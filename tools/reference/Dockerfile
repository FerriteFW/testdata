# Reference decoders for Ferrite's decoder tests: multimon-ng (POCSAG and more), Dire Wolf (atest: APRS audio; decode_aprs),
# Ham::APRS::FAP (the APRS parser behind aprs.fi), and sox. Nothing here is linked into the crates; tests only
# compare results.
FROM debian:trixie-slim
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        multimon-ng direwolf sox libsox-fmt-mp3 libarchive-tools ca-certificates \
        cpanminus make libdate-calc-perl python3-numpy git \
    && cpanm -q --notest Ham::APRS::FAP@1.21 \
    && rm -rf /var/lib/apt/lists/* /root/.cpanm
COPY fap_dump.pl /usr/local/bin/fap_dump
WORKDIR /work
