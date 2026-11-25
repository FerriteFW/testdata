#!/bin/sh
# Every third-party set. Downloads are checked against fetch/SHA256SUMS.
set -e
D=$(dirname "$0")
for s in ham-aprs-fap pocsag-sigidwiki wa8lmf; do
    echo "== $s"
    sh "$D/$s.sh"
done
