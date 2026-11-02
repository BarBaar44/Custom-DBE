# DS18B20 pipe holder (cable tie mount)

Status: **test print**, 2026-11-02. Source: [`../mechanical/ds18b20_tie_holder.scad`](../mechanical/ds18b20_tie_holder.scad).

## Goal

Mount the two DS18B20 probes (J4/J5, `PIPE SENSOR 1/2`) on metal that carries the radiator water instead of on the MLCP pipe. One part for every radiator: Jaga units (one and two fin rows, different widths, upper and lower collectors shaped differently), DBE radiators, valve bodies and plain pipes.

## Decisions

1. **Water side, not between the fins.** There is no room between the fins, and a probe there measures fin temperature. Fin temperature drops when the fans run, which would make the fan control hunt.
2. **No snap clips per collector shape.** The collectors differ per radiator and between upper and lower, so every variant would need exact measurements and test prints.
3. **Universal holder with two cable ties.** The holder keeps the probe pressed on the metal and keeps the ties in place. Only the tie length changes per location.
4. **The probe tip must sit inside the holder.** The DS18B20 chip sits in the last few mm of the sleeve. The old MLCP clips left the tip sticking out into the air.

## Design

| Item | Value |
|---|---|
| Size | 34 × 13 × 9 mm |
| Probe | 6 mm stainless sleeve, 50 mm long, lies along the pipe |
| Probe channel | slides in from the cable end, closed at the tip end (1.6 mm end wall) |
| Probe protrudes under the holder | 0.8 mm, so the ties press the steel onto the metal and the plastic never touches the pipe |
| Tie tunnels | 2 closed tunnels across the top, above the probe, 5.2 × 1.8 mm (fits 4.8 mm and 3.6 mm ties), 8 mm from each end |
| Material | PETG or ASA. **Not PLA:** supply water reaches 60 to 75 °C |
| Print | flat top on the bed; the probe channel bridges about 6 mm |

Parameters to tune in the .scad: `clear` (probe fit, default 0.15), `protrude`, `tie_w`, `tie_h`.

The .scad has not been rendered in OpenSCAD yet; the test STL came from an identical Python model (manifold3d).

## Fitting

1. Find a straight stretch of at least 34 mm on the collector, pipe or valve body.
2. Put thermal paste on the probe and slide it in until the tip touches the end wall.
3. Fit two cable ties through the tunnels and around the pipe. Pull them firm, but not so hard that they dent the MLCP.
4. On collectors, check there is about 1.5 mm free behind them for the ties.
5. Optionally, put a third tie around the cable a few cm further along, so pulling on the cable doesn't move the probe.
6. Wrap pipe foam over the holder and the probe.
7. Compare the reading with a contact thermometer, then set the constant offset in ESPHome. If the difference changes with fan speed, the probe is not making good contact.

## Test checklist

* Probe fit: slides in, does not fall out.
* Contact: a small gap between the plastic and the pipe on both sides once the ties are tight.
* Readings: constant offset compared with a contact thermometer.

## Rejected alternatives

* Round snap clip with a probe channel (12, 15, 16, 22 mm): does not fit the rectangular Jaga collectors.
* Snap clip per collector shape (rounded rectangle, hooks round the back corners): too many variants.
* Probe square to the surface, tip contact only, with a sprung bridge: 52 mm tall, too bulky.
* Probe between the fins: no space, and it measures fin temperature.
