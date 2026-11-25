# Ferrite test data (public)

Recordings, test vectors and reference results for Ferrite's decoders (APRS, FX.25, POCSAG, DSC, WSPR).

- Everything here may be redistributed: our own material, plus a few third-party files whose licences allow it.
- Third-party sets we may not redistribute come through `fetch/`: each script downloads from the original site and
  checks the SHA-256 against `fetch/SHA256SUMS`.
- `PROVENANCE.md` lists where every file group came from and its licence.

## Layout

- `aprs/`: APRS parser vectors (hex packets) with Ham::APRS::FAP's parse of each.
- `dsc/`: VHF DSC calls from dsc_generator, with their symbols and fields.
- `fx25/`: FX.25 frames from Dire Wolf's `gen_packets`, and ours (`fx25/ours/`).
- `pocsag/`: the Wikimedia Commons 512-baud sample, with multimon-ng's decodes.
- `wspr_synth/`: 30 synthetic WSPR slots, with wsprd's decodes and the truth.
- `tools/`: the reference image (Docker: sox, multimon-ng, Dire Wolf, Ham::APRS::FAP) and the DSC generator.

## Fetching the rest

```sh
fetch/all.sh                 # everything below (needs curl, Docker and python3)
fetch/wa8lmf.sh              # WA8LMF TNC Test CD tracks 1 and 2, Dire Wolf's decodes, aprs/wa8lmf.*
fetch/pocsag-sigidwiki.sh    # 6 POCSAG recordings from the Signal Identification Wiki, multimon-ng's decodes
fetch/ham-aprs-fap.sh        # Ham::APRS::FAP 1.21 from CPAN
```

## Using it

Ferrite's tests look for the data beside the `ferrite` checkout. The folders match the private test-data repo's.

## Licence

- Our own material: PolyForm Noncommercial 1.0.0 (`LICENSE.md`), as Ferrite.
- Third-party files keep their own licences: see `PROVENANCE.md`.
