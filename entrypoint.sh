#!/bin/bash

(
  sleep 2
  while ! warp-cli --accept-tos register; do
    sleep 1
    echo >&2 "Awaiting warp-svc become online..."
  done

  warp-cli --accept-tos set-mode proxy
  warp-cli --accept-tos set-proxy-port 40000
  warp-cli --accept-tos disable-dns-log
  warp-cli --accept-tos set-families-mode "${FAMILIES_MODE}"
  if [[ -n $WARP_LICENSE ]]; then
    warp-cli --accept-tos set-license "${WARP_LICENSE}"
  fi
  warp-cli --accept-tos connect

  # socat is used to redirect traffic from 1080 to 40000
  socat tcp-listen:1080,reuseaddr,fork tcp:localhost:40000
) &

exec warp-svc | grep -v DEBUG
warp-cli enable-always-on
