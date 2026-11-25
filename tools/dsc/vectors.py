#!/usr/bin/env python3
"""VHF DSC test vectors for udsc, built with an independent encoder: dsc_generator (Arne Groh, after Wire2waves;
CC0; https://github.com/kywalda/dsc_generator), imported as it is. Its symbol building, ECC, DX/RX interleaving and
bitstream are used unchanged; only the audio output is replaced (it plays to a sound card through PyAudio): the
bits are FSK-modulated here, phase-continuous, 1300 Hz for 1 and 2100 Hz for 0 at 1200 baud, as its modulate() does.

Writes <out>/<name>.wav (9600 S/s, 16-bit) and <out>/vectors.json (the symbols and fields of each call).
Usage: vectors.py <dsc_generator dir> <out dir>"""
import json, math, struct, sys, types, wave

sys.modules["pyaudio"] = types.SimpleNamespace(PyAudio=lambda: types.SimpleNamespace(open=lambda **k: None), paInt16=8)
sys.path.insert(0, sys.argv[1])
import dsc_functions as g  # noqa: E402

RATE = 9600


def audio(call, lead=0.3, tail=0.3):
    bits = g.make_bitstream(g.interleave(g.parity_table, g.phasing_symbol, call))
    out, ph = [0] * int(lead * RATE), 0.0
    n = round(RATE * len(bits) / 1200)
    for i in range(n):
        b = bits[int(i / n * len(bits))]
        f = 1700 - 400 if b == "1" else 1700 + 400
        ph = (ph + 2 * math.pi * f / RATE) % (2 * math.pi)
        out.append(int(12000 * math.sin(ph)))
    return out + [0] * int(tail * RATE)


def wav(path, samples):
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b"".join(struct.pack("<h", s) for s in samples))


ship, other, coast, group = "235012340", "366123450", "002304100", "036612345"
calls = {}
# Individual routine call, working channel 72 (VHF channel field: 90, then the channel number).
calls["individual_routine"] = (g.build_call(120, g.mmsi_symbol(other), 100, g.mmsi_symbol(ship), 100, 126, g.freq_symbol("900072"), 117),
    dict(format=120, address=366123450, category=100, self_id=235012340, tc1=100, tc2=126, channel=72, eos=117))
calls["individual_ack"] = (g.build_call(120, g.mmsi_symbol(ship), 100, g.mmsi_symbol(other), 100, 126, g.freq_symbol("900072"), 122),
    dict(format=120, address=235012340, category=100, self_id=366123450, tc1=100, tc2=126, channel=72, eos=122))
calls["individual_test"] = (g.build_call(120, g.mmsi_symbol(coast), 108, g.mmsi_symbol(ship), 118, 126, [126, 126, 126], 117),
    dict(format=120, address=2304100, category=108, self_id=235012340, tc1=118, tc2=126, eos=117))
calls["all_ships_safety"] = (g.build_call(116, [], 108, g.mmsi_symbol(coast), 100, 126, g.freq_symbol("900016"), 127),
    dict(format=116, category=108, self_id=2304100, tc1=100, tc2=126, channel=16, eos=127))
calls["all_ships_urgency"] = (g.build_call(116, [], 110, g.mmsi_symbol(ship), 100, 126, g.freq_symbol("900006"), 127),
    dict(format=116, category=110, self_id=235012340, tc1=100, tc2=126, channel=6, eos=127))
calls["group_routine"] = (g.build_call(114, g.mmsi_symbol(group), 100, g.mmsi_symbol(ship), 100, 126, g.freq_symbol("900069"), 127),
    dict(format=114, address=36612345, category=100, self_id=235012340, tc1=100, tc2=126, channel=69, eos=127))
# Distress: self-ID, nature, position (quadrant, DDMM, DDDMM), UTC HHMM, subsequent communications (F3E).
calls["distress_mob"] = (g.build_call(112, g.mmsi_symbol(ship), 110, g.area_symbol("1513000007"), 12, 34, [100], 127),
    dict(format=112, self_id=235012340, nature=110, lat_min=51 * 60 + 30, lon_min=-(0 * 60 + 7), utc=[12, 34], subsequent=100, eos=127))
calls["distress_sinking_se"] = (g.build_call(112, g.mmsi_symbol(other), 105, g.area_symbol("2335115112"), 3, 5, [100], 127),
    dict(format=112, self_id=366123450, nature=105, lat_min=-(33 * 60 + 51), lon_min=151 * 60 + 12, utc=[3, 5], subsequent=100, eos=127))
calls["distress_unknown_position"] = (g.build_call(112, g.mmsi_symbol(ship), 107, [99, 99, 99, 99, 99], 88, 88, [100], 127),
    dict(format=112, self_id=235012340, nature=107, utc=None, subsequent=100, eos=127))
# Distress acknowledgement by a coast station (all ships, category distress, telecommand 110).
ack = g.build_dis_ack_call(116, 112, g.mmsi_symbol(coast), 110, g.mmsi_symbol(ship), 110, g.area_symbol("1513000007"), [12, 34], 100, 127)
calls["distress_ack"] = (ack, dict(format=116, category=112, self_id=2304100, tc1=110, distressed=235012340, nature=110,
    lat_min=51 * 60 + 30, lon_min=-(0 * 60 + 7), utc=[12, 34], subsequent=100, eos=127))
calls["geographic_area"] = (g.build_call(102, g.area_symbol("1500101010"), 108, g.mmsi_symbol(coast), 100, 126, g.freq_symbol("900016"), 127),
    dict(format=102, area=[1, 50, 10, 10, 10], category=108, self_id=2304100, tc1=100, tc2=126, channel=16, eos=127))

out = sys.argv[2]
vectors = []
for name, (call, fields) in calls.items():
    wav(f"{out}/{name}.wav", audio(call))
    vectors.append(dict(name=name, symbols=[int(s) for s in call], fields=fields))
# Several calls back to back in one file.
both = []
for name in ["individual_routine", "distress_mob", "all_ships_safety"]:
    both += audio(calls[name][0], lead=0.5, tail=0.5)
wav(f"{out}/three_calls.wav", both)
json.dump(vectors, open(f"{out}/vectors.json", "w"), indent=1)
print(f"{len(vectors)} calls")
