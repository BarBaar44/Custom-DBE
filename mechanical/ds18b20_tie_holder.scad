// DS18B20 pipe holder, cable tie mount. See docs/ds18b20-pipe-holder.md
// Print in PETG or ASA (not PLA: supply water reaches 60 to 75 °C), flat top on the bed.

probe_d   = 6.0;   // measure your probe sleeve
length    = 34;    // holder length (probe is 50 mm)
width     = 13;
protrude  = 0.8;   // how far the probe sticks out under the holder
end_wall  = 1.6;   // tip stop
tie_w     = 5.2;   // fits 4.8 mm ties (and 3.6 mm)
tie_h     = 1.8;   // tunnel height, tie thickness about 1.2 mm
roof      = 1.2;
tie_inset = 8;     // tunnel centre from each end
clear     = 0.15;

$fn = 64;
pr    = probe_d/2;
z_tun = probe_d + 0.6;
z_top = z_tun + tie_h + roof;

module rr(w, h, r) hull() for (sx=[-1,1], sy=[-1,1]) translate([sx*(w/2-r), sy*(h/2-r)]) circle(r);

difference() {
  hull() {
    translate([length/2, 0, protrude]) linear_extrude(0.01) rr(length, width, 2.5);
    translate([length/2, 0, z_top-2])  linear_extrude(0.01) rr(length, width, 2.5);
    translate([length/2, 0, z_top-0.01]) linear_extrude(0.01) rr(length-2, width-3, 2.0);
  }
  translate([end_wall, 0, pr]) rotate([0, 90, 0]) cylinder(r = pr + clear, h = length);
  translate([end_wall, -2, -1]) cube([length, 4, protrude + 1]);
  for (x = [tie_inset, length - tie_inset])
    translate([x - tie_w/2, -width/2 - 1, z_tun]) cube([tie_w, width + 2, tie_h]);
}
