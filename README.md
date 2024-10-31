# Gcode Configs

Some gcode configurations for my P1S printer

## Default

The default start and stop gcode for the P1S printer. While the gcode is very reliable, the start takes about 6 min to complete and wastes a lot of filament during purging.

## Fast

The fast start and stop gcode for the P1S printer. The start takes about 3 min to complete and improves on the following:

- Preperation order is more efficient (preheating during movement, etc.)
- Purging is reduced to a minimum
- The bed is not leveled before every print (only if the tick mark in the slicer is set)

While the fast gcode is much faster and uses less filament, it is less reliable than the default gcode and skips some pre-print tests like the skirt line. If you have problems with the fast gcode, try the default gcode.

## Optimized

The optimized start and stop gcode is a balance between the default and fast gcode. The start takes about 4 min to complete and improves on the same points as the fast gcode, except that the pre-print tests are not skipped.

## Resources

- [The fast gcode written by Schmudi](https://forum.bambulab.com/t/bbl-p1s-organized-start-and-end-gcode/38795/19)
- [Marlin Gcode Documentation](https://marlinfw.org/meta/gcode/)
- BambuLab default start and stop gcode
