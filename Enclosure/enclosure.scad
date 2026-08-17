/*************************************************************************
  3D-Printable Enclosure — Dividing Head Controller (Arduino Nano version)
  STACKED / TALLER LAYOUT

  (Arduino Nano + interconnect PCB + SSD1306 OLED + KY-040 encoder +
  index button)

  This is the compact-footprint alternative to the wide side-by-side
  enclosure: the interconnect PCB (95x60mm, see pcb_laser_mask.svg /
  pcb_build_guide.md) mounts flat on the base floor, and the Nano
  mounts on card-edge rails on a raised shelf ABOVE it, so the box's
  footprint stays close to the PCB's own size instead of growing to
  fit both side by side. The trade is height: this box is taller
  (~110 x 76 x ~47mm assembled) than the wide version (~160 x 76 x ~34mm).

  STRUCTURE: two compartments stacked in the base.
    - Lower compartment: the interconnect PCB, standing on 4 short
      standoffs above the floor.
    - Upper compartment: a shelf plate spans the interior, supported
      by 4 corner posts that also double as the lid-fastening screw
      bosses (one printed feature does both jobs — see base() below).
      The Nano's card-edge rails sit on top of this shelf.
  The lid (OLED / encoder / index button) is unchanged in concept from
  the wide version, just resized to the new smaller footprint.

  Open this file in OpenSCAD (free, openscad.org) to preview and export
  STL for printing. It renders BASE and LID side by side for slicing.

  PRINT SETTINGS: PLA or PETG, 0.2mm layer height, 3 walls, 15% infill.
  The shelf spans the full interior unsupported at both long edges —
  print supports are recommended under the shelf on most slicers
  (support-from-buildplate-only, not everywhere), or verify your
  slicer bridges 40mm+ gaps cleanly before skipping them.

  >>> IMPORTANT: verify dimensions against your actual purchased parts
  >>> before printing, especially which USB connector your Nano clone
  >>> uses (Mini-B / Micro-B / USB-C differ in cutout size and shape).
*************************************************************************/

// ============= PARAMETERS (edit to match your parts) =============

// --- Overall box ---
box_w   = 110;   // external width  (left-right, front panel width)
box_d   = 76;    // external depth  (front-to-back)
wall    = 2.2;   // wall thickness
corner_r = 4;    // outside corner rounding radius

// --- Interconnect PCB (from pcb_laser_mask.svg / pcb_copper_reference.svg) ---
// 95 x 60mm board with 4 corner mounting holes at local (5,5), (90,5),
// (5,55), (90,55) — see pcb_build_guide.md.
pcb_w = 95;
pcb_h = 60;
pcb_offset_x = 9;   // where the PCB's local (0,0) corner sits in the base
pcb_offset_y = 9;
pcb_hole_dia = 3.2; // M3 clearance, matches the PCB's own mounting holes
pcb_standoff_od = 6.5;
pcb_standoff_h  = 4;    // clears solder joints/component leads on the underside
pcb_thickness   = 1.6;

// --- Shelf (supports the Nano above the PCB) ---
shelf_clearance_above_pcb = 9;   // headroom over the PCB's tallest components
shelf_z = wall + pcb_standoff_h + pcb_thickness + shelf_clearance_above_pcb;
shelf_thickness = 2.2;

// --- Corner posts: double as shelf supports AND lid-fastening bosses ---
post_od = 7;
post_pilot_d = 2.6;      // M3 self-tap pilot, only drilled near the top
post_pilot_depth = 12;   // how far down from the top the pilot hole runs
post_positions = [ [5,5], [box_w-5,5], [5,box_d-5], [box_w-5,box_d-5] ];

// --- Arduino Nano card-edge mount (on the shelf, above the PCB) ---
nano_len   = 45.0;
nano_wid   = 18.0;
nano_thick = 1.6;
rail_gap   = nano_thick + 0.6;
rail_h     = 4;                    // rail wall height above the shelf top
rail_len   = nano_len - 4;         // leave clearance at the USB end
nano_pos_x = box_w - wall - nano_len - 2;  // USB end lands near the right wall
nano_pos_y = (box_d - nano_wid) / 2;        // centered front-to-back

box_h_base = shelf_z + shelf_thickness + rail_h + rail_gap + 10;  // ~35mm
box_h_lid  = 14;

// --- Nano USB cutout, on the RIGHT wall (x = box_w) — the Nano's USB
// port faces along its length axis, not sideways, so the cutout must
// go on the wall the rail's open end points toward, not the rear wall.
// Mini-B: ~8x4mm; Micro-B: ~8x3mm; USB-C: ~9x3.2mm — check your board.
usb_cutout_w = 9;   // spans the Nano's width direction (Y)
usb_cutout_h = 4;   // spans vertically (Z)
usb_z_center = shelf_z + shelf_thickness + rail_h + rail_gap/2;

// --- OLED window & mount (0.96" SSD1306 — verify against your module) ---
oled_board_w   = 27.5;
oled_board_h   = 27.5;
oled_glass_w   = 24.0;
oled_glass_h   = 13.0;
oled_pos_x     = 25;
oled_pos_y     = 8;
// Mounting-hole spacing on the OLED PCB — MEASURE YOURS, varies a lot
// between suppliers; this is the #1 thing to check before printing.
oled_hole_dx     = 23.5;
oled_hole_dy     = 23.0;
oled_standoff_od = 4.5;
oled_standoff_id = 1.8;
oled_standoff_h  = 2.6;

// --- Rotary encoder ---
enc_hole_d   = 7.2;
enc_pos_x    = 65;
enc_pos_y    = 8;

// --- Index button ---
btn_hole_d   = 12.2;
btn_pos_x    = 90;
btn_pos_y    = -20;

// --- Cable pass-through to external driver box (in the lower/PCB
// compartment, since that's what it wires to) ---
cable_hole_d = 9;
cable_pos_x  = 0;     // relative to rear-wall center
cable_z      = 10;

$fn = 48;

// ============= MODULES =============

module rounded_box(w, d, h, r) {
  hull() {
    for (x = [r, w - r])
      for (y = [r, d - r])
        translate([x, y, 0])
          cylinder(h = h, r = r);
  }
}

module base() {
  difference() {
    rounded_box(box_w, box_d, box_h_base, corner_r);

    translate([wall, wall, wall])
      rounded_box(box_w - 2*wall, box_d - 2*wall, box_h_base, max(corner_r - wall, 0.1));

    // USB cutout on the right wall, aligned with the Nano's USB end
    translate([box_w - wall - 1, nano_pos_y + nano_wid/2 - usb_cutout_w/2, usb_z_center - usb_cutout_h/2])
      cube([wall + 2, usb_cutout_w, usb_cutout_h]);

    // cable pass-through to external driver box, lower compartment
    translate([box_w/2 + cable_pos_x, box_d - wall - 1, cable_z])
      rotate([-90,0,0])
        cylinder(h = wall + 2, d = cable_hole_d);
  }

  // PCB standoffs — lower compartment, on the base floor
  pcb_hole_positions = [
    [pcb_offset_x + 5,  pcb_offset_y + 5],
    [pcb_offset_x + 90, pcb_offset_y + 5],
    [pcb_offset_x + 5,  pcb_offset_y + 55],
    [pcb_offset_x + 90, pcb_offset_y + 55],
  ];
  for (p = pcb_hole_positions) {
    translate([p[0], p[1], wall])
      difference() {
        cylinder(h = pcb_standoff_h, d = pcb_standoff_od);
        cylinder(h = pcb_standoff_h + 1, d = pcb_hole_dia - 0.6);
      }
  }

  // Corner posts: solid from the floor to the top of the base — these
  // support the shelf partway up AND serve as the lid-fastening bosses
  // at the top, via a pilot hole cut only in the top segment of each.
  for (p = post_positions) {
    translate([p[0], p[1], wall])
      difference() {
        cylinder(h = box_h_base - wall, d = post_od);
        translate([0, 0, (box_h_base - wall) - post_pilot_depth])
          cylinder(h = post_pilot_depth + 1, d = post_pilot_d);
      }
  }

  // Shelf plate — spans the interior at shelf_z, supported by the
  // corner posts, with the Nano's rails printed on top of it
  translate([wall, wall, shelf_z])
    rounded_box(box_w - 2*wall, box_d - 2*wall, shelf_thickness, max(corner_r - wall, 0.1));

  // Nano card-edge rails, on top of the shelf
  translate([nano_pos_x, nano_pos_y, shelf_z + shelf_thickness]) {
    difference() {
      cube([rail_len, 3, rail_h + rail_gap]);
      translate([-0.5, 3 - 1.2, rail_h])
        cube([rail_len + 1, 1.2, rail_gap]);
    }
    translate([0, nano_wid - 3, 0])
      difference() {
        cube([rail_len, 3, rail_h + rail_gap]);
        translate([-0.5, 0, rail_h])
          cube([rail_len + 1, 1.2, rail_gap]);
      }
  }
}

module lid() {
  top_z1 = box_h_lid;
  top_z0 = box_h_lid - wall;
  recess_depth = 1.2;

  oled_cx = oled_pos_x;
  oled_cy = oled_pos_y + 18;

  difference() {
    rounded_box(box_w, box_d, box_h_lid, corner_r);

    translate([wall, wall, -1])
      rounded_box(box_w - 2*wall, box_d - 2*wall, top_z0 + 1, max(corner_r - wall, 0.1));

    translate([oled_cx - oled_glass_w/2, oled_cy - oled_glass_h/2, top_z0 - 1])
      cube([oled_glass_w, oled_glass_h, wall + 2]);

    translate([oled_cx - (oled_board_w+0.6)/2, oled_cy - (oled_board_h+0.6)/2, top_z0])
      cube([oled_board_w + 0.6, oled_board_h + 0.6, recess_depth]);

    translate([enc_pos_x, enc_pos_y + 18, -1])
      cylinder(h = box_h_lid + 2, d = enc_hole_d);

    translate([btn_pos_x, box_d + btn_pos_y, -1])
      cylinder(h = box_h_lid + 2, d = btn_hole_d);

    for (p = post_positions) {
      translate([p[0], p[1], -1])
        cylinder(h = box_h_lid + 2, d = 3.2);
    }
  }

  oled_hole_positions = [
    [oled_cx - oled_hole_dx/2, oled_cy - oled_hole_dy/2],
    [oled_cx + oled_hole_dx/2, oled_cy - oled_hole_dy/2],
    [oled_cx - oled_hole_dx/2, oled_cy + oled_hole_dy/2],
    [oled_cx + oled_hole_dx/2, oled_cy + oled_hole_dy/2],
  ];
  for (p = oled_hole_positions) {
    translate([p[0], p[1], top_z0 + recess_depth - oled_standoff_h])
      difference() {
        cylinder(h = oled_standoff_h, d = oled_standoff_od);
        translate([0, 0, -0.5])
          cylinder(h = oled_standoff_h + 1, d = oled_standoff_id);
      }
  }

  translate([wall + 0.3, wall + 0.3, -2.4])
    difference() {
      rounded_box(box_w - 2*wall - 0.6, box_d - 2*wall - 0.6, 2.3, 2);
      translate([wall, wall, -1])
        rounded_box(box_w - 4*wall - 0.6, box_d - 4*wall - 0.6, 4.3, 1);
    }
}

// ============= LAYOUT FOR PRINTING =============
base();
translate([box_w + 12, 0, 0])
  lid();
