# Spindle Vacuum Attachment

This is a clamp-on spindle attachment for a vacuum hose, with a few extra features.  Most notably, the component that extends down to the tool is removable and can be changed and adjusted toollessly, allowing for different vacuum configurations depending on the tool in the spindle.

## Features

* Written in OpenSCAD, so parameters can be easily customized.
* Spindle hose tubes easily slide into clips, supporting toolless removal.  Allows easily removing spindle tubes for different tools and easier tool changes in cramped spaces.
* Tube can be laterally adjusted closer to or farther from the spindle with detents.
* Clamps directly onto spindle motor.
* Spindle clamp nut is captive for easier assembly.

## Parts

This vacuum attachment prints in 3 parts:

1. The clamp fits around the spindle motor and tightens down using a screw and nut.  It includes a receptacle for the vacuum hose.  The receptacle is slightly tapered so the vacuum hose wedges in.  With some adjustments, it could also be used on the inside of the vacuum hose with a hose clamp.
2. The clip is glued onto the clamp.  This is what the tubes slide into.
3. The spindle vacuum tube, which slides into the clip and attaches with a detent.  More than one of these can be printed, and they can be easily exchanged as needed.

## Printing

Check the OpenSCAD file to ensure the default parameters will work for you (and if not, edit them and export the new STLs).  The most important parameters to watch for are the spindle motor diameter for the clamp (called squeezeRingId, defaulting to 52mm or 2in) and the size of the attached vacuum hose (hoseHolderId1 and hoseHolderId2, defaulting to 31mm and 32.5mm, for a slight taper).  Changing these settings may require others to be changed.

You'll need to print the clamp, the clip, and at least one tube.  I recommend printing in PETG for additional strength (and because the detent clips require a bit of flexibility).  The print settings shouldn't be critical.

## Post-printing

The clip and clamp need to be glued together; superglue works well.  The clip contains two slightly raised areas that align to corresponding cavities in the clamp.  This ensures proper alignment.

The clamp needs to be attached to the spindle motor using a screw and a nut.

A bit of grease on the clip and tube detents can help them fit together easily.

