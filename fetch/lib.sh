# Shared by the fetch scripts (sourced, not run).
set -e
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"
IMAGE=ferrite-testdata-reference

sha256() {
    if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | cut -d' ' -f1; else shasum -a 256 "$1" | cut -d' ' -f1; fi
}

# check PATH: the file's SHA-256 must match fetch/SHA256SUMS.
check() {
    want=$(awk -v p="$1" '$2 == p { print $1 }' fetch/SHA256SUMS)
    [ -n "$want" ] || { echo "$1: not in fetch/SHA256SUMS" >&2; exit 1; }
    got=$(sha256 "$1")
    [ "$got" = "$want" ] || { echo "$1: SHA-256 $got, want $want (delete it and run again)" >&2; exit 1; }
}

# get URL PATH: download once, then check.
get() {
    if [ ! -s "$2" ]; then
        mkdir -p "$(dirname "$2")"
        curl -fL --retry 3 -A ferrite-testdata -o "$2.part" "$1"
        mv "$2.part" "$2"
    fi
    check "$2"
}

# The reference tools (sox, multimon-ng, Dire Wolf, Ham::APRS::FAP) in Docker: tools/reference/Dockerfile.
image() {
    docker build -q -t "$IMAGE" tools/reference >/dev/null
}
