

$fa = 3;
$fs = 0.75;

indexingPinRadius = 5;
indexingPinHeight = 0.3;

function regularPolygonInnerRadiusMultiplier(numCorners) =
    let (pt = ([1, 0] + [cos(1 / numCorners * 360), sin(1 / numCorners * 360)]) / 2)
        sqrt(pt[0]*pt[0] + pt[1]*pt[1]);
module RegularPolygon(numCorners, outerRadius, faceOnXAxis=false) {
    points = [
        for (pointNum = [0 : numCorners - 1])
            [cos(pointNum / numCorners * 360) * outerRadius, sin(pointNum / numCorners * 360) * outerRadius]
    ];
    if (faceOnXAxis)
        rotate([0, 0, 360/numCorners/2])
            polygon(points);
    else
        polygon(points);
};

module SqueezeRing(od, id, h, notchAngle = 13, wingHoleDiameter = 4.52, numWingHoles = 1) {
    wingWidth = wingHoleDiameter * 3.5;
    ringWallThick = (od - id) / 2;
    wingDepth = ringWallThick * 2;
    wingHoleSpacing = h / numWingHoles;
    wingHoleBottomEdgeDistance = wingHoleSpacing / 2;
    wingHoleZPos = [ for (z = [ wingHoleBottomEdgeDistance : wingHoleSpacing : h - wingHoleDiameter ]) z ];
    wingHoleSlotWidth = wingHoleDiameter * 2;
    
    nutSocketSize = 9;
    nutSocketDepth = wingDepth * 0.4;
    
    // Ring with notch in it
    module BaseRing() {
        rotate([ 0, 0, notchAngle/2 ])
            rotate_extrude(angle=360-notchAngle)
                translate([ id/2, 0 ])
                    square([ ringWallThick, h ]);
    }
    BaseRing();
    
    // "Wings"
    module Wing(nutSocket = false) {
        nutSocketOffsetFactor = 0.65;
        translate([ id / 2, -wingDepth / 2, 0 ])
            difference() {
                cube([ wingWidth + ringWallThick, wingDepth, h ]);
                if (nutSocket)
                    translate([ ringWallThick + wingWidth * nutSocketOffsetFactor, 100 + wingDepth - nutSocketDepth, h/2 ])
                        rotate([ 90, 0, 0 ])
                            linear_extrude(100)
                                RegularPolygon(6, nutSocketSize / regularPolygonInnerRadiusMultiplier(6) / 2, true);
            };
    }
    module Wings() {
        aOff = notchAngle/2 + (wingDepth/2) / (PI * od) * 360;
        rotate([ 0, 0, aOff ])
            Wing(true);
        rotate([ 0, 0, -aOff ])
            Wing(false);
    }
    module WingHoles() {
        for (z = wingHoleZPos)
            translate([ od / 2 + wingWidth / 2, 0, z ])
                rotate([ 90, 0, 0 ])
                    cylinder(r=wingHoleDiameter/2, h=1000, center=true);
    }
    module WingHoleSlots() {
        for (z = wingHoleZPos)
            translate([ od / 2 + wingWidth / 2, 0, z ])
                rotate([ 90, 0, 0 ])
                    linear_extrude(1000)
                        union() {
                            square([ wingHoleSlotWidth - wingHoleDiameter, wingHoleDiameter ], center=true);
                            translate([ -(wingHoleSlotWidth - wingHoleDiameter) / 2, 0 ])
                                circle(r=wingHoleDiameter/2);
                            translate([ (wingHoleSlotWidth - wingHoleDiameter) / 2, 0 ])
                                circle(r=wingHoleDiameter/2);
                        };
    }
    difference() {
        Wings();
        WingHoles();
        WingHoleSlots();
    };
}

module HoseHolder(id1 = 24, id2 = 28, h = 50, thick = 4) {
    difference() {
        cylinder(r1 = id1 / 2 + thick, r2 = id2 / 2 + thick, h = h);
        cylinder(r1 = id1 / 2, r2 = id2 / 2, h = 2*h);
    };
}

squeezeRingId = 52;
squeezeRingOd = squeezeRingId + 10;
squeezeRingHeight = 13;

hoseHolderId1 = 31;
hoseHolderId2 = 32.5;
hoseHolderHeight = 52;
hoseHolderThick = 3;
hoseHolderOd1 = hoseHolderId1 + 2 * hoseHolderThick;
hoseHolderOd2 = hoseHolderId2 + 2 * hoseHolderThick;

hoseHolderClearance = 18;
hoseHolderPosX = -squeezeRingOd/2 - hoseHolderClearance - hoseHolderOd2 / 2;

glueFlangeRadius = hoseHolderId1/2 + 10;
glueFlangeHeight = 2;


module SpindleAttachment() {

    SqueezeRing(od=squeezeRingOd, id=squeezeRingId, h=squeezeRingHeight);

    translate([ hoseHolderPosX, 0, 0 ])
        HoseHolder(id1=hoseHolderId1, id2=hoseHolderId2, h=hoseHolderHeight, thick=hoseHolderThick);

    // Connection between hose holder and squeeze ring
    difference() {
        union() {
            linear_extrude(squeezeRingHeight)
                polygon([
                    [ 0, squeezeRingOd/2 ],
                    [ hoseHolderPosX, hoseHolderOd1/2 ],
                    [ hoseHolderPosX, -hoseHolderOd1/2 ],
                    [ 0, -squeezeRingOd/2 ]
                ]);
            // glue flange
            translate([ hoseHolderPosX, 0 ])
                difference() {
                    cylinder(r=glueFlangeRadius, h=glueFlangeHeight);
                    for (y = [ glueFlangeRadius, -glueFlangeRadius ])
                        translate([ 0, y, 0 ])
                            cylinder(r=indexingPinRadius, h=1000);
                };
        };
        cylinder(r = squeezeRingId/2, h = squeezeRingHeight * 2);
        translate([ hoseHolderPosX, 0, 0 ])
            cylinder(r1 = hoseHolderId1 / 2, r2 = hoseHolderId2 / 2, h = 2*hoseHolderHeight);
    };

}

extnTubeBaseWidth = 51;
extnTubeBaseLength = 51;
extnTubeBaseHeight = 2;
extnTubeId1 = 31;
extnTubeOd1 = extnTubeId1 + 4;
extnTubeId2 = 14;
extnTubeOd2 = extnTubeId2 + 4;

sideDetentRadius = 1;

clipBottomHeight = 4;

module ExtensionTube(h = 64) {
    // Distance from bottom of squeeze ring to bottom-most point of tube
    maxTubeZOffset = h;
    tubeId1 = extnTubeId1;
    //tubeId1 = 18;
    tubeOd1 = extnTubeOd1;
    tubeId2 = extnTubeId2;
    tubeOd2 = extnTubeOd2;
    //tubeLen = 600;
    tubeLen = sqrt(pow(hoseHolderPosX, 2) + pow(maxTubeZOffset, 2));
    //bitSlotDiameter = 20;
    bitSlotDiameter = tubeOd2 + 5;
    clipLength = 8;
    clipLengthClearance = 1;
    clipThick = 1.5;
    clipSocketDepth = clipThick + sideDetentRadius + 0.5;
    
    tubeAngle = 90 - atan(maxTubeZOffset / abs(hoseHolderPosX));
    
    // Base and glue flange
    module Base() {
        difference() {
            translate([ 0, 0, extnTubeBaseHeight/2 ])
                cube([ extnTubeBaseLength, extnTubeBaseWidth, extnTubeBaseHeight ], center=true);
            cylinder(r=tubeId1/2, h=1000);
            // Clip sockets
            mirror([ 1, 0, 0 ])
                for (y = [-extnTubeBaseWidth/2, extnTubeBaseWidth/2 - clipSocketDepth])
                    translate([ -clipLength, y, 0 ])
                        cube([ clipLength + clipLengthClearance + sideDetentRadius, clipSocketDepth, 1000 ]);
        };
        // Clips
        module SideClip() {
            translate([ -clipLength, -extnTubeBaseWidth/2, 0 ])
                cube([ clipLength + sideDetentRadius, clipThick, extnTubeBaseHeight ]);
            translate([ 0, -extnTubeBaseWidth/2, 0 ])
                difference() {
                    cylinder(r=sideDetentRadius, h=extnTubeBaseHeight, $fn=20);
                    translate([ -500, 0, 0 ])
                        cube([ 1000, 1000, 1000 ]);
                };
       };
       mirror([ 1, 0, 0 ])
           union() {
               SideClip();
               mirror([ 0, 1, 0 ]) SideClip();
           };
    }
    //translate([ 0, 0, -extnTubeBaseHeight ])
        //Base();
    
    // Hemispherical connecting bit
    module ConnectingSphere() {
        intersection() {
            difference() {
                sphere(r=tubeOd1/2);
                sphere(r=tubeId1/2);
            };
            translate([ -500, -500, 0 ])
                cube([ 1000, 1000, 1000 ]);
        };
    }
    
    module HollowTubeOnly() {
        difference() {
            cylinder(r1=tubeOd1/2, r2=tubeOd2/2, h=tubeLen);
            cylinder(r1=tubeId1/2, r2=tubeId2/2, h=tubeLen);
        };
    }
    
    module Tube() {

        Base();
        
        translate([ 0, 0, extnTubeBaseHeight ])
            intersection() {
                difference() {
                    union() {
                        //Base();
                        ConnectingSphere();
                        // Outer tube
                        rotate([ 0, tubeAngle, 0 ])
                            HollowTubeOnly();
                    };
                    // Inner tube
                    rotate([ 0, tubeAngle, 0 ])
                        cylinder(r1=tubeId1/2, r2=tubeId2/2, h=tubeLen);
                    // Inner connecting sphere (remove difference() artifact)
                    sphere(r=tubeId1/2);
                };
                
                translate([ -500, -500, 0 ])
                    cube([ 1000, 1000, maxTubeZOffset ]);
            };

    }
    
    translate([ -hoseHolderPosX, 0, 0 ])
        difference() {
            translate([ hoseHolderPosX, 0, 0 ])
                Tube();
            // Bit slot
            cylinder(r=bitSlotDiameter/2, h=1000);
            translate([ 0, -bitSlotDiameter/2, 0 ])
                cube([ 1000, bitSlotDiameter, 1000 ]);
        };
}


module ClipOnBase() {
    topWallThick = 2;
    botWallThick = clipBottomHeight;
    sideWallThick = 4;
    vertSlideClearance = 0.2;
    horizSlideClearance = 0.2;
    detentSpacing = 4;
    chamferSize = sideWallThick * 0.75;
    
    size = [ extnTubeBaseLength, extnTubeBaseWidth + 2*sideWallThick + 2*horizSlideClearance, botWallThick + extnTubeBaseHeight + topWallThick + 2*vertSlideClearance ];
    
    //numDetents = floor((size[0] / 2 - sideDetentRadius) / detentSpacing) * 2 - 1;
    numDetents = 5;
    detentPos = [ for (i = [ -(numDetents - 1) / 2 : (numDetents - 1) / 2 ]) i * detentSpacing + size[0]/2 ];

    rotate([0, 90, 0])
    union() {
            difference() {
                // Outer block
                cube(size);
                
                // Sliding slot
                translate([ -500, sideWallThick, botWallThick ])
                    cube([ 1000, extnTubeBaseWidth + 2*horizSlideClearance, extnTubeBaseHeight + 2*vertSlideClearance ]);
                
                // Gap in bottom
                gapDepth = extnTubeOd1 + 2*horizSlideClearance;
                translate([ -500, size[1]/2 - gapDepth/2, 0 ])
                    cube([ 1000, gapDepth, botWallThick ]);
                
                // Central hole for air flow
                translate([ size[0]/2, size[1]/2, 0 ])
                    cylinder(r=hoseHolderId1/2, h=1000);
                
                // Detents
                for (y = [ sideWallThick+horizSlideClearance, size[1]-sideWallThick-horizSlideClearance ])
                    for(x = detentPos)
                        translate([ x, y, botWallThick ])
                            cylinder(r=sideDetentRadius, h=extnTubeBaseHeight + 2*vertSlideClearance, $fn=20);
                
                // Circular mark for aligning glue flange
                translate([size[0] / 2, size[1] / 2, size[2] - 0.2])
                    union() {
                        difference() {
                            cylinder(r=glueFlangeRadius + 0.5, h=0.2);
                            cylinder(r=glueFlangeRadius, h=1000);
                        };
                    };
                
                // Chamfers
                translate([ 0, 0, botWallThick ])
                    linear_extrude(extnTubeBaseHeight + 2*vertSlideClearance)
                        polygon([
                            [0, sideWallThick - chamferSize],
                            [chamferSize, sideWallThick],
                            [0, sideWallThick]
                        ]);
                translate([ 0, 0, botWallThick ])
                    linear_extrude(extnTubeBaseHeight + 2*vertSlideClearance)
                        polygon([
                            [0, size[1] - sideWallThick + chamferSize],
                            [chamferSize, size[1] - sideWallThick],
                            [0, size[1] - sideWallThick]
                        ]);
            };
        // Indexing pins
        indexingPinClearance = 0.5;
        translate([ size[0]/2, size[1]/2, 0 ])
            intersection() {
                for (y = [ glueFlangeRadius, -glueFlangeRadius ])
                    translate([ 0, y, size[2] ])
                        cylinder(r=indexingPinRadius - indexingPinClearance, h=indexingPinHeight);
                cylinder(r=glueFlangeRadius, h=1000);
            };
    };
}


SpindleAttachment();
//ExtensionTube(h=52);
//ExtensionTube(h=62);
//ExtensionTube(h=72);
//ExtensionTube(h=82);
//ClipOnBase();
