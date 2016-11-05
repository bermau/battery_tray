// initial design by 

// modified by Bertrand MAUBERT oct 2016 (add padding space, add optionnal connectors).

// battery diameter (AA-14.5, AAA-10.6 123A-16.8 CR2-15.5)
_diameter = 14.5;

// height of the tray;
_height = 8; // [1:80]

// number of battery clusters across
_columns = 2; // [1:12]

// number of battery clusters deep
_rows = 1; // [1:12]

// padding between the clusters of batteries (also affects padding along the edges)
_spacing = 1.2;

// thickness of the base under the batteries
_base = 0.5;

// radius of corner rounding
_cornerRounding = 4.0;

// added by BM 
// extra space (add padding along the edges)
_padding = 2;

// dimensions of connector
WITH_CONNECTOR = true ;
_con_x = 7; 
_con_y = 2.5;
_con_z = 8;
_offset = 0.2; // spacing for the connector


half_depth = _padding + ((2 * _diameter + _spacing) * _rows + _spacing*2)/2;
half_width = _padding + ((2 * _diameter + _spacing) * _columns + _spacing*2)/2;

module batteryQuad(diameter, height) {
	angle = 35;
	r = diameter/2;
	cut = 2*r*sin(angle);
	tan = tan(angle);
	filletCenter = r - r * tan;
	filletCenter2 = r + r * tan;
	filletOffset = r * tan;
	filletRadius = r/cos(angle) - r;

	eps = 0.1;

	difference() {
		union() {
			for (x=[-r,r]) {
				for (y=[-r,r]) {
					translate([x,y,0]) {
						cylinder(r=r, h=height, center=true);
					}
				}
			}
			for (t=[ [ r, 0, 0],
					[-r, 0, 0],
					[ 0, r, 0],
					[ 0,-r, 0] ]) {
				translate(t) {
					cube(size=[cut,cut,height], center=true);
				}
			}
		}
		// round
		for (z=[0:90:270]) {
			rotate([0,0,z]) {
				for(y=[filletOffset, -filletOffset]) {
					translate([0, r+y,0]) {
						cylinder(r=filletRadius, h=height+eps, center=true, $fn=30);
					}
				}	
			}
		}
	}
}





module makeTray(diameter, height, rows, columns, spacing, base, rounding, padding) {
	eps = 0.1;
	rounding = min(rounding, diameter/2 + spacing*2);
	quadSize = 2 * diameter;
	width = (quadSize + spacing) * columns + spacing*2;
	depth = (quadSize + spacing) * rows + spacing*2;
	xstart = -width/2 + spacing*1.5 + quadSize/2;
	ystart = -depth/2 + spacing*1.5 + quadSize/2;

	difference() {
        // main block
		hull()
		for (x=[-padding - width/2 + rounding, 
            + padding + width/2 - rounding])
		for (y=[-padding - depth/2 + rounding, 
            + padding + depth/2 - rounding]) {
			translate([x,y])
			cylinder(r=rounding, h=height);
		}
        // holes.
		translate([0,0,height/2 + base]) {
			for (x=[0:1:columns-1])
			for (y=[0:1:rows-1]) {
				translate([xstart + (quadSize + spacing)*x,
							 ystart + (quadSize + spacing)*y,0]) {
					batteryQuad(diameter, height);
				}
			}
		}
        // Spaces for connectors
        if  (WITH_CONNECTOR) 
            spacesForConnectors();
	    }
}

module connector2D(){
        polygon([
    [-_con_x,_con_y], [_con_x, _con_y], [_con_x-_con_y,0],  
    [_con_x, -_con_y], [-_con_x, -_con_y],[-_con_x+_con_y , 0]]);
    }
module connector(){
    linear_extrude(height=_con_z)
    connector2D();
    }
module spaceForConnector(){
    translate([0,0,-0.1])
    linear_extrude(height=_con_z + 0.5)
    offset(delta = _offset){
    connector2D();
   }
}
    
CON_PATTERN = "middle" ;
module spacesForConnectors(){
    // draw several spaces for connectors.
    if (CON_PATTERN == "middle"){    
    for ( y = [ - half_depth, half_depth]){
        translate([0,y,0])
        spaceForConnector();
    }
    for ( x = [ - half_width, half_width]){
        translate([x,0,0])
        rotate([0,0,90])
        spaceForConnector();
    }
    }
}


// Main
makeTray(_diameter, _height, _rows, _columns, _spacing, _base, _cornerRounding, _padding, $fn=90);

if  (WITH_CONNECTOR) 
    translate([0,half_depth + 10,0])
    connector();
