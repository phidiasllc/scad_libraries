/************************************************************************************

Triangles.scad - simple triangle shapes
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

//simple triangles

module equilateral(h, center = false) {
	translate([0, center ? -(h - equilateral_base_from_height(h) * tan(30) / 2) : 0, 0])
		isosoles(equilateral_base_from_height(h), h);
}

module isosoles(b, h) {
	polygon(points=[[0, 0], [b/2, h], [-b/2, h]]);
}

function equilateral_base_from_height(h) =
	0.577350269 * h * 2;

function equilateral_height_from_base(b) =
	b / 0.577350269 / 2;
