/************************************************************************************

bearings.scad - dimensions of various bearings
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

// 608 bearing
od_608 = 22.5;
id_608 = 8.4;
h_608 = 7;
bearing_608 = [od_608, id_608, h_608];

// 624 bearing
od_624 = 13;
id_624 = 4.4;
h_624 = 5;
bearing_624 = [od_624, id_624, h_624];

// 625 bearing
od_625 = 16.4;
id_625 = 5.4;
h_625 = 5;
bearing_625 = [od_625, id_625, h_625];

// MR105zz bearing
od_MR105 = 10;
id_MR105 = 5;
h_MR105 = 4;
bearing_MR105 = [od_MR105, id_MR105, h_MR105];

// lm8uu bearing dims
od_lm8uu = 15.2; // measured 15
id_lm8uu = 8; // should be 8 or so
l_lm8uu = 24.5; // measured 24
bearing_lm8uu = [od_lm8uu, id_lm8uu, l_lm8uu];

// lm6uu bearing dims
od_lm6uu = 12; // measured 12
id_lm6uu = 6;
l_lm6uu = 19;
bearing_lm6uu = [od_lm6uu, id_lm6uu, l_lm6uu];

module bearing(type = bearing_608) {
	difference() {
		cylinder(r = type[0] / 2, h = type[2], center = true);

		translate([0, 0, -1])
			cylinder(r = type[1] / 2, h = type[2] + 2, center = true);

		// chamfer top and bottom
		for (i = [-1, 1])
			translate([0, 0, i * type[2] / 2])
				rotate_extrude(convexity = 10)
					translate([type[0] / 2, 0, 0])
						rotate([0, 0, 45])
							square([0.5, 0.5], center = true);
	}
}

module lm8uu(opening = false) {
	if (opening)
		difference() {
			cylinder(r = od_lm8uu / 2, h = l_lm8uu);

			translate([0, 0, -1])
				cylinder(r = id_lm8uu / 2, h = l_lm8uu + 2);
		}
	else
		cylinder(r = od_lm8uu / 2, h = l_lm8uu);
}
