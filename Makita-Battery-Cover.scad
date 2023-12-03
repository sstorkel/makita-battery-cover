//
// Battery cover for Makita 18V power-tool batteries. Verified to fit BL1815 and BL1830
// batteries.
//
// This design is a remix of a model initially created by Thingiverse user beaq. Find
// the original project here: https://www.thingiverse.com/thing:5892130
//
// Requires the BOSL2 library from BelfrySCAD: https://github.com/BelfrySCAD/BOSL2
//

include <BOSL2/std.scad>
include <BOSL2/rounding.scad>


/* [Base Plate] */
Baseplate_Thickness = 3.0;
Baseplate_Width = 68.0;
Baseplate_Length = 76.0;
Baseplate_Corner_Radius = 12.0;

/* [Base Plate Hole] */
Baseplate_Hole_Length = 10;
Baseplate_Hole_Width = 35;
Baseplate_Hole_Offset = 6;

/* [Base Plate Rib] */
Baseplate_Rib_Length = 45.0;
Baseplate_Rib_Height = 1.5;
Baseplate_Rib_Width = 4.0;
Baseplate_Rib_Offset = 40.0;

/* [Back] */
Back_Clearance = 2.0;

/* [Sides] */
Side_Height = 13.0;
Side_Thickness = 3.0;
Side_Length = 56.0;

/* [Runners] */
Runner_Height = 2.0;
Runner_Length = 40 + Side_Thickness;
Runner_Width = 2.0;

/* [Hidden] */
$fn = 100;
roundingRadius = 2.0;
// See https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/CSG_Modelling#union for an explanation of
// why this is needed for union() and difference() operations
epsilon = 0.01; 



/**********************************
 *
 *  BASE PLATE WITH HOLE
 *
 **********************************/
 
 // Rather than use a simple rectangular plate with sharp corners, we use BOSL2's `rect` function
 // to create a path that has large large radius corners at the front of the plate and smaller
 // radius corners at the back.
 
 platePath = rect([Baseplate_Width, Baseplate_Length], 
                  rounding=[roundingRadius, roundingRadius, Baseplate_Corner_Radius, Baseplate_Corner_Radius], 
                  anchor=FRONT+LEFT);
                  
color("silver") {
    difference() {
        // Create the baseplate from our `platePath` then translate it so that the top of the plate is at Z=0.
        // Using `offset_sweep` allows us to round the bottom edge of the plate rather than having sharp edges
        translate([0,0, -Baseplate_Thickness])                  
            offset_sweep(platePath, height=Baseplate_Thickness, check_valid=false, bottom=os_teardrop(r=roundingRadius));
        
        // Create the hole that the battery will grab onto
        translate([(Baseplate_Width - Baseplate_Hole_Width)/2, Baseplate_Hole_Offset, -Baseplate_Thickness-epsilon]) 
            cube([Baseplate_Hole_Width, Baseplate_Hole_Length, Baseplate_Thickness+2*epsilon]);

    }    
}

/**********************************
 *
 *  BASE PLATE RIB
 *
 **********************************/

// To keep the cover from rocking front-to-back we add a horizontal rib across the baseplate

color("red") {
    // The majority of the rib is a simple `cube`
    translate([ (Baseplate_Width - Baseplate_Rib_Length)/2, Baseplate_Rib_Offset, 0])
        cube([Baseplate_Rib_Length, Baseplate_Rib_Width, Baseplate_Rib_Height]);
    
    // Add a ramp to the front of the rib to make it easier for the cover to slide on. Use
    // a `polygon` to define a triangle shape, then extrude, rotate, and translate it into
    // the correct location
    translate([(Baseplate_Width - Baseplate_Rib_Length)/2, Baseplate_Rib_Offset - Baseplate_Rib_Width, 0])
        rotate([90, 0, 90])
            linear_extrude(Baseplate_Rib_Length)
                polygon([[0,0], [Baseplate_Rib_Width, 0], [Baseplate_Rib_Width, Baseplate_Rib_Height]]);
}

/**********************************
 *
 *  BACK WALL
 *
 **********************************/

// Making the back of the cover slightly shorter than the sides gives some clearance for the
// cover to "ride up" and clear the latch

color("blue") {
    translate([roundingRadius, Baseplate_Length - Side_Thickness, 0])
        cube([Baseplate_Width - 2*roundingRadius, Side_Thickness, Side_Height - Back_Clearance]);
}

/**********************************
 *
 *  LEFT SIDE
 *
 **********************************/

// The battery cover side consists of four separate objects:
//   1. The main panel
//   2. A rounded transition from the side to the back wall, which matches the radius of
//     the base plate
//   3. A 60-degree ramp that matches the contour of the battery
//   4. A runner that slots into a groove on the battery

// Left Side
color("cyan") {
    // 1. The main panel
    translate([0, Baseplate_Length - Side_Length - roundingRadius, 0])
        cube([Side_Thickness, Side_Length, Side_Height]);
    
    // 2. A rounded transition from the side to the back wall, which matches the radius of the base plate
    translate([roundingRadius, Baseplate_Length - roundingRadius, 0])
        cylinder(h=Side_Height, r=roundingRadius, center=false);
    
    // 3. A 60-degree ramp that matches the contour of the battery
    translate([Side_Thickness, Baseplate_Length - Side_Length - Side_Height/tan(60) - roundingRadius, 0])
        rotate([0, -90, 0])
            linear_extrude(Side_Thickness)
                polygon([ [0,0], [0, Side_Height/tan(60)], [Side_Height, Side_Height/tan(60)] ]);
    
    // 4. A runner that slots into a groove on the battery
    translate([Side_Thickness, Baseplate_Length - Runner_Length, Side_Height - Runner_Height])
        cube([Runner_Width, Runner_Length, Runner_Height]);
        
    // 4b. In order for the design to be 3D printable, we add a small chamfer under the runner
    translate([Side_Thickness, Baseplate_Length, Side_Height - 2*Runner_Height]) {
        rotate([90, 0, 0]) {
            linear_extrude(Runner_Length) {
                polygon(points=[ [0,0], [0,Runner_Width], [Runner_Width,Runner_Width] ]);
            }
        }
    }
}

/**********************************
 *
 *  RIGHT SIDE
 *
 **********************************/

// Create the right side of the cover by mirroring and translating the code we wrote for the left side

translate([Baseplate_Width, 0, 0]) {
    mirror([1, 0, 0]) {
        color("cyan") {
            // 1. The main panel
            translate([0, Baseplate_Length - Side_Length - roundingRadius, 0])
                cube([Side_Thickness, Side_Length, Side_Height]);
            
            // 2. A rounded transition from the side to the back wall, which matches the radius of the base plate
            translate([roundingRadius, Baseplate_Length - roundingRadius, 0])
                cylinder(h=Side_Height, r=roundingRadius, center=false);
            
            // 3. A 60-degree ramp that matches the contour of the battery
            translate([Side_Thickness, Baseplate_Length - Side_Length - Side_Height/tan(60) - roundingRadius, 0])
                rotate([0, -90, 0])
                    linear_extrude(Side_Thickness)
                        polygon([ [0,0], [0, Side_Height/tan(60)], [Side_Height, Side_Height/tan(60)] ]);
            
            // 4. A runner that slots into a groove on the battery
            translate([Side_Thickness, Baseplate_Length - Runner_Length, Side_Height - Runner_Height])
                cube([Runner_Width, Runner_Length, Runner_Height]);
                
            // 4b. In order for the design to be 3D printable, we add a small chamfer under the runner
            translate([Side_Thickness, Baseplate_Length, Side_Height - 2*Runner_Height]) {
                rotate([90, 0, 0]) {
                    linear_extrude(Runner_Length) {
                        polygon(points=[ [0,0], [0,Runner_Width], [Runner_Width,Runner_Width] ]);
                    }
                }
            }
        }
    }
}
