#!/bin/sh
# The WA8LMF TNC Test CD, ver 2.0 (http://wa8lmf.net/TNCtest/), from its author's site: tracks 1 and 2 as 16-bit
# mono WAVs at 44.1 kHz and 9600 Hz in wa8lmf/, Dire Wolf's decodes in wa8lmf/ref/, and the APRS parser vectors
# built from them (aprs/wa8lmf.hex and .jsonl). Needs Docker.
. "$(dirname "$0")/lib.sh"
D=wa8lmf
get http://www.wa8lmf.net/TNCtest/TNC_Test_2.iso $D/TNC_Test_2.iso
image
mkdir -p $D/iso $D/ref
docker run --rm -v "$ROOT/$D:/d" "$IMAGE" bsdtar -xf /d/TNC_Test_2.iso -C /d/iso
for n in 01 02; do
    src=$(find $D/iso -iname "*${n}*.flac" | head -1)
    [ -n "$src" ] || { echo "track $n not found in the image" >&2; exit 1; }
    cp "$src" $D/track$n.flac
    docker run --rm -v "$ROOT/$D:/d" "$IMAGE" sh -c \
        "sox /d/track$n.flac -c 1 -b 16 /d/track$n.wav && sox /d/track$n.flac -c 1 -b 16 -r 9600 /d/track${n}_9600.wav"
done
for t in track01 track01_9600 track02 track02_9600; do
    docker run --rm -v "$ROOT/$D:/d" "$IMAGE" sh -c "atest -h /d/$t.wav 2>&1" |
        LC_ALL=C sed 's/\x1b\[[0-9;]*m//g' > $D/ref/$t.atest.txt
done

# Every distinct packet Dire Wolf decoded, as APRS-IS carries it (trailing CR/LF stripped; third-party traffic also
# unwrapped), then Ham::APRS::FAP's parse of each.
LC_ALL=C cat $D/ref/*.atest.txt | python3 -c '
import re, sys
seen = []
for line in sys.stdin.buffer:
    m = re.match(rb"^\[0[^\]]*\] (.*?)\r?\n?$", line)
    if not m:
        continue
    raw = re.sub(rb"<0x([0-9a-f]{2})>", lambda g: bytes([int(g.group(1), 16)]), m.group(1)).rstrip(b"\r\n")
    info = raw.split(b":", 1)[1] if b":" in raw else b""
    inner = info[1:] if info.startswith(b"}") else None
    for p in (raw, inner):
        if p and p not in seen:
            seen.append(p)
for raw in seen:
    print(raw.hex())
' > aprs/wa8lmf.hex
docker run --rm -i "$IMAGE" fap_dump < aprs/wa8lmf.hex > aprs/wa8lmf.jsonl
ls -l $D/*.wav
