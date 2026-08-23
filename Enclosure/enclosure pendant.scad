// ============================================================
// PENDANT ENCLOSURE
// Houses the pendant PCB, OLED display, rotary encoder, and index
// button. Connects to the main board enclosure via an 8-conductor
// cable entering through the back wall.
// ============================================================

// ============= PARAMETERS (edit to match your parts) =============

wall = 2.5;
corner_r = 4;

// --- Pendant PCB (from pendant_copper_reference.svg / pcb_build_guide.md) ---
// 45 x 46mm board, 4 corner mounting holes at local (4,2), (41,2),
// (4,44), (41,44).
pcb_w = 45;
pcb_d = 46;
pcb_margin = 9;
pcb_hole_dia = 3.2;
pcb_standoff_od = 6;
pcb_standoff_h = 4;

box_w = pcb_w + 2*pcb_margin;   // 63
box_d = pcb_d + 2*pcb_margin;   // 64
pcb_offset_x = pcb_margin;
pcb_offset_y = pcb_margin;

box_h_base = pcb_standoff_h + wall + 12;
box_h_lid  = 6;    // taller lid: OLED window + encoder/button bosses live here

post_inset = 6;    // kept clear of the PCB standoffs (~8.6mm away)
post_od = 6;
post_pilot_d = 2.6;
post_pilot_depth = 8;
post_positions = [
  [post_inset, post_inset],
  [box_w - post_inset, post_inset],
  [post_inset, box_d - post_inset],
  [box_w - post_inset, box_d - post_inset],
];

// --- OLED (0.96" SSD1306 — MEASURE YOUR MODULE, this varies by supplier) ---
oled_glass_w = 27;
oled_glass_h = 12;
oled_board_w = 27.3;
oled_board_h = 27.8; // many 0.96" modules are taller than the glass (mounting ears)
oled_hole_dx = 23.5;
oled_hole_dy = 23.5;
oled_standoff_od = 4.5;
oled_standoff_id = 1.8;   // pilot for M2 self-tapper
oled_standoff_h = 3;
oled_cx = box_w/2;
oled_cy = 17.5;

// --- Rotary encoder (e.g. KY-040) ---
enc_hole_d = 7.2;    // shaft bushing clearance — check your encoder's thread
enc_cx = box_w/2 - 12;
enc_cy = 48;

// --- Index button ---
btn_hole_d = 6.2;
btn_cx = box_w/2 + 12;
btn_cy = 48;

// --- Incoming 8-conductor cable, back wall ---
cable_hole_d = 6;
cable_cx = box_w/2;
cable_z = wall + pcb_standoff_h + 5;

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

    // incoming cable, back wall (y = 0)
    translate([cable_cx, -1, cable_z])
      rotate([-90,0,0])
        cylinder(h = wall + 2, d = cable_hole_d);
  }

  pcb_hole_positions = [
    [pcb_offset_x + 4,  pcb_offset_y + 2],
    [pcb_offset_x + 41, pcb_offset_y + 2],
    [pcb_offset_x + 4,  pcb_offset_y + 44],
    [pcb_offset_x + 41, pcb_offset_y + 44],
  ];
  for (p = pcb_hole_positions) {
    translate([p[0], p[1], wall])
      difference() {
        cylinder(h = pcb_standoff_h, d = pcb_standoff_od);
        cylinder(h = pcb_standoff_h + 1, d = pcb_hole_dia - 0.6);
      }
  }

  for (p = post_positions) {
    translate([p[0], p[1], wall])
      difference() {
        cylinder(h = box_h_base - wall, d = post_od);
        translate([0, 0, (box_h_base - wall) - post_pilot_depth])
          cylinder(h = post_pilot_depth + 1, d = post_pilot_d);
      }
  }
}

module lid() {
  top_z1 = box_h_lid;
  top_z0 = box_h_lid - wall;
  recess_depth = 1.2;

  difference() {
    rounded_box(box_w, box_d, box_h_lid, corner_r);

    translate([wall, wall, -1])
      rounded_box(box_w - 2*wall, box_d - 2*wall, top_z0 + 1, max(corner_r - wall, 0.1));

    translate([oled_cx - oled_glass_w/2, oled_cy - oled_glass_h/2, top_z0 - 1])
      cube([oled_glass_w, oled_glass_h, wall + 2]);

    translate([oled_cx - (oled_board_w+0.6)/2, oled_cy - (oled_board_h+0.6)/2, top_z0])
      cube([oled_board_w + 0.6, oled_board_h + 0.6, recess_depth]);

    translate([enc_cx, enc_cy, -1])
      cylinder(h = box_h_lid + 2, d = enc_hole_d);

    translate([btn_cx, btn_cy, -1])
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

  translate([wall + 0.3, wall + 0.3, -2.2])
    difference() {
      rounded_box(box_w - 2*wall - 0.6, box_d - 2*wall - 0.6, 2.1, 2);
      translate([wall, wall, -1])
        rounded_box(box_w - 4*wall - 0.6, box_d - 4*wall - 0.6, 4.1, 1);
    }
}

// ============= LAYOUT FOR PRINTING =============
base();
translate([box_w + 12, 0, 0])
  lid();
