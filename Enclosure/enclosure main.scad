// ============================================================
// MAIN BOARD ENCLOSURE
// Houses: the main PCB (Nano soldered directly to it, driver header,
// power-in header, pendant header), plus the buck converter and
// DRV8825 stepper driver modules mounted in a side bay. Powered
// through a panel-mount Anderson Powerpole pair. Separate wall
// openings for the pendant cable and the stepper motor leads.
// ============================================================

// ============= PARAMETERS (edit to match your parts) =============

wall = 2.5;
corner_r = 4;

// --- Main PCB (from main_copper_reference.svg / pcb_build_guide.md) ---
// 108 x 68mm board, 4 corner mounting holes at local (5,5), (103,5),
// (5,63), (103,63).
pcb_w = 108;
pcb_d = 68;
pcb_margin = 8;
pcb_hole_dia = 3.2;
pcb_standoff_od = 6;
pcb_standoff_h = 4;

box_w_pcb_section = pcb_w + 2*pcb_margin;   // width of just the PCB half of the box
box_d = pcb_d + 2*pcb_margin;
pcb_offset_x = pcb_margin;
pcb_offset_y = pcb_margin;

// --- Component bay: buck converter + DRV8825, beside the PCB ---
// Both are adhesive/hot-glue mounted onto a shallow printed placement
// outline rather than screw standoffs, since hole spacing on these
// cheap breakout modules varies a lot between suppliers — measure
// yours if you'd rather drill matching standoff holes instead.
bay_w = 70;
buck_w = 45; buck_h = 23; buck_outline_depth = 0.6;
buck_x0 = box_w_pcb_section + 10;
buck_y0 = 8;
drv_w = 22; drv_h = 16;
drv_x0 = box_w_pcb_section + 10 + (buck_w - drv_w)/2;
drv_y0 = buck_y0 + buck_h + 12;

box_w = box_w_pcb_section + bay_w;   // overall box width

box_h_base = 22;    // clears the buck converter's ~14mm height, and also the
                     // Nano sitting on female header sockets (~13mm stack:
                     // 8.5mm socket + Nano PCB + tallest topside component)
box_h_lid  = 4;

// --- Corner posts ---
post_inset = 7;      // kept clear of the PCB standoffs (~8.5mm away)
post_od = 6;
post_pilot_d = 2.6;
post_pilot_depth = 8;
post_positions = [
  [post_inset, post_inset],
  [box_w - post_inset, post_inset],
  [post_inset, box_d - post_inset],
  [box_w - post_inset, box_d - post_inset],
];

// --- Nano USB cutout, back wall (y = 0) ---
// The Nano's footprint on the PCB spans local x=25..40.24. MEASURE
// YOUR CLONE — USB position/orientation varies by supplier.
// Height assumes the Nano sits on female header sockets (see
// pcb_build_guide.md), which raise it well above the main PCB
// surface — 8.5mm socket + Nano PCB thickness + roughly half the USB
// connector's own height. If you're soldering a bare Nano flat to the
// board instead, lower usb_z_center to about wall + pcb_standoff_h + 3.
usb_cutout_w = 10;
usb_cutout_h = 4;
usb_center_x = pcb_offset_x + (25 + 40.24)/2;
usb_z_center = wall + pcb_standoff_h + 8.5 + 1.6 + 1.5;

// --- Pendant cable exit, front wall (y = box_d), under the pendant header ---
pend_slot_w = 9;
pend_slot_h = 6;
pend_slot_z = wall + pcb_standoff_h + 2;
pend_slot_x = pcb_offset_x + 80;   // pendant header's board-local x

// --- Anderson Powerpole panel cutout (input power), far wall (x = box_w) ---
// Sized for a standard 2-pole gang, red+black housings dovetailed and
// stacked vertically (the usual PP15/30/45 convention) — roughly
// 16mm wide x 17mm tall x 20mm deep. Cut a bit generous and
// friction-fit the housing, or add a dab of hot glue; the printed lip
// on 3 sides gives it something to grip against. File/sand to fit
// your specific housing.
pp_w = 16;    // width of the opening, along the wall (y-axis)
pp_h = 15;    // height of the opening, vertical (z-axis)
pp_cy = buck_y0 + buck_h/2;   // centered on the buck converter, along the wall's y-axis
pp_z  = wall + 1;
pp_lip = 1.2;

// --- Stepper motor wire exit, far wall (x = box_w), below the Powerpole cutout ---
motor_hole_d = 9;
motor_cy = drv_y0 + drv_h/2;
motor_z  = wall + 8;

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

    translate([usb_center_x - usb_cutout_w/2, -1, usb_z_center - usb_cutout_h/2])
      cube([usb_cutout_w, wall + 2, usb_cutout_h]);

    translate([pend_slot_x - pend_slot_w/2, box_d - wall - 1, pend_slot_z])
      cube([pend_slot_w, wall + 2, pend_slot_h]);

    translate([box_w - wall - 1, pp_cy - pp_h/2 + pp_lip, pp_z])
      cube([wall + 2, pp_w, pp_h - pp_lip]);

    translate([box_w - wall - 1, motor_cy, motor_z])
      rotate([0,90,0])
        cylinder(h = wall + 2, d = motor_hole_d);
  }

  // PCB standoffs, matched to the board's own verified-clear corner holes
  pcb_hole_positions = [
    [pcb_offset_x + 5,   pcb_offset_y + 5],
    [pcb_offset_x + 103, pcb_offset_y + 5],
    [pcb_offset_x + 5,   pcb_offset_y + 63],
    [pcb_offset_x + 103, pcb_offset_y + 63],
  ];
  for (p = pcb_hole_positions) {
    translate([p[0], p[1], wall])
      difference() {
        cylinder(h = pcb_standoff_h, d = pcb_standoff_od);
        cylinder(h = pcb_standoff_h + 1, d = pcb_hole_dia - 0.6);
      }
  }

  // Corner posts
  for (p = post_positions) {
    translate([p[0], p[1], wall])
      difference() {
        cylinder(h = box_h_base - wall, d = post_od);
        translate([0, 0, (box_h_base - wall) - post_pilot_depth])
          cylinder(h = post_pilot_depth + 1, d = post_pilot_d);
      }
  }

  // Buck converter placement outline — a shallow raised border so the
  // module sits in a known, repeatable spot before gluing it down
  translate([buck_x0, buck_y0, wall])
    difference() {
      cube([buck_w, buck_h, buck_outline_depth]);
      translate([1.5, 1.5, -0.5])
        cube([buck_w - 3, buck_h - 3, buck_outline_depth + 1]);
    }

  // DRV8825 placement outline, same approach
  translate([drv_x0, drv_y0, wall])
    difference() {
      cube([drv_w, drv_h, buck_outline_depth]);
      translate([1.5, 1.5, -0.5])
        cube([drv_w - 3, drv_h - 3, buck_outline_depth + 1]);
    }
}

module lid() {
  difference() {
    rounded_box(box_w, box_d, box_h_lid, corner_r);
    translate([wall, wall, -1])
      rounded_box(box_w - 2*wall, box_d - 2*wall, box_h_lid + 2, max(corner_r - wall, 0.1));
    for (p = post_positions) {
      translate([p[0], p[1], -1])
        cylinder(h = box_h_lid + 2, d = 3.2);
    }
  }
  translate([wall + 0.3, wall + 0.3, -2.2])
    difference() {
      rounded_box(box_w - 2*wall - 0.6, box_d - 2*wall - 0.6, 2.1, 2);
      translate([wall, wall, -1])
        rounded_box(box_w - 4*wall - 0.6, box_d - 4*wall - 0.6, 4.1, 1);
    }
}

// ============= LAYOUT FOR PRINTING =============
base();
translate([0, box_d + 12, 0])
  lid();
