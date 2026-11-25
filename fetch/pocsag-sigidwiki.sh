#!/bin/sh
# POCSAG recordings from the Signal Identification Wiki (https://www.sigidwiki.com/wiki/POCSAG), not
# redistributed here: the originals in pocsag/src/, converted to 22050 S/s (multimon-ng's rate) and 9600 S/s (the
# radio's) mono WAVs, with multimon-ng's decodes as recorded and inverted. Needs Docker.
. "$(dirname "$0")/lib.sh"
O=pocsag
get https://www.sigidwiki.com/images/0/0b/POCSAG_512.mp3 $O/src/sigid_512.mp3
get https://www.sigidwiki.com/images/4/49/POCSAG_1200.mp3 $O/src/sigid_1200.mp3
get https://www.sigidwiki.com/images/4/47/POCSAG_2400.mp3 $O/src/sigid_2400.mp3
get https://www.sigidwiki.com/images/4/4f/POCSAG_Sound.mp3 $O/src/sigid_sound.mp3
get https://www.sigidwiki.com/images/b/b3/148.mp3 $O/src/sigid_148.mp3
get https://www.sigidwiki.com/images/e/e2/1200_variant.wav $O/src/sigid_1200_variant.wav
image
docker run --rm -v "$ROOT/$O:/work" "$IMAGE" sh -c '
  for f in src/sigid_*; do
    n=$(basename "${f%.*}")
    sox "$f" -c 1 -b 16 -r 22050 "$n.22050.wav" remix - 2>/dev/null
    sox "$f" -c 1 -b 16 -r 9600 "$n.9600.wav" remix - 2>/dev/null
    for inv in "" -i; do
      sox "$n.22050.wav" -t raw -r 22050 -e signed -b 16 -c 1 - |
        multimon-ng -q -t raw $inv -a POCSAG512 -a POCSAG1200 -a POCSAG2400 -f alpha - \
          > "$n.multimon${inv:+_inv}.txt" 2>/dev/null
    done
  done'
ls -l $O/sigid_*.wav
