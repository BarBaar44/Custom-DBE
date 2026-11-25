// DBE v3 snap fit enclosure
// Rebuilt 2026-11-25 from the printed STLs of 2026-11-03 (the original .scad was lost).
// Board coordinates: origin at the board's lower left corner, top view, mm.
// Positions follow PickAndPlace_PCB1_2026_11_03.csv. No LED windows (planned for enclosure v2).
//
// power_in = "J1" (barrel jack, left wall) or "J7" (screw terminal, bottom wall): only that input gets a slot.
// part = "assembly" | "exploded" | "base" | "lid" | "base_print" | "lid_print" | "plate" | "board"
//   base_print, lid_print: print orientation (base upright, lid top face down), export these as STL.

part = "assembly";
power_in = "J7";    // "J1" or "J7": which power input is fitted on this board

/* [Board] */
board_w   = 67.5;
board_d   = 56.0;
board_t   = 1.6;
holes     = [[3.5, 17], [3.5, 52.5], [64, 52.5], [64, 3.5]];   // M2 mounting holes

/* [Shell] */
wall      = 1.6;
floor_t   = 1.6;
lid_t     = 1.6;
gap       = 0.5;    // board edge to inner wall
r_out     = 2.5;    // outer corner radius
standoff_h = 3.0;   // floor to board underside
f1_height = 19.3;   // F1 Littelfuse RUEF400 (C2760163), straight leads: body height B max 19.3 mm (datasheet table, A 14.0 / E 3.0 max)
f1_margin = 0.7;    // air between F1 and the lid
top_clear = max(14.0, f1_height + f1_margin);   // board top to lid underside; 14 covers the D1 mini on headers
rebate_w  = 0.8;    // lid sits flush in this rebate
lid_clear = 0.15;   // lid to rebate, arm to wall

/* [Board fixing] */
standoff_d = 5.5;
peg_d      = 1.9;   // through the M2 holes
peg_len    = 1.39;  // above the standoff, stays just under the board top
column_d   = 4.5;   // lid columns press the board down
column_d_small = 3.4;
small_column = [64, 3.5];   // next to J6, so this one is thinner

/* [Connector slots] open to the top, closed by lid tabs above the connector
   [ref, wall, centre along the wall, slot width, connector height above the board]
   wall: "left" (x = 0 side) or "front" (y = 0 side). Heights are datasheet estimates. */
connectors = [
  ["J1",   "left",   6.5,  11.0, 11.8],   // DC barrel jack, plug from the left
  ["J4J5", "left",  35.47, 29.2, 12.4],   // J4 (y 43) + J5 (y 27.94), one slot
  ["J7",   "front", 18.0,  11.0,  8.0],   // 2-pin screw terminal, wires from below
  ["FAN",  "front", 43.3,  38.8,  7.4]    // J2, J3, J6 fan headers, one slot
];
tab_gap   = 0.3;    // lid tab underside above the connector
merge_web = 2.0;    // slots closer than this on the same wall are joined (no thin wall left)
tab_clear  = 0.2;   // tab to slot end
tab_inset  = 0.1;   // tab outer face behind the outer wall face

function used(c) = (c[0] == "J1" || c[0] == "J7") ? c[0] == power_in : true;
// [wall, from, to, tab_bottom_z]
slots = [for (c = connectors) if (used(c))
          [c[1], c[2] - c[3]/2, c[2] + c[3]/2, floor_t + standoff_h + board_t + c[4] + tab_gap]];
// neighbour on the same wall within merge_web: returns the gap edge, or undef
function next_edge(s) = let(n = [for (t = slots) if (t[0] == s[0] && t[1] >= s[2] && t[1] - s[2] < merge_web) t[1]]) len(n) ? n[0] : undef;
function prev_edge(s) = let(n = [for (t = slots) if (t[0] == s[0] && t[2] <= s[1] && s[1] - t[2] < merge_web) t[2]]) len(n) ? n[0] : undef;

/* [Snap hooks] [wall, position along the wall] */
hooks = [["left", 16.5], ["right", 6], ["back", 7], ["back", 60.5]];
hook_w      = 5.0;
hook_t      = 1.2;
hook_len    = 8.0;    // arm length below the lid
barb        = 0.9;    // how far the barb sticks out
barb_h      = 2.2;    // ramp height, barb top at hook_bottom + barb_h
win_w       = 5.6;    // window in the wall
win_below   = 0.4;    // window starts this far below the arm tip
win_above   = 0.1;    // and ends this far above the barb

/* [Labels] engraved in the lid top: [text, x, y, size, rotation] */
labels = [
  ["S2",     -0.96, 27.94, 2.6, -90],
  ["S1",     -0.96, 43.0,  2.6, -90],
  ["FAN 1",  30.73,  1.5,  2.6,   0],
  ["RPM",    30.73,  5.5,  2.08,  0],
  ["FAN 2",  43.31,  1.5,  2.6,   0],
  ["FAN 3",  55.88,  1.54, 2.6,   0],
  ["DBE v3", 50.5,  31.5,  6.0,   0]
];
power_label = power_in == "J1" ? ["12V IN", -0.96, 6.5, 2.6, -90] : ["12V IN", 18.0, 1.5, 2.6, 0];
label_font  = "Liberation Sans:style=Bold";
label_depth = 0.5;

$fn = 48;

// ---------- derived ----------
IX0 = -gap;            IY0 = -gap;                 // inner cavity
IX1 = board_w + gap;   IY1 = board_d + gap;
OX0 = IX0 - wall;      OY0 = IY0 - wall;           // outer
OX1 = IX1 + wall;      OY1 = IY1 + wall;
r_in  = r_out - wall;
z_board = floor_t + standoff_h;                    // board underside
z_btop  = z_board + board_t;                       // board top
z_lid   = z_btop + top_clear;                      // lid underside
z_top   = z_lid + lid_t;                           // outer top
hook_bottom = z_lid - hook_len;                    // z of the arm tip
win_z   = [hook_bottom - win_below, hook_bottom + barb_h + win_above];
eps = 0.01;

module rrect(x0, y0, x1, y1, r) {
  translate([x0, y0]) offset(r = r) offset(delta = -r) square([x1 - x0, y1 - y0]);
}

// box through a wall: along-wall span [u0, u1], z span [z0, z1], extra depth d each side
module wall_cut(w, u0, u1, z0, z1, d = 1) {
  if (w == "left")  translate([OX0 - d, u0, z0]) cube([wall + 2*d, u1 - u0, z1 - z0]);
  if (w == "right") translate([IX1 - d, u0, z0]) cube([wall + 2*d, u1 - u0, z1 - z0]);
  if (w == "front") translate([u0, OY0 - d, z0]) cube([u1 - u0, wall + 2*d, z1 - z0]);
  if (w == "back")  translate([u0, IY1 - d, z0]) cube([u1 - u0, wall + 2*d, z1 - z0]);
}

// ---------- base ----------
module base() {
  difference() {
    linear_extrude(z_top) rrect(OX0, OY0, OX1, OY1, r_out);
    translate([0, 0, floor_t]) linear_extrude(z_top) rrect(IX0, IY0, IX1, IY1, r_in);
    // rebate for the lid
    translate([0, 0, z_lid]) linear_extrude(z_top)
      rrect(IX0 - rebate_w, IY0 - rebate_w, IX1 + rebate_w, IY1 + rebate_w, r_out - (wall - rebate_w));
    // connector slots, open to the top
    for (s = slots) {
      wall_cut(s[0], s[1], s[2], z_btop, z_top + 1);
      ne = next_edge(s);
      if (!is_undef(ne)) wall_cut(s[0], s[2] - eps, ne + eps, z_btop, z_top + 1);   // join close slots
    }
    // snap windows
    for (h = hooks) wall_cut(h[0], h[1] - win_w/2, h[1] + win_w/2, win_z[0], win_z[1]);
  }
  // standoffs and pegs
  for (p = holes) translate([p[0], p[1], floor_t - eps]) {
    cylinder(d = standoff_d, h = standoff_h + eps);
    cylinder(d = peg_d, h = standoff_h + peg_len + eps);
  }
}

// ---------- lid (assembled position) ----------
module hook(w, u) {
  // arm on the inside of the wall, barb points outwards into the window
  zl = z_lid - hook_bottom;
  if (w == "left")  translate([IX0 + lid_clear, u, hook_bottom]) hook_shape(zl, -1, "y");
  if (w == "right") translate([IX1 - lid_clear, u, hook_bottom]) hook_shape(zl,  1, "y");
  if (w == "back")  translate([u, IY1 - lid_clear, hook_bottom]) hook_shape(zl,  1, "x");
  if (w == "front") translate([u, IY0 + lid_clear, hook_bottom]) hook_shape(zl, -1, "x");
}
// local: origin on the arm's outer face at the tip, s = outward direction (+1/-1), along = wall direction
module hook_shape(len, s, along) {
  prof = [[0, 0], [s*barb, barb_h], [0, barb_h]];          // barb, in (out, z)
  arm  = [[0, 0], [-s*hook_t, 0], [-s*hook_t, len + eps], [0, len + eps]];
  // extrude the profile along the wall
  if (along == "y")
    translate([0, hook_w/2, 0]) rotate([90, 0, 0]) linear_extrude(hook_w) { polygon(prof); polygon(arm); }
  else
    translate([-hook_w/2, 0, 0]) rotate([90, 0, 90]) linear_extrude(hook_w) { polygon(prof); polygon(arm); }
}

module label_2d(l) {
  translate([l[1], l[2]]) rotate(l[4])
    text(l[0], size = l[3], font = label_font, halign = "center", valign = "baseline");
}

module lid() {
  difference() {
    union() {
      translate([0, 0, z_lid]) linear_extrude(lid_t)
        rrect(IX0 - rebate_w + lid_clear, IY0 - rebate_w + lid_clear,
              IX1 + rebate_w - lid_clear, IY1 + rebate_w - lid_clear, r_out - (wall - rebate_w) - lid_clear);
      // tabs that close the slots above the connectors
      for (s = slots) {
        // tab ends: clearance at a free slot end, half way into the gap at a joined end
        pe = prev_edge(s);  ne = next_edge(s);
        a = is_undef(pe) ? s[1] + tab_clear : (pe + s[1]) / 2;
        b = is_undef(ne) ? s[2] - tab_clear : (s[2] + ne) / 2;
        if (s[0] == "left")
          translate([OX0 + tab_inset, a, s[3]]) cube([wall - tab_inset, b - a, z_top - s[3]]);
        if (s[0] == "front")
          translate([a, OY0 + tab_inset, s[3]]) cube([b - a, wall - tab_inset, z_top - s[3]]);
      }
      // columns that press the board down
      for (p = holes) translate([p[0], p[1], z_btop])
        cylinder(d = (p == small_column) ? column_d_small : column_d, h = top_clear + eps);
      for (h = hooks) hook(h[0], h[1]);
    }
    translate([0, 0, z_top - label_depth]) linear_extrude(label_depth + 1) for (l = concat([power_label], labels)) label_2d(l);
  }
}

module board() {
  color("green") translate([0, 0, z_board]) difference() {
    cube([board_w, board_d, board_t]);
    for (p = holes) translate([p[0], p[1], -1]) cylinder(d = 2.2, h = board_t + 2);
  }
}

// ---------- output ----------
if (part == "assembly")   { base(); lid(); board(); }
if (part == "exploded")   { base(); translate([0, 0, 25]) lid(); board(); }
if (part == "base")       base();
if (part == "lid")        lid();
if (part == "board")      board();
if (part == "base_print") base();                                         // upright, on the plate
if (part == "lid_print")  translate([0, 0, z_top]) rotate([180, 0, 0]) lid();   // top face down (rotated, not mirrored)
if (part == "plate")      { base(); translate([OX1 - OX0 + 8, 0, 0]) translate([0, 0, z_top]) rotate([180, 0, 0]) lid(); }
