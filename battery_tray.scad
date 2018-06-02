// initial design from :
// http://www.thingiverse.com/thing:48235

// modified by Bertrand MAUBERT oct 2016 (add padding space, add optionnal connectors).
// add code for SD Card, USB key


// battery diameter (AA-14.5, AAA-10.6 123A-16.8 CR2-15.5)
_diameter = 10.6;
// 
MODULE_SIZE = "8AA" ; // valeurs : "8AA","" 

// height of the tray;
_height = 10; // [1:80]

// number of battery clusters across
_columns = 2; // [1:12]

// number of battery clusters deep
_rows = 1; // [1:12]

// padding between the clusters of batteries (also affects padding along the edges)
_spacing = 1.2;

// thickness of the base under the batteries
_base = 1.2; //0.5

// radius of corner rounding
_cornerRounding = 4.0;

// added by BM 
// extra space (add padding along the edges)
_padding = 2;

// dimensions of connector
WITH_CONNECTOR = true ;
_con_x = 7; 
_con_y = 2.5;
_con_z = 10;
_offset = 0.2; // spacing for the connector

// CON_PATTERN : // possible values : 
// "middle_of_tray", "middle of quad"
CON_PATTERN = "middle_of_tray" ; 

// choose only one of type of holes.
FOR_BATTERIES = true ;
FOR_USB = false ; 
FOR_USB_AND_SD = false ;

half_depth = _padding + ((2 * _diameter + _spacing) * _rows + _spacing*2)/2;
echo( half_depth ); 
// half_depth = 18.3 ; // Pour des modules de taille fixe
half_width = _padding + ((2 * _diameter + _spacing) * _columns + _spacing*2)/2;
echo( half_width ); 
// half_with = 33.4 ; // Pour des modules de taille fixe

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

module USBHoleMalePartOnly(depth=10){
    width = 2.7 ;
    length = 12.2 ;
    translate([width/2, 0, depth/2])
    cube([width, length,  depth], center=true);
}

module USBHole(depth=10){
    width = 4.5+0.2 ;
    length = 12.1+0.2;
    translate([width/2, 0, depth/2])
    cube([width, length,  depth], center=true);
}
// for USB key
module usbHoles(){
    delta = 9.5 ;            
    make_group_of(3, delta){
        USBHole();
    }    
}

module SDHole(depth=10){
    width = 2.2 +0.2 ;
    length = 24.1 + 0.2 ;
    translate([width/2, 0, depth/2])
    cube([width, length,  depth], center=true);
}

module SDHoles(){
    delta = 5 ;        
    make_group_of(5, delta){
        SDHole();
    }    
}

module make_group_of(count, space){
    for ( i = [0 : count-1]){
    translate([ i * space,0,0]) children();}
}

module makeTray(diameter, height, rows, columns, spacing, base, rounding, padding) {
	eps = 0.1;
	rounding = min(rounding, diameter/2 + spacing*2);
	quadSize = 2 * diameter;
	width = (quadSize + spacing) * columns + spacing*2;
	depth = (quadSize + spacing) * rows + spacing*2;
    echo (width);
    echo (depth);
    
    if (MODULE_SIZE == "8AA") {
            echo ("MODULE SIZE IS 8AA ") ;
            width = 62.8 ; 
            depth = 32.6 ; 
    }   
    echo (width);
    echo (depth);   
        
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
        // holes for batterie
        if (FOR_BATTERIES){
		  translate([0,0,height/2 + base]) {
			for (x=[0:1:columns-1])
			for (y=[0:1:rows-1]) {
				translate([xstart + (quadSize + spacing)*x,
							 ystart + (quadSize + spacing)*y,0]) {
					batteryQuad(diameter, height);
				}
			}
		  }
        }
         if (FOR_USB){
		  translate([0,0,height/2 + base]) {
			for (x=[0:1:columns-1])
			for (y=[0:1:rows-1]) {
				translate([-11 + xstart + (quadSize + spacing)*x,
							 -0 + ystart + (quadSize + spacing)*y,0]) {
					usbHoles(depth);
				}
			}
		  }
        }
          if (FOR_USB_AND_SD){
		  translate([0,0,height/2 + base]) {
			// for (x=[0:1:columns-1])
            x = 0 ;
            echo(x);   
			for (y=[0:1:rows-1]) {
				translate([-11 + xstart + (quadSize + spacing)*0,
							 -0 + ystart + (quadSize + spacing)*y,0]) {
					usbHoles(depth);
				}
			}
            x = 1 ;
            echo(x);
            for (y=[0:1:rows-1]) {
				translate([-11 + xstart + (quadSize + spacing)*x,
							 -0 + ystart + (quadSize + spacing)*y,0]) {
					SDHoles(depth);
				}
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

module spacesForConnectors(){
    // draw several spaces for connectors.
    if (CON_PATTERN == "middle_of_tray"){    
    // echo("middle of tray");
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
    else if (CON_PATTERN == "middle_of_quad"){
       // _rows, 
        QW = (half_width*2)/_columns ; // Quad width
        eps = 0.01;
        %for ( y = [-half_depth, half_depth]){  
            for ( x=[-half_width+(QW/2):QW:eps+half_width-(QW/2)]){
            echo(x ); 
            translate([x,y,0]) 
            spaceForConnector();
            }

            for ( x = [ -half_width, half_width])
                for (y = [-half_depth+(QW/2):QW:eps+half_depth-(QW/2)]  ){
                translate([x,y,0])
                rotate([0,0,90])
                spaceForConnector();
            }
    
        }
    }    
    else{
        echo ("Hein ?");
    }
}


// Main
makeTray(_diameter, _height, _rows, _columns, _spacing, _base, _cornerRounding, _padding, $fn=90);

if  (WITH_CONNECTOR) 
    translate([0,half_depth + 10,0])
    connector();
