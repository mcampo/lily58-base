$fn = $preview ? 30 : 100;

/* [3D printing params] */
// Clearance to adjust for dimensional inaccuracy of 3D printers. Used for holes or simlar geometry.
clearance = 0.2;

/* [Model Params] */
// Angle at which the keyboard is elevated
typing_angle = 7;
// Thickness of the base that is in contact with the bottom PCB. Make it a multiple of your printing layer height.
base_thickness = 0.9;
// Height of the feet (usually silicon). Set this value to 0 if you will not use feet.
feet_height = 1;
// Diameter of the feet.
feet_diameter = 12 + clearance * 2;
// Height of the exposed part of the feet
feet_exposure = 0.4;
// Widht of the outer wall of the legs that create a "pocket" for the feet to fit in.
leg_outer_wall_width = 0.8;
leg_diameter = feet_diameter + leg_outer_wall_width * 2;

// Position of each of the legs. You will have to adjust these values if you change the dimensions of the feet/legs.
leg_positions = [
  [7.2, 95.1],
  [142.72 - 7.2, 106.32 - 7.7],
  [7.2, 30]
];

/* [Hidden] Not intended to be modified */
cut_extra = 1;
pcb_thickness = 1.6;
pcb_hole_diameter = 2.4;
// Measured from the lily58 kicad PCB files
pcb_hole_positions = [
  [19.66, 81.61],
  [95.86, 83.81],
  [19.66, 43.41],
  [95.86, 45.81],
  [120.46, 28.61]
];

/* Vieport values for differente scenes, uncomment each block separately */

// Angled front-left
//$vpt = [ 40, 40, 20 ];
//$vpr = [ 77, 0, -60 ];
//$vpd = 350;
//$vpf = 20;

// Angled back-bottom
//$vpt = [70, 0, 40];
//$vpr = [120, 0, 180];
//$vpd = 350;
//$vpf = 20;

// Right
//$vpt = [0, 54, 15];
//$vpr = [90, 0, 90];
//$vpd = 240;
//$vpf = 20;


main();

module main() {
  if ($preview) {
    color("#494949")
    rotate(typing_angle, [1, 0, 0])
    pcb();
  }
  
  color("White")
  base_assembly();
}

module pcb() {  
  linear_extrude(pcb_thickness)
  difference() {
    pcb_shape();
    
    for (hole_position = pcb_hole_positions) {
      translate(hole_position)
      circle(d = pcb_hole_diameter);
    }
  }
}

module base_assembly() {
  rotate(typing_angle, [1, 0, 0])
  translate([0, 0, -base_thickness])
  base();

  for (leg_position = leg_positions) {
    leg(leg_position);
  }
}

module base() {
  linear_extrude(base_thickness)
  difference() {
    pcb_shape();
    
    polygon([
      [-5, -5],
      [-5, 20],
      [9, 20],
      pcb_hole_positions[2] + [4, -4],
      pcb_hole_positions[1] + [-4, -7],
      [142.72 + 5, 94],
      [142.72 + 5, -5],
    ]);

    for (hole_position = pcb_hole_positions) {
      translate(hole_position)
      circle(d = pcb_hole_diameter + clearance);
    }
  }
}

module leg(position) {
  leg_height = tan(typing_angle) * (position[1] + leg_diameter / 2);
  leg_height_at_center = tan(typing_angle) * position[1];

  translate(position)
  difference() {
    cylinder(h = leg_height, d = leg_diameter);
    
    translate([0, 0, leg_height_at_center])
    rotate(typing_angle, [1, 0, 0])
    translate([-leg_diameter, -leg_diameter, 0])
    cube([leg_diameter * 2, leg_diameter * 2, 10]);

    translate([0, 0, -cut_extra])
    cylinder(h = feet_height + cut_extra, d = feet_diameter);

    translate([0, 0, -cut_extra])
    cylinder(h = feet_exposure + cut_extra, d = leg_diameter + cut_extra);
  }
}

module pcb_shape() {
  translate([142.72, 0])
  mirror([1, 0, 0])
  import("bottom-pcb.svg");
}
