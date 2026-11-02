# DBE v2: PC Fan Controller Board (as built)

> This documents **v2** (PCB rev 6, as built). The **v3** rebuild is specified in [`schematic-v3.md`](schematic-v3.md).

The v2 design files (EasyEDA Pro project, Gerbers, render) are in [`hardware/v2/`](../hardware/v2), moved from [BarBaar44/EasyEDA](https://github.com/BarBaar44/EasyEDA). This file replaces the README there as the reference: it was extracted from the `.epro2` project (PCB netlist, device records) and the Gerber package, not from memory. Where the project disagrees with itself, that is listed under [Known issues](#known-issues-for-the-next-revision).

An ESP8266 (Wemos D1 mini) running ESPHome switches 12 V PC fans fully on/off with a relay, sets their speed over PWM, reads fan RPM and reads two DS18B20 pipe sensors.

* Firmware and control logic: [BarBaar44/ESPHome/DBE](https://github.com/BarBaar44/ESPHome/tree/main/DBE)
* Enclosure: FreeCAD repo
* Design history: [HA Community, "3 pin pc fan control via mosfet"](https://community.home-assistant.io/t/3-pin-pc-fan-control-via-mosfet/738676)

**Revision:** schematic rev 15F, PCB layout rev 6 (silkscreen "DBE Version 2.0"), exported 2026-08-08.

> **Why "MosFet" in the file names:** early versions tried a MOSFET, then a transistor pair. The built design is relay switched. Names kept for continuity.

---

## How it works

1. **12 V in** on DC2 (barrel jack).
2. **U3 (LM2596 buck module)** makes 5 V for the D1 mini `5V` pin. The D1 mini's own regulator makes 3.3 V.
3. **Power switch:** D0 (GPIO16) drives **Q2 (BC337)** through **R3**. Q2 sinks the coil of **K2 (SRA-12VDC-AL relay)**. The relay's normally open contact connects 12 V to the fan connector. Relay off means fan fully unpowered (fail safe).
4. **Speed:** D6 (GPIO12) drives the fan PWM wire directly.
5. **RPM:** fan tach on D5 (GPIO14), pulled up to 3.3 V by U7.
6. **Temperatures:** two DS18B20 on screw terminals U2/U4, shared OneWire bus on D1 (GPIO5), pulled up by R1.
7. **Protection:** D2 across the relay coil, D3 across the fan output.

```
12V ──DC2──┬───────────── U3 IN+ ──► LM2596 ──► 5V ── D1 mini 5V, R1, U2/U4 pin 3
           ├── K2 coil ── Q2 C   (D2 across coil)
           │              Q2 B ── R3 ── D0      Q2 B ── U5 10k ── GND
           │              Q2 E ── GND
           └── K2 COM ── K2 NO ── P1.3 fan +12V  (D3 across fan output)
D6 ── P1.1 PWM          D5 ── P1.2 tach ── U7 ── 3V3          D1 ── U2/U4 pin 2 ── R1 ── 5V
```

## Board

* 74.0 × 53.0 mm, 2 layers, 1 oz, no copper pour, 4 × M2 mounting holes.
* SMD on top: R1 (0603), U5 (1206), R3 (2512). Everything else through hole.
* All tracks are 0.254 mm (10 mil). See known issues.

![PCB layout](../hardware/v2/PCB_PCB_DBE%20MosFet_6_2026-08-08.png)

## Connectors

### DC2: 12 V input (5 A barrel jack fitted; the project links a different part, see issue 9)
| Pin | Net |
|---|---|
| 1 (centre) | +12 V |
| 2, 3 | GND (power) |

### P1: fan output (KF2510 4 pin, 2.54 mm, LCSC C61409)
| Pin | Silk | Signal | ESP pin |
|---|---|---|---|
| 1 | S | PWM | D6 / GPIO12 |
| 2 | T | Tach | D5 / GPIO14 (pull-up 3.3 V) |
| 3 | L | +12 V, relay switched | |
| 4 | N | GND | |

The footprint numbers its pads from the other end than the PC fan standard; physically it matches standard fan plugs (proven in use). Multiple fans hang off this one connector, daisy chained; only one fan's tach should be connected.

### U2, U4: DS18B20 sensors (Amphenol YO0301500000G, 3 pin 3.5 mm terminal, LCSC C2683167)
| Pin | Silk | Signal |
|---|---|---|
| 1 | N | GND |
| 2 | D | OneWire data, D1 / GPIO5 |
| 3 | L | 5 V (see known issues) |

DS18B20 wiring: red to L, yellow to D, black to N. Which sensor goes on which pipe does not matter; firmware takes the warmer one as supply.

### U3: LM2596 module footprint
| Pad | Signal |
|---|---|
| 1 | IN− (power GND) |
| 2 | IN+ (+12 V) |
| 3 | OUT+ (5 V) |
| 4 | OUT− (logic GND) |
| 7 to 10 | mechanical only |

Set the module to **5.0 V before** fitting the D1 mini.

## ESP8266 pin use

| D1 mini | GPIO | Function | Firmware (`DBEmain.yml`) |
|---|---|---|---|
| D0 | 16 | Relay drive | `switch: powerswitch` |
| D1 | 5 | OneWire | `one_wire` |
| D5 | 14 | Fan tach | `pulse_counter`, ×0.5 |
| D6 | 12 | Fan PWM | `esp8266_pwm`, 1 kHz |
| 5V | | from LM2596 | |
| 3V3 | | tach pull-up | |
| GND | | logic GND | |

Unused: RST, A0, D2, D3, D4, D7, D8, TX, RX.

## Netlist (from the PCB)

| Net | Connects | Meaning |
|---|---|---|
| $1N6416 | DC2.1, U3.2, K2.3, K2.5, D2.K | +12 V |
| $1N5771 | DC2.2, DC2.3, U3.1, Q2.E, U5.2, D3.A, P1.4 | power GND |
| $1N3338 | D1 mini GND, U3.4, U2.1, U4.1 | logic GND |
| $1N1850 | D1 mini 5V, U3.3, R1.1, U2.3, U4.3 | 5 V |
| $1N3125 | D1 mini 3V3, U7.1 | 3.3 V |
| $1N1389 | D0, R3.1 | relay drive |
| $1N2807 | R3.2, Q2.B, U5.1 | Q2 base |
| $1N6420 | Q2.C, K2.4, D2.A | relay coil low side |
| $1N4493 | K2.1, D3.K, P1.3 | switched fan +12 V |
| $1N1762 | D6, P1.1 | PWM |
| $1N5826 | D5, U7.2, P1.2 | tach |
| $1N1 | D1, R1.2, U2.2, U4.2 | OneWire data |

Power GND and logic GND are separate nets on the PCB and only meet inside the LM2596 module (IN− and OUT− are common there). Without the module fitted the ESP and the fan circuit have no common ground.

## BOM (as stored in the project)

| Ref | Part | Footprint | LCSC | Note |
|---|---|---|---|---|
| 1 | Wemos D1 mini | WEMOS-D1-MINI | | headers |
| U3 | LM2596 buck module | LM2596 | | set to 5 V |
| K2 | SRA-12VDC-AL relay, 1A, 12 V coil 240 Ω, 10 A | RELAY-TH_SRA-XXVDC-AL | C86414 | |
| Q2 | BC337-40 NPN | TO-92 | C713611 | pad 1 C, 2 B, 3 E |
| D2, D3 | 1N4007 | DO-41 | C106903 | |
| R3 | **see issue 3** | 2512 | C186683 | |
| U5 | 10 kΩ | 1206 | C5141115 | base pull-down |
| U7 | **see issue 4** | THT 2.4 × 6.3 mm | C3429539 | tach pull-up |
| R1 | 4.7 kΩ | 0603 | | OneWire pull-up |
| DC2 | DC-005-20A | | C136744 | linked part is rated 0.5 A; the fitted jack is 5 A, see issue 9 |
| P1 | KF2510 4 pin | | C61409 | |
| U2, U4 | YO0301500000G | | C2683167 | |

## Manufacturing

[`Gerber_PCB_DBE_MosFet_6_2026-08-08.zip`](../hardware/v2/Gerber_PCB_DBE_MosFet_6_2026-08-08.zip) holds Gerbers (copper, silk, mask, top paste, outline, document), PTH/NPTH/via drills and a JLCPCB flying probe file. Upload the zip as is to JLCPCB. Hand assembly is assumed: the stored BOM is not clean enough for PCBA (issues 3, 4 and 9).

Assembly order: SMD resistors, diodes (stripe = K, check D2 and D3 orientation against silk), Q2 (flat face per silk), relay, connectors, LM2596 module (adjust to 5 V first), D1 mini last.

First power up: 12 V in without the D1 mini, check 5 V on the module output, check continuity between power GND and logic GND, then fit the D1 mini.

---

## Known issues for the next revision

Ordered by importance. All of them are addressed in [v3](schematic-v3.md).

1. **Track width.** Every track is 0.254 mm. The 12 V fan path (DC2 → K2 → P1.3) and GND return carry up to about 2.5 A with 15 fans. A 0.254 mm 1 oz outer track is good for roughly 0.9 A at 10 °C rise; 2.5 A gives a rise far above that. Fix: 1.5 mm or wider for +12 V, switched 12 V and power GND, or a GND pour on the bottom. Fine for one or two fans as is.
2. **DS18B20 bus on 5 V.** R1 and the sensor supply go to 5 V, so the OneWire line idles at 5 V on GPIO5. The ESP8266 is a 3.3 V part; this works in practice through clamp diodes but is out of spec. Fix: move R1.1, U2.3, U4.3 to 3V3. The ESPHome README and the old EasyEDA README already claimed 3.3 V; the board does not match.
3. **R3 part mismatch.** Schematic name is "R470" (470 Ω) but the linked part is a 300 mΩ 1 W 2512 current shunt (KOA SR73W3ATTER300F). Fitted as stored it would short D0 into the base. ESPHome README says about 1 kΩ. Fix: pick one, 470 Ω or 1 kΩ, in 0805 or 1206, and correct the device. Either value saturates Q2 for a 50 mA coil.
4. **U7 value mismatch.** Value field says 4.7 kΩ, linked part is 13.3 kΩ. Both work as a tach pull-up. Pick one and make the fields agree.
5. **Ground through the module.** See netlist note. Fix: tie power GND and logic GND with a track on the PCB.
6. **D0 at boot.** GPIO16 is commonly reported to go high briefly at boot, which may pulse the relay and fans on reset. Verify on a board; if it happens, move the relay to D1 or D2 (and OneWire elsewhere) or accept it.
7. **Fan connector:** pad numbering differs from the fan standard, but the physical pinout is correct and works. Keep this part (right angle, connector on the side).
8. **Size reduction idea** (from the forum): replace the LM2596 module with a small fixed 5 V buck module. Only when boards need replacing.
9. **DC2 part mismatch.** The project links DC-005-20A (C136744), whose datasheet rates it at 0.5 A. The jack actually fitted on the built boards is a 5 A part, so the boards are fine at 2.4 A. Fix: correct the device in the project before any v2 reorder. v3 uses a checked 5 A part (C381116).

Firmware side, not PCB: PWM runs at 1 kHz; the Intel fan spec is 25 kHz. Some fans whine at 1 kHz.

## Revision history

* **2025-01-06** Initial project upload (`ProPrj_DBE MosFet_15F_2025-01-06.epro`).
* **2026-08-08** Project export `.epro2`, Gerbers and render, PCB rev 6.
* **2026-10-29** README rebuilt from the project file: netlist, pinouts, BOM, known issues. Earlier README called U2/U4 fan headers; they are the DS18B20 terminals.
* **2026-11-02** Design files moved from BarBaar44/EasyEDA to `hardware/v2/` in this repo.
