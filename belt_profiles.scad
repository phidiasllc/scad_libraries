/************************************************************************************

belt_profiles.scad - dimensions of various timing belts
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

/**********

Belt profile library

definitions:
p = pitch; "The distance between successive corresponding points or lines, e.g., between the teeth of a cogwheel"
hs = total belt height from belt back to tooth tip
ht = total height of tooth from belt root line to tooth tip
s = tooth root width; distance between root radii centers
g = tooth flank angle; if tooth flanks were extended until they intercepted, this is the angle they'd make
ra = tooth tip radius connecting tooth flank to tooth tip
rr = tooth root radius connecting tooth flank to belt root line
w_scale = tooth width scale. Increase or decrease to improve tooth fit
h_scale = tooth height scale. Increase or decrease to improve tooth fit

**********/

//belt profile for T5 timing belt
T5 = [
	5, // p, pitch (mm) -- 0
	2.2, // hs, total belt height (mm) -- 1
	1.2, // ht, tooth height (mm) -- 2
	2.65, // s, tooth root width (mm) -- 3
	40, // g, tooth flank angle (deg) -- 4
	0.4, // ra, tip radius connecting tooth flank to tooth tip (mm) -- 5
	0.4, // rr, root radius connecting tooth flank to belt root line (mm) -- 6
	1.3, // w_scale, factor applied to scale tooth width -- 7
	1.3 // h_scale, factor applied to scale tooth height -- 8
];

//belt profile for T2.5 timing belt
T2_5 = [
	2.5,
	1.3,
	0.7,
	1.5,
	40,
	0.2,
	0.2,
	1.3,
	1.3
];

//belt profile for GT2 timing belt
GT2 = [
	2,
	1.38,
	0.75,
	0.88,
	90,
	0.56,
	0.15,
	1.3,
	1.3
];
