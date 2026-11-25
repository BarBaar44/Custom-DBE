# DBE v3 enclosure

Status: **draft**, 2026-11-03. Not printed yet. Positions from `PickAndPlace_PCB1_2026_11_03.csv`.

Source: [`../mechanical/dbe_v3_enclosure.scad`](../mechanical/dbe_v3_enclosure.scad). Two versions, one per power input. Print the one that matches the fitted connector; base and lid belong together.

| Power input | Base (upright) | Lid (top face down) |
|---|---|---|
| J1 barrel jack (DBE radiators) | [`DBE_v3_enclosure_J1_base.stl`](../mechanical/DBE_v3_enclosure_J1_base.stl) | [`DBE_v3_enclosure_J1_lid.stl`](../mechanical/DBE_v3_enclosure_J1_lid.stl) |
| J7 screw terminal (Jaga units, board 1) | [`DBE_v3_enclosure_J7_base.stl`](../mechanical/DBE_v3_enclosure_J7_base.stl) | [`DBE_v3_enclosure_J7_lid.stl`](../mechanical/DBE_v3_enclosure_J7_lid.stl) |

All in print orientation, no supports.

The .scad was rebuilt on 2026-11-25 from the STLs of 2026-11-03, because the original source was lost. The old STLs were the J1 version: the J1 base matches them exactly, the J1 lid differs by 0.23 mm³, all in the rounding of the engraved letters. The J7 values (bottom wall, centre x 18, 11 mm slot, 8 mm tall) come from the original source as quoted in the 3 Nov chat. Export with `openscad -o base.stl -D 'part="base_print"'` and `-D 'part="lid_print"'`, each with `-D 'power_in="J1"'` or `"J7"`; `assembly`, `exploded` and `plate` are for checking.

**Check before printing:** board 1 now carries a LOLIN S2 mini instead of a D1 mini. The enclosure was designed around a D1 mini on female headers; check the S2 mini stack height, USB position and antenna clearance against the lid first.

## Design

| Item | Value |
|---|---|
| Outer size | 71.7 × 60.2 × 21.8 mm |
| Walls, floor, lid | 1.6 mm; board to wall gap 0.5 mm |
| Lid | flush in a 0.8 mm rebate, 4 snap hooks (top ×2, left at y 16.5, right at y 6) in the mounting hole keep-out zones; release with a small screwdriver through the window |
| Board fix | no screws: pegs in the base through the M2 holes, lid columns press the board down (column at (64, 3.5) is 3.4 mm, because J6 is close) |
| Connector slots | open to the top so the board drops in; lid tabs close them 0.3 mm above each connector. J4/J5 share one slot, J2/J3/J6 share one slot |
| Power input | `power_in = "J1"`: 11 mm slot in the left wall, `12V IN` label along the left edge. `power_in = "J7"`: 11 mm slot in the bottom wall at x 18, joined with the fan slot (only 0.4 mm of wall would be left between them), `12V IN` label next to FAN 1. The other input's wall stays closed |
| Labels | engraved in the lid: 12V IN, S1 (J4), S2 (J5), FAN 1 + RPM, FAN 2, FAN 3, DBE v3 |
| Height budget | 14 mm above the board; set by the D1 mini on headers (about 12.7 mm) |
| Material | PETG or ASA; base upright, lid top face down, no supports |

## D1 mini socketed (requirement, 2026-11-21)

The D1 mini sits in 2 × 8 female headers, not soldered, so it stays easy to replace. The enclosure must support that:

* **Retention:** a socketed D1 mini can creep out from heat cycling or when plugging cables. Add a rib or pad on the lid that rests lightly on the D1 mini (on the PCB edge, away from the antenna and the reset button), about 0.3 mm interference or a small gap, so it cannot lift out of the headers.
* **Removal:** with the lid off, the D1 mini must come out straight up without removing the board. Keep nothing in the base or lid that overhangs it, and leave finger room on at least two sides (or room for a flat screwdriver to lever it out evenly).
* **Height:** keep the 14 mm budget based on standard female headers (8.5 mm) plus the D1 mini. Measure the real stack (headers + D1 mini + shield components) before printing.
* **D1 mini Pro fallback:** if a Pro with u.FL is fitted, the lid rib must clear the u.FL connector, and the pigtail needs a hole at the antenna edge.

## Open points

1. F1: bend it over towards +y, with the body about 9.5 to 12.5 mm above the board, over the J5 header. This only works if the J5 header is under about 9 mm. Upright F1 needs `top_clear = 20`, which makes the box 27.8 mm tall.
2. J1 opening appears to sit about 2.8 mm in from the board edge. Check that the adapter plug seats fully through the 11 mm slot.
3. Check part heights against the real parts: J1, J7 (8 mm assumed), J4/J5 with plugs, KF2510 headers, D1 mini on its headers.
4. S1/S2 labels assume J4 = PIPE SENSOR 1 and J5 = PIPE SENSOR 2; check against the silkscreen.
5. **Enclosure v2: LED windows** for LED1 (power, at 21.3, 44.9) and LED2 (fans on, at 65.7, 14.4). Dropped from v1 because no transparent filament is in stock. Options: clear 1.75 mm filament or 2 mm acrylic rod as light pipes, commercial round light pipes, or a natural PETG lid with thin spots over the LEDs.
6. USB on the D1 mini is only reachable with the lid off; updates go over OTA.
7. D1 mini retention rib and removal clearance: see the section above; not in the model yet.
8. Board model in the .scad is a plain plate with holes, no components; collision checks against connectors need the real part heights.
