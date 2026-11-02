# DBE v3.0: Schematic spec

Rebuild of the DBE radiator booster fan board (PC fans). This file is the source of truth for the schematic and net names. Draw the EasyEDA schematic from it; the PCB comes after.

Status: **draft**, updated 2026-11-01. Schematic complete in EasyEDA; netlist exported 2026-10-31 and checked against this spec, all nets match. PCB placed and routed 2026-11-01, GND pours on both layers, DRC clean. Next: stitching vias, silkscreen, final review. Not ordered.

Related: [`v2-as-built.md`](v2-as-built.md) (v2 as built), [`DBH-v1-parked.md`](DBH-v1-parked.md) (Jaga driver board, **parked**: the Jaga radiators get PC fans and this board instead, see decision 16).

## Decisions

| # | Decision | Reason |
|---|---|---|
| 1 | Keep Wemos D1 mini on headers | proven, no firmware rework |
| 2 | Buck on board: AP63205 fixed 5 V | replaces LM2596 module, saves space |
| 3 | Polyfuse + reverse polarity P-FET + bulk caps on input | cheap protection |
| 4 | Fan power switched by a high side P-FET (Q4, AO4407A, same part as Q1), driven by Q2. v2 relay dropped. Q4 is on/off only, never PWM | silent (relay click is audible in living rooms), no 0.6 W coil heat, no wear. At 2.4 A Q4 loses about 0.12 W (+9 °C). The v1 MOSFET overheated from weak 3.3 V gate drive and/or PWM through it; here Vgs is about −11 V and speed goes over the fan PWM wire |
| 5 | Three 4-pin fan headers, right angle (KF2510-4AGW, as v2, proven with the fans): J2 fan 1 with tach, J3 and J6 fans 2 and 3 without tach | fan cables plug in directly (proven on v2), keyed, connector exits sideways, no tools; up to 20 fans as three chains (max 2.4 A total) |
| 6 | Tach only on J2 | only one tach can be read per GPIO; fan 1 is the sample. J3/J6 pin 2 not connected |
| 7 | PWM open drain via 2N7002 | Intel fan spec; no fan 5 V pull-ups back-feeding the ESP |
| 8 | All logic at 3.3 V, DS18B20 bus on 3V3 | fixes v2 5 V on GPIO5 |
| 9 | Fan switch drive moved D0 (GPIO16) to D2 (GPIO4) | GPIO16 may go high at boot |
| 10 | One GND net, joined on the board | v2 grounds only met inside the module |
| 11 | Hand soldered: 0805 / 1206 passives, SOT-23, SOIC-8, TSOT-23-6, THT | |
| 12 | Two DS18B20 on separate OneWire buses (D1 and D7) | no sensor addresses in config (`index: 0`), sensor swap without reflash, one faulty sensor cannot block the other, either sensor in either port |
| 13 | Sensor ports: pluggable 3-pin terminal blocks (3.81 mm), wire colours on silk | plug fits one way only; wires screwed into the plug off the board, or sensors pre-wired |
| 14 | Status LEDs: red power (+5V) and green fans powered (`FAN_12V_SW`); D1 mini onboard LED (D4) as status in firmware | user sees board alive and fan power state without tools |
| 15 | Silkscreen in plain words at every connector | no reference designators near connectors |
| 16 | PC fans only. The Jaga radiators are converted to Arctic PWM PST fans and use this board; the Jaga controller, driver boards and fans come out (kept for going back). DBH board parked | one board design and one firmware for every radiator; quieter fans, RPM feedback, real low speed range |
| 17 | Power input: J1 barrel jack **or** J7 2-pin 5.08 mm screw terminal, same nets, fit one; footprints overlap so both cannot be fitted | the Jaga radiators have a Mean Well PSU with bare leads; two fitted inputs could short two supplies in series |
| 18 | Board marked as a development board on the silk (bottom layer): `DBE v3.0 DEVELOPMENT BOARD` / `Not a finished consumer product. For development and evaluation only.` | boards are sold or given to others; marks it as a dev board rather than a finished product |

## Installations

| Site | Fans | Max current | Supply | Input |
|---|---|---|---|---|
| DBE radiators | up to 15 PC fans | about 2.4 A | 12 V adapter | J1 |
| Jaga unit 1 (DBH, fan tray 37605.010104) | 20 × Arctic P9 PWM PST (CO), 92 mm, 0.12 A, replacing ADDA AD0912MB-A70GL | 2.4 A | check: model and ≥ 40 W | J7 (if bare leads) |
| Jaga unit 2 (Vertiga 053) | 4 × Arctic P12 PWM PST, 120 mm, replacing ADDA AD1212MB-A71GL | about 0.4 A | Mean Well NPF-40-12, 12 V 3.34 A, bare leads | J7 |

PST fans daisy chain: one chain per header. Only the first fan of the J2 chain reports RPM. Check that the replacement fans match the frame size (92 or 120 × 25 mm), screw holes and airflow direction of the originals.

## Blocks

The schematic has one page with five blocks, connected by net labels only:

1. **POWER**: J1 DC jack, J7 screw terminal, F1, Q1, D1, C1, buck U1 with its parts
2. **MCU**: Wemos D1 mini (M1)
3. **FAN**: fan switch Q4 with driver Q2, PWM driver, tach, J2/J3/J6 fan headers, LED2
4. **SENSORS**: J4, J5 DS18B20 terminals, one OneWire bus each
5. **STATUS**: LED1 power (may sit in the POWER block)

POWER, MCU and SENSORS were shared with the DBH board; DBH is parked, so no need to keep them in sync.

## Nets

| Net | Members | Track |
|---|---|---|
| `VIN_RAW` | J1.1 (centre +), J7.1 (+), F1.1 | wide (≥1.5 mm) |
| `VIN_F` | F1.2, Q1.D | wide |
| `VIN_12V` | Q1.S, D1.K, C1+, C2.1, C3.1, U1.VIN, U1.EN, Q4.S, R14.1 | wide to Q4, normal to U1 |
| `PFET_G` | Q1.G, R1.1, D1.A | normal |
| `GND` | J1.2, J1.3, J7.2 (−), R1.2, C1−, C2.2, C3.2, C5.2, C6.2, U1.GND, M1.GND, Q2.E, R5.2, Q3.S, R7.2, D4.A, J2.4, J3.4, J6.4, J4.1, J5.1, C8.2, C9.2, C10.2, LED1.K, LED2.K | wide; bottom pour preferred |
| `BUCK_SW` | U1.SW, L1.1, C4.1 | short, compact |
| `BUCK_BST` | U1.BST, C4.2 | short |
| `+5V` | L1.2, U1.FB, C5.1, C6.1, M1.5V, R12.1 | normal |
| `LED1_A` | R12.2, LED1.A | normal |
| `+3.3V` | M1.3V3, R8.1, R9.1, R11.1, J4.3, J5.3, C8.1, C10.1 | normal |
| `FANSW_EN` | M1.D2 (GPIO4), R4.1 | normal |
| `FANSW_B` | R4.2, R5.1, Q2.B | normal |
| `FANSW_DRV` | Q2.C, R15.2 | normal |
| `FANSW_G` | Q4.G, R14.2, R15.1 | normal |
| `FAN_12V_SW` | Q4.D, D4.K, J2.3, J3.3, J6.3, R13.1 | wide (≥1.5 mm) to every header |
| `LED2_A` | R13.2, LED2.A | normal |
| `FAN_PWM` | Q3.D, J2.1, J3.1, J6.1 | normal |
| `PWM_GATE` | R6.2, R7.1, Q3.G | normal |
| `PWM_MCU` | M1.D6 (GPIO12), R6.1 | normal |
| `FAN_TACH` | J2.2, R8.2, R10.1 | normal |
| `TACH_MCU` | R10.2, M1.D5 (GPIO14), C9.1 | normal |
| `ONEWIRE_1` | M1.D1 (GPIO5), R9.2, J4.2 | normal |
| `ONEWIRE_2` | M1.D7 (GPIO13), R11.2, J5.2 | normal |

### Reverse polarity circuit

P-channel MOSFET in the high side, drain towards the jack:

* Q1 D to `VIN_F`, S to `VIN_12V`, G to `PFET_G`
* R1 10 kΩ from `PFET_G` to `GND`
* D1 12 V zener from `PFET_G` (A) to `VIN_12V` (K), clamps Vgs

Correct polarity: the body diode conducts, the gate is pulled low, and the FET turns fully on. Reversed: the FET stays off. Matters more with J7: bare wires get swapped more easily than a barrel plug.

### Unused D1 mini pins
RST, A0, D0, D3, D4, D8, TX, RX: no connect (mark with NC flags). D4 drives the D1 mini's onboard LED; keep it free.

J3.2 and J6.2 (tach on fans 2 and 3): no connect.

## Parts

LCSC numbers marked ✓ were checked on LCSC or JLCPCB. Stock changes; check again when ordering. Footprints: use the LCSC/EasyEDA footprint for each part number, not a generic one.

### POWER
| Ref | Value | Package | Part | LCSC |
|---|---|---|---|---|
| J1 | DC barrel jack 5.5/2.1 plug, 2.0 mm pin, 5 A 24 V | THT right angle | XKB DC-005-5A-2.0 | C381116 ✓ |
| J7 | Screw terminal 2-pin, 5.08 mm pitch, 24 A, 12 to 22 AWG | THT | Kefa KF128-5.08-2P-AA | C474952 ✓ |
| F1 | PTC 4.0 A hold, 8.0 A trip, 30 V | THT radial, 14.0 × 5.8 mm body, 19.3 mm tall, 7.6 mm lead spacing | Littelfuse RUEF400 (replaces JK60-375: 60 V part was about 24 × 28.5 mm, too large) | C2760163 ✓ |
| Q1 | P-MOSFET 30 V 12 A | SOIC-8 | AOS AO4407A | C16072 ✓ |
| D1 | Zener 12 V 500 mW | SOD-123 | MCC BZT52C12-TP | C668891 ✓ |
| R1 | 10 kΩ 1 % | 0805 | UNI-ROYAL 0805W8F1002T5E | C17414 ✓ |
| C1 | 100 µF 25 V electrolytic, 105 °C, low ESR | THT radial 6.3 × 11.2 mm, 5 mm pitch (SB suffix = B taping, leads formed to 5 mm; straight lead version is 2.5 mm) | Panasonic EEU-FC1E101SB | C1669168 ✓ |
| U1 | Buck 5 V fixed, 2 A, 3.8 to 32 V in | TSOT-23-6 | Diodes AP63205WU-7 | C2071056 ✓ |
| C2, C3 | 10 µF 25 V X5R | 1206 | Samsung CL31A106KAHNNNE | C9807 ✓ |
| C4 | 100 nF 50 V X7R (BST) | 0805 | YAGEO CC0805KRX7R9BB104 | C49678 ✓ |
| L1 | 4.7 µH, 3 A rated, 3.5 A Isat, 32 mΩ, shielded | 5 × 5 mm | CENKER CKCS5040-4.7uH/M (alt: Sumida 0630CDMCCDS-4R7MC C167294, 6.6 × 7 mm, 6.8 A Isat, low stock) | C354606 ✓ |
| C5, C6 | 22 µF 25 V X5R | 1206 | Samsung CL31A226KAHNNNE | C12891 ✓ |
| LED1 | LED red | 0805 | KENTO KT-0805R (same family as LED2, same footprint LED0805-R-RD: pad 2 = K) | C2295 ✓ |
| R12 | 1 kΩ (about 3 mA at 5 V) | 0805 | UNI-ROYAL 0805W8F1001T5E | C17513 ✓ |

F1: 4 A hold because a PTC's hold current drops when warm. At about 50 °C behind a radiator it holds roughly 3.2 A, comfortably above the 2.4 A load (a 3 A part would hold only about 2.4 A). Jaga unit 1 (20 × 0.12 A) lands on the same 2.4 A. 30 V rating also covers a 24 V adapter mix-up.

C1: φ6.3 mm FC endurance is 1000 h at 105 °C, roughly 7 years continuous at 45 °C. Kept; an 8 mm FC (2000 h, 3.5 mm pitch) is the option if it ages early.

J1 and J7: fit one. Silk at J7: `12V IN` with `+` and `−` at the pins. The terminal has no polarity marking: `+` goes at the pad of footprint pin 1 (`VIN_RAW`); check the pad number in the footprint before placing silk.

AP63205 pins (TSOT-23-6): 1 FB, 2 EN, 3 VIN, 4 GND, 5 SW, 6 BST. FB goes to `+5V` (fixed version, no divider). EN is tied to VIN.

### MCU
| Ref | Value | Notes |
|---|---|---|
| M1 | Wemos D1 mini | 2 × 8 pin female headers, normally supplied with the D1 mini. Wemos D1 mini Pro fits the same footprint (u.FL for an external antenna) as fallback for weak WiFi |

### FAN
| Ref | Value | Package | Part | LCSC |
|---|---|---|---|---|
| Q4 | P-MOSFET 30 V 12 A, fan power switch | SOIC-8 | AOS AO4407A (same as Q1) | C16072 ✓ |
| R14 | 10 kΩ gate to source, holds Q4 off | 0805 | UNI-ROYAL 0805W8F1002T5E | C17414 ✓ |
| R15 | 1 kΩ gate series, Q2 collector to Q4 gate | 0805 | UNI-ROYAL 0805W8F1001T5E | C17513 ✓ |
| Q2 | NPN 45 V 800 mA | TO-92 | BC337-40 (keep) | C713611 |
| R4 | 1 kΩ base | 0805 | UNI-ROYAL 0805W8F1001T5E | C17513 ✓ |
| R5 | 10 kΩ base pull-down | 0805 | UNI-ROYAL 0805W8F1002T5E | C17414 ✓ |
| D4 | Fan flyback (clamps the motor spike when Q4 opens), Schottky 3 A 40 V | SMA | MDD SS34 | C8678 ✓ |
| Q3 | N-MOSFET 60 V, logic level | SOT-23 | JSCJ 2N7002 | C8545 ✓ |
| R6 | 100 Ω gate | 0805 | UNI-ROYAL 0805W8F1000T5E | C17408 ✓ |
| R7 | 10 kΩ gate pull-down | 0805 | UNI-ROYAL 0805W8F1002T5E | C17414 ✓ |
| R8 | 10 kΩ tach pull-up to 3V3 | 0805 | UNI-ROYAL 0805W8F1002T5E | C17414 ✓ |
| R10 | 1 kΩ tach series | 0805 | UNI-ROYAL 0805W8F1001T5E | C17513 ✓ |
| C9 | 1 nF tach filter (optional, fit if RPM is noisy) | 0805 | YAGEO CC0805KRX7R9BB102 | C94121 ✓ |
| J2 | 4-pin fan header, right angle (v2 part, proven) | THT 2.54 mm | BOOMELE KF2510-4AGW high bend | C61409 |
| J3, J6 | 4-pin fan header, right angle (fans 2, 3) | THT 2.54 mm | BOOMELE KF2510-4AGW high bend | C61409 |
| LED2 | LED green | 0805 | KENTO KT-0805G | C2297 ✓ |
| R13 | 4.7 kΩ (about 2 mA at 12 V) | 0805 | UNI-ROYAL 0805W8F4701T5E | C17673 ✓ |

J2, J3, J6 pad mapping: copy v2 exactly (footprint CONN-TH_KF2510-4AGW): pad 1 PWM, pad 2 Tach (J2 only), pad 3 +12 V (`FAN_12V_SW`), pad 4 GND. This is the standard fan order counted from the other end of the footprint; v2 proves it matches real fan plugs. Do not renumber.
Silk: `FAN 1 (RPM)`, `FAN 2`, `FAN 3`. Fans 2 and 3 have no tach because parallel tach outputs overlap and give a meaningless count.

Q4 fan switch: Q2 on pulls `FANSW_DRV` low; R15/R14 divide 12 V so Vgs ≈ −12 × 10/11 = −10.9 V (Rds(on) < 14 mΩ at −10 V). Stays below the ±25 V gate limit up to about 27 V input, so no zener. Q2 off: R14 pulls the gate to the source, Q4 off. Q4 pins (SOIC-8): 1, 2, 3 S; 4 G; 5 to 8 D. Body diode points from `FAN_12V_SW` to `VIN_12V`, so it cannot feed the fans when Q4 is off. Firmware: on/off only, never PWM Q4.

### SENSORS
| Ref | Value | Package | Part | LCSC |
|---|---|---|---|---|
| J4, J5 | Pluggable terminal block 3-pin 3.81 mm, PCB header, right angle, closed | THT | KANGNEX WJ15EDGRC-3.81-03P-14-00A | C8406 ✓ |
| P4, P5 | Matching plug, screw, 16 to 28 AWG. **Qty 2 per board** (one per sensor) | cable side | KANGNEX WJ15EDGK-3.81-03P-14-00A | C8413 ✓ |
| R9, R11 | 4.7 kΩ OneWire pull-up, one per bus | 0805 | UNI-ROYAL 0805W8F4701T5E | C17673 ✓ |
| C8, C10 | 100 nF, one at each terminal | 0805 | YAGEO CC0805KRX7R9BB104 | C49678 ✓ |

J4 and J5 pinout: 1 GND, 2 DQ, 3 +3.3V. Silk per pin: `BLACK`, `YELLOW`, `RED` (standard DS18B20 probe colours), plus `GND D 3V3` small. Port label `PIPE SENSOR 1` / `PIPE SENSOR 2`. J4 and J5 are interchangeable: either sensor, either pipe.

P4 and P5 are not on the PCB, so they will not appear in the EasyEDA BOM export. Order them separately: 2 per board, plus spares.

## Nets per component

Reverse view of the net table, generated from it. If the two ever disagree, the net table wins.

| Ref | Pin → net |
|---|---|
| C1 | + → `VIN_12V`<br>− → `GND` |
| C2 | 1 → `VIN_12V`<br>2 → `GND` |
| C3 | 1 → `VIN_12V`<br>2 → `GND` |
| C4 | 1 → `BUCK_SW`<br>2 → `BUCK_BST` |
| C5 | 1 → `+5V`<br>2 → `GND` |
| C6 | 1 → `+5V`<br>2 → `GND` |
| C8 | 1 → `+3.3V`<br>2 → `GND` |
| C9 | 1 → `TACH_MCU`<br>2 → `GND` |
| C10 | 1 → `+3.3V`<br>2 → `GND` |
| D1 | A → `PFET_G`<br>K → `VIN_12V` |
| D4 | A → `GND`<br>K → `FAN_12V_SW` |
| F1 | 1 → `VIN_RAW`<br>2 → `VIN_F` |
| J1 | 1 (centre +) → `VIN_RAW`<br>2 → `GND`<br>3 → `GND` |
| J2 | 1 → `FAN_PWM`<br>2 → `FAN_TACH`<br>3 → `FAN_12V_SW`<br>4 → `GND` |
| J3 | 1 → `FAN_PWM`<br>2 → NC (tach)<br>3 → `FAN_12V_SW`<br>4 → `GND` |
| J4 | 1 → `GND`<br>2 → `ONEWIRE_1`<br>3 → `+3.3V` |
| J5 | 1 → `GND`<br>2 → `ONEWIRE_2`<br>3 → `+3.3V` |
| J6 | 1 → `FAN_PWM`<br>2 → NC (tach)<br>3 → `FAN_12V_SW`<br>4 → `GND` |
| J7 | 1 (+) → `VIN_RAW`<br>2 (−) → `GND` |
| L1 | 1 → `BUCK_SW`<br>2 → `+5V` |
| LED1 | A → `LED1_A`<br>K → `GND` |
| LED2 | A → `LED2_A`<br>K → `GND` |
| M1 | JP1.1 RST → NC<br>JP1.2 A0 → NC<br>JP1.3 D0 → NC<br>JP1.4 D5 (GPIO14) → `TACH_MCU`<br>JP1.5 D6 (GPIO12) → `PWM_MCU`<br>JP1.6 D7 (GPIO13) → `ONEWIRE_2`<br>JP1.7 D8 → NC<br>JP1.8 3V3 → `+3.3V`<br>JP2.1 TX → NC<br>JP2.2 RX → NC<br>JP2.3 D1 (GPIO5) → `ONEWIRE_1`<br>JP2.4 D2 (GPIO4) → `FANSW_EN`<br>JP2.5 D3 → NC<br>JP2.6 D4 (onboard LED) → NC<br>JP2.7 GND → `GND`<br>JP2.8 5V → `+5V` |
| Q1 | 1, 2, 3 (S) → `VIN_12V`<br>4 (G) → `PFET_G`<br>5, 6, 7, 8 (D) → `VIN_F` |
| Q2 | B → `FANSW_B`<br>C → `FANSW_DRV`<br>E → `GND` |
| Q3 | G → `PWM_GATE`<br>D → `FAN_PWM`<br>S → `GND` |
| Q4 | 1, 2, 3 (S) → `VIN_12V`<br>4 (G) → `FANSW_G`<br>5, 6, 7, 8 (D) → `FAN_12V_SW` |
| R1 | 1 → `PFET_G`<br>2 → `GND` |
| R4 | 1 → `FANSW_EN`<br>2 → `FANSW_B` |
| R5 | 1 → `FANSW_B`<br>2 → `GND` |
| R6 | 1 → `PWM_MCU`<br>2 → `PWM_GATE` |
| R7 | 1 → `PWM_GATE`<br>2 → `GND` |
| R8 | 1 → `+3.3V`<br>2 → `FAN_TACH` |
| R9 | 1 → `+3.3V`<br>2 → `ONEWIRE_1` |
| R10 | 1 → `FAN_TACH`<br>2 → `TACH_MCU` |
| R11 | 1 → `+3.3V`<br>2 → `ONEWIRE_2` |
| R12 | 1 → `+5V`<br>2 → `LED1_A` |
| R13 | 1 → `FAN_12V_SW`<br>2 → `LED2_A` |
| R14 | 1 → `VIN_12V`<br>2 → `FANSW_G` |
| R15 | 1 → `FANSW_G`<br>2 → `FANSW_DRV` |
| U1 | 1 FB → `+5V`<br>2 EN → `VIN_12V`<br>3 VIN → `VIN_12V`<br>4 GND → `GND`<br>5 SW → `BUCK_SW`<br>6 BST → `BUCK_BST` |

P4, P5 (plugs) are cable side and have no nets.

## Firmware impact (`DBEmain.yml`)

| Item | v2 | v3 |
|---|---|---|
| Fan power `switch` pin | D0 (relay) | **D2** (Q4 via Q2); on/off only, never PWM |
| PWM output | `pin: D6` | `pin: D6`, add `inverted: true` |
| PWM frequency | 1000 Hz | test 25 kHz (fan spec); fall back if ESP8266 PWM is unstable |
| OneWire | one bus on D1, sensors by address (`dallas_1_ID`, `dallas_2_ID`) | two buses: `ow_1` on D1, `ow_2` on D7; each `dallas_temp` uses `one_wire_id` + `index: 0`; drop the address substitutions from every `dbe-*.yaml` |
| Tach | D5 | D5 |
| Status LED | none | `status_led` on D4 (onboard LED, inverted) |

Firmware and hardware must change together: a v2 board with v3 firmware drives the wrong pin.

Jaga units: same firmware; set the tach multiplier for Arctic fans (2 pulses per revolution, as standard) and tune min/max speed per unit by ear. Add a `wifi_signal` sensor for the steel housing.

Boot behaviour: R7 holds Q3 off, so PWM floats high (100 %) until firmware runs. Q4 is held off (R5 keeps Q2 off, R14 holds the gate at the source), so the fans are unpowered at that point anyway.

## Layout notes (for later)

* Buck: C2/C3 right at U1 VIN and GND, SW node small, L1 next to U1, GND vias under C2, C3, C5, C6.
* Wide tracks or pour for `VIN_RAW`, `VIN_F`, `VIN_12V` (to Q4), `FAN_12V_SW` and `GND`.
* Bottom layer: GND pour.
* Q4 drain pins (5 to 8) on a wide `FAN_12V_SW` copper area; not needed for 0.12 W, but free.
* Keep the D1 mini antenna end over no copper, at the board edge (or overhanging it). Place the D1 mini so a D1 mini Pro u.FL pigtail can leave the enclosure at that edge.
* J1 and J7 on the same edge with **overlapping footprints**: the body of one covers the pads or body of the other, so only one can be fitted. Reason: with both fitted, J7 wired reversed while J1 is plugged in puts the two supplies in series, shorted through `VIN_RAW` and `GND`; F1 and Q1 are not in that loop. Courtyard overlap of J1/J7 is intentional: mark it as a DRC exception.
* Silk, plain words: `12V IN` (with centre + symbol at J1, `+` / `−` at J7), `FAN 1 (RPM)`, `FAN 2`, `FAN 3`, `PIPE SENSOR 1`, `PIPE SENSOR 2`, `POWER` and `FANS ON` at the LEDs. No reference designators next to connectors.
* Dev board marking (decision 18), bottom silk, clear of pads and vias: `DBE v3.0 DEVELOPMENT BOARD` (about 1.5 mm text) with `Not a finished consumer product. For development and evaluation only.` below it (about 1.0 mm).
* LEDs where they are visible through the enclosure (or plan light pipes).
* All connectors on one or two board edges, so cables leave the enclosure tidily.
* Layout: flat, nothing under the D1 mini (decided 2026-10-31). Board **67.5 × 56 mm** (placement done 2026-11-01). Mounting holes M2 (2.2 mm, unplated, 5 mm keep-out): (3.5, 17), (64, 3.5), (3.5, 52.5), (64, 52.5). Fan headers 2.5 mm apart. Cables leave around the bottom left corner: J1 and J4/J5 on the left edge, J7 and fan headers on the bottom edge. D1 mini antenna flush with the right edge, with a no-copper keep-out on both layers. The enclosure needs a new version.

## Open points

1. J1: the v2 project links a 0.5 A jack (DC-005-20A, C136744), but the boards were built with a 5 A jack. v3 uses a checked 5 A part (C381116). The 2.0 mm pin is the common pairing for 5.5 × 2.1 mm adapter plugs; test fit with your adapter.
2. F1 (RUEF400) is 19.3 mm tall plus leads; check enclosure height or bend it over (then keep a 14 × 20 mm area free beside it).
3. ~~K1 pinout~~ closed 2026-10-31: relay replaced by Q4 (decision 4).
4. Optional: TVS (SMBJ15A) on `VIN_12V` for hot plugging. Not included yet.
5. ~~Layout stacked or flat~~ closed 2026-10-31: flat, nothing under the D1 mini (easier to solder, probe and repair).
6. Reference number gaps (D2, D3, R2, R3, C7, K1) still open: renumber at annotation or leave.
7. ~~J7 part number~~ closed 2026-10-30: Kefa KF128-5.08-2P-AA (C474952).
8. WiFi inside the steel Jaga housing: test RSSI first with a spare D1 mini (ESPHome `wifi_signal`) at the controller spot, radiator closed. Above about −70 dBm fine; below about −80 dBm use a D1 mini Pro with external antenna, or mount the board outside the housing.
9. Jaga unit 1: check the PSU (model, ≥ 40 W, bare leads or barrel plug).
10. Jaga fan swap: confirm frame size, screw holes and airflow direction against the original ADDA fans before ordering.
