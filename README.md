# Custom DBE: radiator booster fan board

**DBE** is a small board that drives 12 V PC fans on a radiator from Home Assistant. A Wemos D1 mini (ESP8266, ESPHome) switches fan power, sets fan speed over PWM, reads fan RPM and reads two DS18B20 pipe sensors (supply and return). The firmware uses those temperatures to run the fans only when the radiator is warm, and faster when the water comes back too warm (small delta T).

This repo holds both versions: **v2**, the board in use today, and **v3**, a full redesign.

| | Where |
|---|---|
| v2 hardware (as built, in use) | [`hardware/v2/`](hardware/v2): EasyEDA Pro project, Gerbers, PCB render (moved from [BarBaar44/EasyEDA](https://github.com/BarBaar44/EasyEDA)) |
| v2 documentation, checked against the project file | [`docs/v2-as-built.md`](docs/v2-as-built.md) |
| Firmware and control logic | [BarBaar44/ESPHome, `DBE/`](https://github.com/BarBaar44/ESPHome/tree/main/DBE) |
| Heating system it belongs to | [BarBaar44/thermostat](https://github.com/BarBaar44/thermostat) |
| Design history | [HA Community: "3 pin pc fan control via mosfet"](https://community.home-assistant.io/t/3-pin-pc-fan-control-via-mosfet/738676) |

## Status

| Version | State |
|---|---|
| v2 (PCB rev 6) | built and running in the house |
| v3 | schematic done, PCB placed and routed, DRC clean. Next: stitching vias, silkscreen, final review. **Not ordered.** |

## How v2 works

![DBE v2 PCB](hardware/v2/PCB_PCB_DBE%20MosFet_6_2026-08-08.png)

1. **12 V in** on a barrel jack.
2. An **LM2596 buck module** makes 5 V for the D1 mini; the D1 mini's own regulator makes 3.3 V.
3. **Fan power:** D0 drives a BC337 transistor, which drives a **12 V relay**. The relay contact switches 12 V to the fan connector. Relay off means the fans have no power at all.
4. **Speed:** D6 drives the fan PWM wire directly, 1 kHz.
5. **RPM:** fan tach on D5, pulled up to 3.3 V.
6. **Temperatures:** two DS18B20 on one OneWire bus (D1), told apart by their addresses in the config.
7. One 4 pin fan connector; all fans daisy chained from it, one tach connected.

```
12V ──jack──┬── LM2596 module ── 5V ── D1 mini
            ├── relay coil ── BC337 ── D0
            └── relay contact ── fan +12V
D6 ── fan PWM      D5 ── fan tach      D1 ── DS18B20 ×2 (one bus)
```

It works, but has real flaws: every track is 0.254 mm while up to 2.4 A flows through it, the barrel jack is rated 0.5 A, the OneWire bus runs at 5 V on a 3.3 V pin, the relay clicks audibly, and the two grounds only meet inside the buck module. Full list in [`docs/v2-as-built.md`](docs/v2-as-built.md#known-issues-for-the-next-revision).

## What changes in v3

Same idea and same D1 mini, new board. Every v2 known issue is addressed.

| Area | v2 | v3 |
|---|---|---|
| Fan power switch | relay (clicks, 0.6 W coil heat, wears) | high side P-FET (AO4407A) via BC337: silent, about 0.12 W at 2.4 A. On/off only, never PWM |
| 5 V supply | LM2596 plug-in module | AP63205 buck on the board |
| Power input | 0.5 A barrel jack, no protection | 5 A barrel jack **or** 2 pin screw terminal (for bare PSU leads), 4 A PTC fuse, reverse polarity P-FET, bulk caps |
| Copper | all tracks 0.254 mm, no pour | wide power tracks, GND pour on both layers |
| Ground | two nets, joined only inside the module | one GND net on the board |
| Logic levels | OneWire bus on 5 V | everything at 3.3 V |
| PWM | ESP pin straight to the fan | open drain via 2N7002, per the Intel fan spec |
| Tach | direct | series resistor, optional filter cap |
| Fan outputs | 1 header, all fans on one chain | 3 headers (fan 1 with RPM), up to 20 fans in three chains |
| Temperature sensors | one bus, sensors by address, bare screw terminals | two buses (D1, D7), no addresses (`index: 0`), pluggable 3.81 mm terminals: swap a sensor without reflashing |
| Boot behaviour | relay on GPIO16, which can go high at boot | fan switch on GPIO4, fans held off until firmware runs |
| Feedback | none | LEDs for power and fans on, D1 mini LED as ESPHome status |
| Silkscreen | reference designators | plain words: `12V IN`, `FAN 1 (RPM)`, `PIPE SENSOR 1`, wire colours |
| BOM | part fields wrong in places (R3 linked to a 300 mΩ shunt) | every part with a checked LCSC number |
| Board | 74 × 53 mm | 67.5 × 56 mm, everything flat, nothing under the D1 mini |

v3 also replaces the Jaga controllers on two Jaga radiators, after their fans are swapped for Arctic PWM PST fans. One board and one firmware for every radiator in the house.

### Firmware is not interchangeable

v3 needs firmware changes and a v2 board with v3 firmware drives the wrong pin:

* fan power switch on **D2** instead of D0
* PWM output `inverted: true` (open drain driver), test 25 kHz
* two OneWire buses (D1 and D7), `index: 0`, drop the sensor address substitutions
* `status_led` on D4

Details in [`docs/schematic-v3.md`](docs/schematic-v3.md#firmware-impact-dbemainyml).

## Repo layout

| Path | Content |
|---|---|
| [`docs/schematic-v3.md`](docs/schematic-v3.md) | v3 spec: decisions, nets, BOM with LCSC numbers, layout notes. Source of truth for the schematic |
| [`docs/v2-as-built.md`](docs/v2-as-built.md) | v2 netlist, pinouts, BOM and known issues, extracted from the EasyEDA project |
| [`docs/ds18b20-pipe-holder.md`](docs/ds18b20-pipe-holder.md) | 3D printed holder that ties the probes onto the radiator collector |
| [`mechanical/ds18b20_tie_holder.scad`](mechanical/ds18b20_tie_holder.scad) | OpenSCAD source for the holder |
| [`docs/DBH-v1-parked.md`](docs/DBH-v1-parked.md) | parked fallback: driver board that keeps the original Jaga fans |
| [`hardware/v2/`](hardware/v2) | v2 EasyEDA Pro project, Gerbers (upload to JLCPCB as is), PCB render |
| [`hardware/v3/`](hardware/v3) | v3 EasyEDA project, Gerbers and render, once exported |

## License

[MIT](LICENSE)
