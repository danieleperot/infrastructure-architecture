#!/usr/bin/env bash

CACHE=/tmp/.vault-pass-cache

if [ -f "$CACHE" ] && [ $(($(date +%s) - $(stat -c %Y "$CACHE"))) -lt 300 ]; then
  cat "$CACHE"
else
  read -rsp "Vault password: " pw
  echo "$pw" | tee "$CACHE" >/dev/null
  chmod 600 "$CACHE"
  echo "$pw"
fi

