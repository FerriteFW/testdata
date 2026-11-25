#!/bin/sh
# Rebuilds dsc/: calls made by dsc_generator (Arne Groh; CC0; https://github.com/kywalda/dsc_generator) at a fixed
# commit, modulated by tools/dsc/vectors.py. Needs Docker.
set -e
cd "$(dirname "$0")/.."
docker build -q -t ferrite-testdata-reference tools/reference >/dev/null
docker run --rm -v "$PWD/tools/dsc:/tools" -v "$PWD/dsc:/out" ferrite-testdata-reference sh -c '
    git clone -q https://github.com/kywalda/dsc_generator /tmp/g && cd /tmp/g &&
    git checkout -q 55a861a00a8eded1909c354d1752165befb68776 && python3 /tools/vectors.py /tmp/g /out'
