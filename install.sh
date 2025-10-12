#!/usr/bin/env bash
set -euo pipefail
WEBHOOK_URL="${WEBHOOK_URL:-https://discord.com/api/webhooks/YOUR_ID/YOUR_TOKEN}"
DOWNLOAD_URL="https://example.com/myapp-macos.tar.gz"
EXPECTED_SHA="replace_with_sha256_hex"
read -r -p "Installer will download and install MyApp. Continue? (y/N) " reply
reply="${reply,,}"
if [[ "$reply" != "y" && "$reply" != "yes" ]]; then echo "Aborted."; exit 1; fi
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT
ARCHIVE="$TMPDIR/myapp.tar.gz"
curl -fL --retry 3 --retry-delay 2 -o "$ARCHIVE" "$DOWNLOAD_URL"
printf "%s  %s\n" "$EXPECTED_SHA" "$ARCHIVE" > "$TMPDIR/checksum"
shasum -a 256 -c "$TMPDIR/checksum"
tar -xzf "$ARCHIVE" -C "$TMPDIR"
if [[ -x "$TMPDIR/install.sh" ]]; then
  "$TMPDIR/install.sh"
else
  if command -v installer >/dev/null 2>&1 && [[ -f "$TMPDIR/MyApp.pkg" ]]; then
    sudo installer -pkg "$TMPDIR/MyApp.pkg" -target /
  fi
fi
read -r -p "Send install notification to Discord webhook? (y/N) " notify
notify="${notify,,}"
if [[ "$notify" == "y" || "$notify" == "yes" ]]; then
  HOST_INFO="$(whoami)@$(hostname)"
  CONTENT="$(printf "Installed MyApp on %s — %s" "$HOST_INFO" "$(date -u +"%Y-%m-%dT%H:%M:%SZ")")"
  PAYLOAD="$(printf '{"username":"installer","content":"%s"}' "$CONTENT")"
  curl -sS -H "Content-Type: application/json" -X POST -d "$PAYLOAD" "$WEBHOOK_URL" || true
fi
echo "Done."
