/************************************************************************************

simple_delta_common.scad - common shapes used by various delta derivatives
Copyright 2015 Jerry Anzalone
Author: Jerry Anzalone <info@phidiasllc.com>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.

************************************************************************************/

/***************** Modifications *****************

2/4/18 - increasing $fn for some parts to improve print quality

**************************************************/


include <fasteners.scad>
include <bearings.scad>
include <steppers.scad>
include <Triangles.scad>
include <hotends.scad>
include <belt_terminator.scad>
include <belt_profiles.scad>
include <threads.scad>

// round_box makes a box with rounded corners
module round_box(
	length,
	width,
	height,
	radius = 4) {
	hull() {
		for (i = [-1, 1]) {
			translate([i * (length / 2 - radius), width / 2 - radius, 0])
				cylinder(r = radius, h = height, center = true);

			translate([i * (length / 2 - radius), -(width / 2 - radius), 0])
				cylinder(r = radius, h = height, center = true);
		}
	}
}

// the mount body forms the bulk of the linking board mounts on the motor and idler ends
// nut pockets will be included if: nut_pocket = 1 on exterior side, nut_pocket = -1 on interior side
module mount_body(
	cc_mount,
	l_base_mount,
	w_base_mount,
	t_base_mount,
	r_base_mount,
	l_slot = 0,
	hole_count = 3,
	height,
	nut_pocket,
	w_mount = w_mount,
	doecho = true) {

	// various radii and chord lengths
	a_arc_guides = asin(cc_guides / 2 / r_printer); // angle of arc between guide rods at r_printer
	a_sep_guides = 120 - 2 * a_arc_guides; // angle of arc between nearest rods on neighboring apexes
	//l_chord_guides = 2 * r_printer * sin(a_sep_guides / 2); // length of chord between nearest rods on neighboring apexes
	r_tower_center = pow(pow(r_printer, 2) - pow(cc_guides / 2, 2), 0.5); // radius to centerline of apex
	r_mount_pivot = pow(pow(r_tower_center, 2) + pow(cc_mount / 2, 2), 0.5); // radius to pivot point of apex mounts
	a_arc_mount = asin(cc_mount / 2 / r_mount_pivot);// angle subtended by arc struck between apex centerline and mount pivot point
	a_sep_mounts = 120 - 2 * a_arc_mount; // angle subtended by arc struck between mount pivot points on adjacent apexes
	l_chord_pivots = 2 * r_mount_pivot * sin(a_sep_mounts / 2); // chord length between adjacent mount pivot points
	// remove enough material from mount so that a logical length board can be cut to ensure adjacent mount pivot point chord lengths will yield a printer having r_printer
	l_brd = floor(l_chord_pivots / 10) * 10 - l_mount / 2; // length of the board that will be mounted between the apexs to yield r_printer
	l_pad_mount = (l_chord_pivots - l_brd) / 2;
	//l_boss_mount = l_mount - l_pad_mount;
	if (doecho) {
		//echo(str("Distance between nearest neighbor guide rods = ", l_chord_guides, "mm"));
		echo(str("Radius to centerline of tower = ", r_tower_center, "mm"));
		//echo(str("Radius to mount tab pivot = ", r_mount_pivot, "mm"));
		//echo(str("Distance between adjacent mount pivot points = ", l_chord_pivots, "mm"));
		echo(str("Length of linking board to yield printer radius of ", r_printer, "mm  = ", l_brd, "mm"));
		echo(str("Linking board tab thickness = ", height, "mm"));
		echo(str("Linking board hole c-c = ", cc_mount_holes, "mm"));
		echo(str("Linking board hole offset from end = ", floor(l_pad_mount / 2), "mm"));
		//echo(str("Linking board-tab overlap = ", l_boss_mount, "mm"));
		echo(str("l_pad_mount = ", l_pad_mount));
	}

	difference() {
		hull() {
			cylinder(r = w_mount / 2, h = height, center = true);

			translate([0, -l_mount + w_mount / 2, 0])
				cube([w_mount, w_mount, height], center = true);
		}

		// relief for board between apexs
		translate([w_mount - 3, -l_mount / 2 - l_pad_mount, 0])
			cube([w_mount, l_mount, height + 2], center = true);

		// screw holes to mount linking board
		translate([0, -l_mount / 2 - l_pad_mount + floor(l_pad_mount / 2), (t_base_mount > 8) ? t_base_mount - 8 : 0])
			if (hole_count == 4)
				for (i = [-1, 1])
					for (j = [-1, 1])
						translate([0, j * cc_mount_holes / 2, i * cc_mount_holes / 2]) {
							slot(l_slot = l_slot);

							if (nut_pocket != 0)
								translate([nut_pocket * (w_mount / 2 - 3), 0, 0])
									rotate([0, 90, 0])
										cylinder(r = d_M3_nut / 2, h = 2 * h_M3_nut, center = true, $fn = 6);
						}
			else if (hole_count == 3) {
				for (i = [-1, 1])
					translate([0, -cc_mount_holes / 2, i * cc_mount_holes / 2]) {
						slot(l_slot = l_slot);

						if (nut_pocket != 0)
							translate([nut_pocket * (w_mount / 2 - 3), 0, 0])
								rotate([0, 90, 0])
									cylinder(r = d_M3_nut / 2, h = 2 * h_M3_nut, center = true, $fn = 6);
					}

				translate([0, cc_mount_holes / 2, 0]) {
					slot(l_slot = l_slot);

					if (nut_pocket != 0)
						translate([nut_pocket * (w_mount / 2 - 3), 0, 0])
							rotate([0, 90, 0])
								cylinder(r = d_M3_nut / 2, h = 2 * h_M3_nut, center = true, $fn = 6);
				}
			}
	}
}

// just what it sounds like
module slot(
	l_slot) {
		rotate([0, 90, 0])
			if (l_slot > 0)
				hull()
					for (k = [-1, 1])
						translate([0, k * l_slot / 2, 0])
							cylinder(r = d_M3_screw / 2, h = w_mount + 2, center = true);
			else
				cylinder(r = d_M3_screw / 2, h = w_mount + 2, center = true);
}

// so that the relief of the mount holes for vertical boards are consistent:
module vertical_board_relief(doecho = true) {
	// holes to mount vertical boards
	for (i = [-1, 1])
		translate([i * cc_v_board_mounts / 2, 0, 0])
			rotate([90, 0, 0])
				cylinder(r = d_M3_screw / 2, h = w_clamp + 1, center = true);

	if (doecho) echo(str("c-c vertical board mounts = ", cc_v_board_mounts));
}

// the mount is the shape that linking boards attach to
module mount(
	l_slot,
	height,
	cc_mount,
	base_mount = true,
	nut_pocket,
	doecho,
	d_base_mount = 4) {
	union() {
		mount_body(
			cc_mount = cc_mount,
			l_base_mount = l_base_mount,
			w_base_mount = w_base_mount,
			t_base_mount = t_base_mount,
			r_base_mount = r_base_mount,
			l_slot = l_slot,
			height = height,
			nut_pocket = nut_pocket,
			doecho = doecho);

			if (base_mount)
			// boss for mounting base plate
				translate([-w_mount / 2 - w_base_mount / 2 + r_base_mount, -l_base_mount / 2, (t_base_mount - height) / 2])
					difference() {
						round_box(
							w_base_mount,
							l_base_mount,
							t_base_mount,
							radius = r_base_mount);

						translate([-w_base_mount / 2 + 4, -l_base_mount / 2 + 4, 0])
							cylinder(r = d_base_mount / 2, h = t_base_mount + 1, center = true);

						translate([-w_base_mount / 2 + 4, 0, 0])
							cylinder(r = d_base_mount / 2, h = t_base_mount + 1, center = true);
					}
	}
}

// the apex is the shape of the motor or idler end
module apex(
	l_slot,
	height = h_clamp,
	cc_mount,
	base_mount = true,
	nut_pocket = 0,
	doecho = true,
	d_base_mount
) {
	hull() {
		for (i = [-1, 1])
			translate([i * cc_mount / 2, 0, 0])
				cylinder(r = w_mount / 2, h = height, center = true);
	}

	for (i = [-1, 1])
		translate([i * cc_mount / 2, 0, 0])
			rotate([0, 0, i * 30])
				mirror([(i < 0) ? i : 0, 0, 0])
					mount(
						l_slot = l_slot,
						height = height,
						cc_mount = cc_mount,
						base_mount = base_mount,
						nut_pocket = nut_pocket,
						doecho = doecho,
						d_base_mount = d_base_mount);
}

// rod_clamp_relief uses the whole motor/idler end as a clamp, requiring threaded rods to apply clamping force
module rod_clamp_relief(
	height,
	z_offset_guides,
	height_divisor = 4) {
	union() {
		// clamp screws
		for (i = [-1, 1])
			for (j = [-1, 1])
				translate([0, (w_idler_relief + d_M3_nut) / 2 - 1, i * height / height_divisor])
					rotate([0, 90, 0]) {
						translate([0, 0, j * (l_clamp / 2 + 0.1)])
							cylinder(r = d_M3_washer / 2 + 1, h = 1, center = true);

						cylinder(r = d_M3_screw / 2, h = l_clamp + 1, center = true);
					}

		// guide rod holes and slots for clamp
		for (i = [-1, 1])
			translate([i * cc_guides / 2, 0, 0]) {
				translate([0, 0, z_offset_guides - height / 2])
					cylinder(r = d_guides / 2, h = height);

				translate([0, (w_clamp - d_guides) / 2 + 0.5, 0])
					cube([gap_clamp, w_clamp, height + 1], center = true);
			}
	}
}

// bar_clamp_relief employs bars with M3 nuts for application of clamping force in the motor/idler ends
module bar_clamp_relief(z_offset_guides) {
	// instead of using the end body as a clamp, use a bar:
	for (i = [-1, 1])
		translate([i * cc_guides / 2, 0, 0]) {
			// put a hole all the way through so Slic3r doesn't treat it like a hole in the model
			cylinder(r = 0.1, h = h_clamp + 1, center =true);

			translate([0, 0, z_offset_guides])
				cylinder(r = d_guides / 2, h = h_clamp, center = true);

			// the bar clamp will be rectangular but the pocket it sits in will be trapezoidal so that the clamp can be pressed against the guide rod
			translate([i * -t_bar_clamp / 2, 0, 0]) {
				hull() {
					translate([0, -w_clamp / 2 - 1, 0])
						cube([t_bar_clamp, 0.1, h_bar_clamp + 2 * layer_height], center = true);

					translate([i, w_clamp / 2 + 1, 0])
						cube([t_bar_clamp + 2, 0.1, h_bar_clamp + 2 * layer_height], center = true);
				}

				translate([i * (pad_clamp / 2 + 1), w_clamp / 2 - 7, 0])
					rotate([0, 90, 0])
						cylinder(r = d_M3_screw / 2, h = 2 * pad_clamp, center = true);
			}
		}
}

// bar_clamp is the part that clamps against the guide rods when the motor/idler ends use bar_clamp_relief
module bar_clamp() {
	mirror([0, 0, 1])
		difference() {
			cube([h_bar_clamp, w_clamp, t_bar_clamp], center = true);

			translate([0, w_clamp / 2 - 7, 0]) {
				translate([0, 0, -t_bar_clamp / 2 - layer_height])
					cylinder(r = d_M3_screw / 2, h = t_bar_clamp, center = true);

				translate([0, 0, t_bar_clamp / 2])
					cylinder(r = d_M3_nut / 2, h = 2 * h_M3_nut + 1, center = true, $fn = 6);
			}

			translate([0, 0, -t_bar_clamp / 2])
				rotate([0, 90, 0])
					cylinder(r = d_guides / 2, h = h_bar_clamp + 1, center = true);

			//angle the outside end so it's flush with the face of the end when tightened
			translate([0, w_clamp / 2 + (h_bar_clamp - h_bar_clamp * sin(atan(2 / w_clamp))) / 2, 0])
				rotate([atan(2 / w_clamp), 0, 0])
					cube([h_bar_clamp + 1, h_bar_clamp, h_bar_clamp], center = true);
		}
}

// the hotend_cage is the part of the hotend mount that the fan mounts to
module hotend_cage(
	thickness,
	a_fan_mount,
	l_fan,
	d_fan_mount_hole,
	cc_mount_holes,
	d_fan,
	d_hotend_side,
	r_flare,
	dalekify = false,
	vent = false,
	rear_wires = false
) {

	y_offset_fan = d_hotend_side / 2 + t_heat_x_jhead / 2 * sin(a_fan_mount);
	z_offset_fan = t_effector;
	h_thickness = thickness / cos(a_fan_mount); // length of hypoteneus based upon thickness of cage
	t_fan_mount = 3;
	h_fan_mount = t_fan_mount / 2 / cos(a_fan_mount);
	r_mount_holes = pow(pow(cc_mount_holes / 2, 2) * 2, 0.5);

	difference() {
		union() {
			difference() {
				hotend_cage_shape(
					thickness = thickness,
					d_hotend_side = d_hotend_side,
					l_fan = l_fan,
					y_offset_fan = y_offset_fan,
					z_offset_fan = z_offset_fan,
					a_fan_mount = a_fan_mount,
					r_flare = r_flare,
					dalekify = dalekify);

				hotend_cage_shape(
					thickness = thickness - 6,
					d_hotend_side = d_hotend_side - 5,
					l_fan = l_fan - 6,
					y_offset_fan = y_offset_fan + 0.5,
					z_offset_fan = z_offset_fan,
					a_fan_mount = a_fan_mount,
					r_flare = r_flare);
			}

			translate([0, y_offset_fan, (l_fan > h_thickness) ? z_offset_fan + (l_fan - h_thickness) / 2: z_offset_fan])
				rotate([90 + a_fan_mount, 0, 0]){
					for (i = [-1, 1])
						translate([i * cc_mount_holes / 2, cc_mount_holes / 2, 0])
							rotate([0, 0, i * 20])
								hull() {
									cylinder(r = 3, h = t_fan_mount, center = true);

									translate([0, -4, 0])
										cylinder(r = 1, h = t_fan_mount, center = true);
								}

					for (i = [-1, 1])
						translate([i * cc_mount_holes / 2, -cc_mount_holes / 2, 0])
							cylinder(r = 3, h = t_fan_mount, center = true);
				}
		}

		translate([0, y_offset_fan, (l_fan > h_thickness) ? z_offset_fan + (l_fan - h_thickness) / 2: z_offset_fan])
			rotate([90 + a_fan_mount, 0, 0])
				for (i = [0:3])
					rotate([0, 0, i * 90 + 45])
						translate([0, r_mount_holes, 0])
							cylinder(r = 2.5 / 2, h = t_fan_mount + 6, center = true);

		if (vent) {
			for (i = [-4:4])
				if (i != 0)
					rotate([0, 0, i * 20])
						translate([0, -15, 0])
							rotate([90, 0, 0])
								hull()
									for (j = [-1, 1])
										translate([0, 0, j * 15])
											scale([0.2, 1])
												cylinder(r = thickness / 4, h = 1, center = true);
		}

		if (!rear_wires) {
			translate([10, y_offset_fan - 5.5, z_offset_fan + l_fan / 2 + layer_height])
				rotate([a_fan_mount, 0, 0])
					cylinder(r = 3, h = 10);
		}
	}
}

// hotend_cage_shape forms the fan-to-outlet transition that is the exterior and interior of the bulk of the hotend cage
module hotend_cage_shape(
	thickness,
	d_hotend_side,
	l_fan,
	y_offset_fan,
	z_offset_fan,
	a_fan_mount,
	r_flare,
	dalekify = false) {

	h_thickness = thickness / cos(a_fan_mount); // length of hypoteneus based upon thickness of cage
	r_dalek_spheres = 2;
	a_dalek_spheres = 30;

	union() {
		hull() {
			cylinder(r1 = d_hotend_side / 2 + r_flare, r2 = d_hotend_side / 2, h = thickness, center = true, $fn = (dalekify) ? 12 : 200);

			translate([0, y_offset_fan, (l_fan > h_thickness) ? z_offset_fan + (l_fan - h_thickness) / 2 : z_offset_fan])
				rotate([90 + a_fan_mount, 0, 0])
					round_box(
						l_fan,
						l_fan,
						3,
						radius = 3);
		}

		if (dalekify) {
			translate([0, 0, -thickness / 2])
				for (i = [0:3])
					translate([0, 0, i * (thickness - t_effector - r_dalek_spheres) / 4 + t_effector + r_dalek_spheres])
						rotate([0, 0, a_dalek_spheres / 2])
						for (j = [-3:2])
							rotate([0, 0, j * a_dalek_spheres])
								translate([0, -(d_hotend_side / 2 + r_flare * (thickness - (i * (thickness - t_effector) / 4 + t_effector)) / thickness), 0])
									sphere(r = r_dalek_spheres);
		}
	}
}

// hotend_mount is the shape placed on a tool or effector onto which a fan and hot end can be mounted
module hotend_mount(dalekify = false,
	quickrelease = false,
	vent = false,
	rear_wires = false,
	headless = false
) {
	union() {
		difference() {
			union() {
				// hot end cage
				translate([0, 0, (t_hotend_cage - t_effector) / 2])
					hotend_cage(
						thickness = t_hotend_cage,
						a_fan_mount = a_fan_mount,
						l_fan = l_fan,
						d_fan_mount_hole = 3.4,
						cc_mount_holes = 32,
						d_fan = 38,
						d_hotend_side = d_hotend_side,
						r_flare = r_flare,
						dalekify = dalekify,
						vent = vent
					);

				// hot end retainer body
				translate([0, 0, z_offset_retainer]) {
					cylinder(r1 = r1_retainer_body, r2 = r2_retainer_body, h = h_retainer_body, $fn = 200);

					if (!headless)
					// cool looking top
					translate([0, 0, h_retainer_body]) {
						scale([1, 1, 1.2])
							intersection() {
								sphere(r = r2_retainer_body);

								translate([-r2_retainer_body, -r2_retainer_body, 0])
									cube([2 * r2_retainer_body, 2 * r2_retainer_body,2 * r2_retainer_body]);
							}

						if (dalekify)
							for (i = [-1, 1])
								translate([])
									rotate([0, i * 45, 0])
										cylinder(r = 1.5, h = r2_retainer_body + 4);
					}
				}
			} // end union

			// opening for hot end
//			translate([0, 0, -t_effector / 2 - 1])
//				cylinder(r1 = r1_opening, r2 = r2_opening, h = t_effector + 1.5, center = true);

			// hot end mounting parts
			translate([0, 0, z_offset_retainer]) {
				// bowden sheath retainer
				translate([0, 0, -1])
					hull()
						for (i = [0, 1])
							translate([0, i * d_hotend_side, 0])
								cylinder(r = d_small_jhead / 2, h = h_groove_jhead + 2);

				translate([0, 0, h_groove_jhead]) {
					hull()
						for (i = [0, 1])
							translate([0, i * d_large_jhead / 2, 0])
								cylinder(r = d_large_jhead / 2, h = h_groove_offset_jhead);

					hull() {
						translate([0, d_large_jhead / 3, h_groove_offset_jhead / 2])
							cube([d_large_jhead, 0.1, h_groove_offset_jhead], center = true);

						translate([0, d_large_jhead, h_groove_offset_jhead / 2 - 1.5])
							cube([d_large_jhead, 0.1, h_groove_offset_jhead + 3], center = true);
					}

					// truncate the slot for the hot end to facilitate insertion - 03_01_2015
					translate([0, d_large_jhead + 1, 0])
						cube([r2_retainer_body * 2, d_large_jhead, h_groove_offset_jhead + 5], center = true);

					if (quickrelease) {
						if (headless) {
							// relief for quick release connector
							translate([0, 0, h_groove_offset_jhead + layer_height])
								cylinder(r = d_quickrelease / 2, h = 10);

							// relief for thumbscrew
							translate([0, 0, h_retainer_body - h_groove_jhead + 1])
								cylinder(r = 12, h = 10);
						}
						else {
							// Bowden sheath
							translate([0, 0, h_groove_offset_jhead + layer_height])
								cylinder(r = bowden[2] / 2, h = 30);

								// chop top off tool
								translate([0, 0, r2_retainer_body + h_retainer_body - h_groove_jhead]) {
									cylinder(r = d_hotend_side / 2 - 5, h = d_hotend_side);

									translate([0, 0, -countersink_quickrelease]) {
										// quick release fitting countersink
										cylinder(r = d_quickrelease / 2, h = countersink_quickrelease + 1);

										// quick release fitting threads
										translate([0, 0, -l_quickrelease_threads])
											metric_thread(diameter = d_quickrelease_threads, pitch = pitch_quickrelease_threads, length = l_quickrelease_threads, internal = true, n_starts = 1);
									}
							}
						}

						translate([0, 0, h_groove_offset_jhead + layer_height]) {
							rotate([0, 0, 40]) {
							// retainer retainer
							translate([0, (d_large_jhead + d_retainer_screw) / 2, 0])
								cylinder(r = d_retainer_screw / 2 - 0.15, h = 20);

							translate([0, (d_large_jhead + d_retainer_screw) / 2, 2])
								cylinder(r = d_M2_screw_head / 2, h = 20);
							}
						}
					}
					else
						// Bowden sheath retainer
						translate([0, 0, h_groove_offset_jhead + layer_height]) {
							cylinder(r = bowden[0] / 2, h = bowden[1], $fn = 6);

							// bowden sheath
							translate([0, 0, bowden[1] + layer_height])
								cylinder(r = bowden[2] / 2, h = 30);

							// retainer retainer
							translate([0, (d_large_jhead + d_retainer_screw) / 2, 0])
								cylinder(r = d_retainer_screw / 2 - 0.15, h = 20);

							translate([0, (d_large_jhead + d_retainer_screw) / 2, 6])
								cylinder(r = d_M2_screw_head / 2, h = 20);
					}
				}

				if (dalekify) {
					for (i = [-1,1])
						translate([i * (d_hotend_side / 2 - 3), 0, 3])
							rotate([80, 0, 0])
								cylinder(r = 2.2 / 2, h = 20);

					translate([0, -r2_retainer_body + 7, h_retainer_body + r2_retainer_body - 5])
						rotate([70, 0, 0])
							cylinder(r = 2.2 / 2, h = 20);
			}

		}

				if (rear_wires) {
					// wires exit in back
					translate([0, -1, 0]) // increase wire-hot end clearance 06/26/2015
						rotate([22, 0, 0])
							cylinder(r = 3.5, h = 40); // increased diameter 06/26/2015
				}
				// access for pushing hot end out
				translate([0, 0, z_offset_retainer + h_groove_jhead + h_groove_offset_jhead / 2])
					rotate([90, 0, 0])
						cylinder(r = 1.5, h = 30, center = true);

		} // end difference

		translate([0, 0, z_offset_retainer - layer_height / 2]) {
			// floor for retainer body
			hull() {
				cylinder(r = r1_retainer_body - 1, h = layer_height);

				translate([0, r1_retainer_body, 0])
					cube([38, 0.1, 2 * layer_height], center = true);
				}

			// floor for top of retainer body
			translate([0, d_hotend_side / 2 - 2, h_groove_jhead + h_groove_offset_jhead + layer_height])
				cube([l_fan - 5, 7, 2 * layer_height], center = true);
		}
	} // end floor union
}

// tool_mount_body is the shape forming the base of a tool mount to be used on a tool end effector
module tool_mount_body(
	h_effector_tool_mount,
	d_effector_tool_magnet_mount
) {
	union() {
		hull()
			for (i = [0:2])
				rotate([0, 0, i * 120 + 60])
					translate([0, d_effector_tool_magnet_mount / 2, 0])
						cylinder(r = d_ball_bearing / 2 + 1.5, h = h_effector_tool_mount, center = true);

		for (i = [0:2])
			rotate([0, 0, i * 120 + 60])
				translate([0, d_effector_tool_magnet_mount / 2, -1])
					difference() {
						sphere(r = d_ball_bearing / 2 + 1.5);

						translate([0, 0, -d_ball_bearing / 2])
							cylinder(r = d_ball_bearing, h = d_ball_bearing, center = true);
					}

		// put an index on the edge normal the y-axis
		translate([5 * tan(30), (d_effector_tool_magnet_mount / 2 + d_ball_bearing / 2 + 1.5) * tan(30), 0])
			rotate([0, 0, 60])
				linear_extrude(height = h_effector_tool_mount, center = true)
					equilateral(5);

	}
}

// tool_mount_bearing_cage forms the relief for the ball bearings used in the tool mount
module tool_mount_bearing_cage(
	d_effector_tool_magnet_mount,
	h_effector_tool_mount) {
			// place the center of the ball bearings just under the top of the mount so they snap in their pockets
			for (i = [0:2])
				rotate([0, 0, i * 120 + 60])
					translate([0, d_effector_tool_magnet_mount / 2, -h_effector_tool_mount / 2]) {
						translate([0, 0, 2])
							sphere(r = d_ball_bearing / 2);

						sphere(r = d_ball_bearing / 2);
					}
}

// magnet_mount is the shape of the bosy and pocket into which magnets are mounted
module magnet_mount(r_pad, h_pad, test = false) {
	// this places the pivot point at the origin
	translate([0, 0, -r_bearing_seated - h_magnet / 2])
		difference() {
			translate([0, 0,  - h_pad / 2])
				cylinder(r = od_magnet / 2 + r_pad, h = h_magnet + h_pad, center = true, $fn = 200);

				cylinder(r1 = od_magnet / 2 + 0.25, r2 = od_magnet / 2, h = h_magnet, center = true, $fn = 200);
		}

if (test)
	translate([0, 0, -r_bearing_seated - h_magnet / 2]) {
		// magnet and ball bearing
		color([0.7, 0.7, 0.7])
			union() {
				difference() {
					cylinder(r = od_magnet / 2, h = h_magnet, center = true);

					cylinder(r = id_magnet / 2, h = h_magnet + 1, center = true);
				}

				translate([0, 0, h_magnet / 2 + r_bearing_seated])
					sphere(r = d_ball_bearing / 2);
			}
}
}

// effector_base is the shape of the base of the end effector
module effector_base(large = false) {
	r_apex = 2.5;

	difference() {
		union() {
			// magnet mounts are always in the same position
			effector_tierod_magnets();

			if (large){
				// knock off the edges where the magnet mounts are located
				difference() {
					cylinder(r = (h_triangle_inner + od_magnet) / 2 + r_pad_effector_magnet_mount, h = t_effector, center = true);

					for (i = [0:2])
						rotate([0, 0, i * 120 + 60])
							translate([0, (h_triangle_inner + od_magnet) / 2 + r_pad_effector_magnet_mount, 0])
								for (j = [-1, 1])
									translate([j * 6, 0, 0])
										rotate([0, j * (90 - tie_rod_angle), 0])
											cylinder(r = od_magnet / 2, h = 8);
				}
			}

			else {
				// inner portion of effector
				difference() {
					translate([0, r_triangle_middle - h_triangle_inner, 0])
						linear_extrude(height = t_effector, center = true)
							equilateral(h_triangle_inner);

					// round the triangle apexes
					for(i = [0:2])
						rotate([0, 0, i * 120])
							translate([0, r_triangle_middle - h_triangle_inner, 0])
								cylinder(r = r_apex, h = t_effector + 1, center = true);
				}
			}

			// put an index on the side normal the y-axis
			translate([5 * tan(30), (large) ? (h_triangle_inner + od_magnet) / 2 + r_pad_effector_magnet_mount - 1: h_triangle_inner * tan(30) * tan(30) - 1, 0])
				rotate([0, 0, 60])
					linear_extrude(height = t_effector, center = true)
						equilateral(5);
		}

		// need to flatten base
		translate([0, 0, -t_effector * 2.5])
			cylinder(r = r_effector * 2, h = t_effector * 4, center = true);
	}
}

module effector_tierod_magnets() {
	translate([0, 0, h_effector_magnet_mount])
		for (i = [0:2])
			rotate([0, 0, i * 120])
				translate([0, r_effector, 0])
						rotate([tie_rod_angle - 90, 0, 0])
							for (j = [-1, 1])
								translate([j * (l_effector) / 2, 0, 0])
									magnet_mount(r_pad = r_pad_effector_magnet_mount, h_pad = h_effector_magnet_mount);
}

// carriage_body renders the solid parts of the carriage with relief dor the end stop adjustment screw
module carriage_body(
	limit_switch_mount = true,
	linear_bearing = bearing_lm8uu) {
	difference() {
		union() {
			// bearing saddles
			for (i = [-1, 1])
				translate([i * cc_guides / 2, 0, 0])
					cylinder(r = linear_bearing[0] / 2 + 3, h = h_carriage, center = true, $fn = 100);

			// boss for the limit switch engagement  screw
			if (limit_switch_mount)
				translate([l_effector / 2 - limit_x_offset, y_web, -h_carriage / 2 + 3.5])
					difference() {
						hull()
							for (i = [0, 1])
								translate([0, i * (limit_y_offset - y_web), 0])
									cylinder(r1 = d_M3_screw / 2 + 3, r2 = d_M3_screw / 2 + 2, h = 7, center = true);

						translate([0, 5, 0])
							cube([10, 10, 10], center = true);
					}

			// web
			translate([0, y_web, 0])
				cube([cc_guides, w_carriage_web, h_carriage], center = true);
		}

		// end stop screw
		if (limit_switch_mount)
			translate([l_effector / 2 - limit_x_offset, limit_y_offset, 0]) {
				translate([0, 0, -h_carriage / 2 + h_M3_cap + 0.25])
					cylinder(r = d_M3_screw / 2 - 0.4, h = 7);

				translate([0, 0, -h_carriage / 2])
					cylinder(r = d_M3_cap / 2, h = 2 * h_M3_cap, center = true);
			}
	}
}

// carriage_bearing_relief renders the pockets for lm8uu bearings and guide rods for the carriage
module carriage_bearing_relief(
	linear_bearing = bearing_lm8uu
) {
	union() {
		// bearing pockets and guide rod relief
		for (i = [-1, 1])
			translate([i * cc_guides / 2, 0, 0]) {
				for (j = [0, 1])
					translate([0, j * (linear_bearing[0] / 2 - 1), 0])
						cylinder(r = linear_bearing[0] / 2, h = linear_bearing[2], center = true, $fn = 100);

				difference() {
					hull() {
						cylinder(r = d_guides / 2, h = h_carriage + 2, center = true);

						translate([0, linear_bearing[0] / 2 + 3, 0])
							cylinder(r = d_guides / 2, h = h_carriage + 2, center = true);
					}

					translate([0, 0, (linear_bearing[2] + layer_height) / 2])
						cube([linear_bearing[0], d_guides, layer_height], center = true);
				}

				translate([0, 10, 0])
					cube([linear_bearing[0] + 8, linear_bearing[0] / 2 + 5, h_carriage + 4], center = true);
			}
	}
}

// carriage_wire_tie_relief are the slots for wire ties in the carriage
module carriage_wire_tie_relief(
	linear_bearing = bearing_lm8uu,
	clearance = 1
) {
	difference() {
		hull() {
			cylinder(r = linear_bearing[0] / 2 + clearance + 1.4, h = 4.5, center = true);

			translate([0, -6, 0])
				cylinder(r = linear_bearing[0] / 2 + clearance + 1.4, h = 4.5, center = true);
		}

		hull() {
			cylinder(r = linear_bearing[0] / 2 + clearance, h = 6, center = true);

			translate([0, -6, 0])
				cylinder(r = linear_bearing[0] / 2 + clearance, h = 6, center = true);
		}
	}
}

// 12mm_vboard_mount is a shape for tucking wires under and attaching fixtures to 12mm thick boards
module 12mm_board_mount(
	height = 10,
	length = 10,
	width = 16,
	d_wire_guide = 12.2,
	wire_guide_offset = 5
) {
	union() {
		difference() {
			cube([length, width, height], center = true);

			translate([0, 0, d_wire_guide / 2 + wire_guide_offset])
				cube([length + 1, 12.2, height], center = true);

			rotate([0, 90, 0])
				hull()
					for (i = [-1, 1])
						translate([i * height / 2 - d_wire_guide / 2 - wire_guide_offset, 0, 0])
							rotate([0, 0, 30])
								cylinder(r = d_wire_guide / 2, h = length + 1, center = true, $fn = 6);
		}

		if (d_wire_guide < 12.2) // ad a floor to the guide
			translate([height / 2 - d_wire_guide / 2 - wire_guide_offset, 0, -layer_height / 2])
				cube([length, width, layer_height], center = true);
	}
}
