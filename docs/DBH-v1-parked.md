# DBH v1: Jaga driver board, schematic spec

Status: **parked**, 2026-10-30. Both Jaga units are converted to Arctic PWM PST fans driven by DBE v3 ([`schematic-v3.md`](schematic-v3.md), decision 16). This board is the fallback if the fan swap does not work out: it keeps the original Jaga fans and driver boards and replaces only the Jaga controller.

## Goal (if revived)

* One board per radiator, replacing the Jaga controller (simplistic, no water temperature sensor on unit 2).
* Continuous fan speed from Home Assistant / ESPHome, same control logic as DBE.
* Covers both Jaga units.

## How the Jaga units work (both measured)

```
Mean Well PSU (bare leads) ──► Jaga controller red/black push-in terminals
Jaga controller fan header (JST PH 3-pin) ──► GS-D driver board ──► 2 fans
                                              └─ pass-through ──► next GS-D board ...
```

* Jaga controller board 15020036L9 on both units; 5 push-in terminals black, grey, yellow, red, black. Red/black = 12 V supply from the PSU. Grey = 0 to 10 V output that mirrors the fan speed signal.
* Fan header: JST PH, 2.0 mm pitch, 3-pin, wires black (GND), white (0 to 10 V speed), red (+12 V).
* GS-D driver boards: 2 channels each (one transistor and fuse per fan), 3-pin input plus 4-pin pass-through to the next board. They turn the 0 to 10 V signal into fan voltage.
* Fans are 2-wire ADDA (no tach, no PWM input).
* White 0 V = fans off.
* Other controller connections, not needed: RJ45 (control panel), grey/black 2-wire cable on a small red header (not a temperature sensor on unit 2), white and green 2-pin headers (about 5 V, empty, likely option ports), hex rotary mode switch, empty barrel jack.

### Unit 1
* Controller DPC.MD45, 12 V DC, FW 2.8. Manual, 3 fixed speeds.
* Fan tray 37605.010104, 12 V DC. 20 × ADDA AD0912MB-A70GL (92 mm, 12 V, 0.17 A): about 3.4 A at full voltage.
* Speed signal at grey terminal (mirrors white): off 0 V, 1 = 5.9 V, 2 = 6.7 V, 3 = 9.3 V DC, clean DC.
* PSU: to check.

### Unit 2
* Radiator Jaga Vertiga 053, 230 V AC in, 30 W max, 31-8-2023.
* Controller DPC.VE45, 12 V DC, 30 W, FW 3.3, 31-8-2023. No water temperature sensor.
* PSU Mean Well NPF-40-12: 12 V 3.34 A, 40 W, IP67, bare output leads.
* 2 × GS-D boards, 4 × ADDA AD1212MB-A71GL (120 mm, 12 V, 0.33 A): about 1.4 A.
* Speed signal on white at the JST: low 5.8 V, mid 7.0 V, high 9.0 V DC.

Both units: 12 V only, same 0 to 10 V scale.

## Concept

Copy from [`schematic-v3.md`](schematic-v3.md): POWER (with J7 screw terminal input for the bare PSU leads; reverse polarity FET matters here), MCU (D1 mini, or D1 mini Pro for the steel housing), SENSORS (J4/J5 DS18B20 on D1 and D7), STATUS (LED1).

```
PSU bare leads ──► screw terminal ──► fuse, reverse polarity ──► VIN 12 V ──► buck 5 V ──► D1 mini
VIN 12 V ──────────────────────────────────────────► J8 pin 3 (red, +12 V)
D8 PWM ──► RC filter ×2 ──► LM358, gain 3 ──► 100 Ω ──► J8 pin 2 (white, 0 to 9.9 V)
GND ───────────────────────────────────────────────► J8 pin 1 (black)
DS18B20 ×2 on J4 (D1), J5 (D7)
```

(Fan connector named J8 here, because DBE v3 uses J7 for the screw terminal.)

### Speed output
ESP PWM 3.3 V on D8 → R 10 kΩ → C 1 µF → R 10 kΩ → C 1 µF → LM358 IN+ (pin 3). Feedback 20 kΩ (out to IN−), 10 kΩ (IN− to GND): gain 3, 0 to 9.9 V. 100 Ω series output resistor. Unused half B: IN+ to GND, IN− to OUT. LM358 supply from VIN, 100 nF at pin 8.
* Filter: two stages at about 16 Hz; ripple far below 10 mV at 1 kHz PWM.
* D8 has a pull-down on the D1 mini: output 0 V at boot, so fans off.

Parts already checked: LM358DR2G C7950, 10 kΩ C17414, 1 µF 50 V C28323, 20 kΩ C4328, 100 Ω C17408, 100 nF C49678.

### Fan switch
Not needed: 0 V on white stops the fans, and D8 holds 0 V at boot. Optional DNP footprint for a P-FET high side switch on J8 pin 3 if a hard off is wanted.

### J8 fan connector
JST PH 3-pin, 2.0 mm (B3B-PH-K-S top entry or S3B-PH-K-S side entry): 1 GND (black), 2 0 to 10 V (white), 3 +12 V (red). The Jaga plug goes straight in. First board: power up without the fan cable and confirm 12 V on the pad that red lands on, to rule out a mirrored footprint.

### Firmware
`esp8266_pwm` on D8, 1 kHz, not inverted. Jaga's own speeds: about 58 to 60 / 67 to 70 / 90 to 93 % duty. Cap max at about 90 % at first. Find the minimum start voltage by test.

## Wiring at the radiator

Remove the Jaga controller (keep it). PSU leads into the screw terminal. Jaga fan plug into J8. Own DS18B20 sensors on the pipes into J4/J5. Control panel and other Jaga cables unused.

## Open points (only if revived)

1. Unit 1 PSU: model, wattage (20 ADDA fans draw about 3.4 A at 12 V; Jaga runs them at most about 9.3 V).
2. Fan minimum start voltage.
3. WiFi in the steel housing (see DBE v3 open point 8).
4. Board size and enclosure.
