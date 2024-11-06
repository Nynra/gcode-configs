# Gcode Configs

Some gcode configurations for my P1S printer. Bambu makes amazing printers but they put significantly less effort in the gcode. The default gcode is very slow and wastes a lot of filament and sometimes even makes moves that are not necessary for this model (for example move to the front left is for the X1C QR code scan...).

## Configs

The raw folder contains the gcode straight from the slicer. The gcode is not modified in any way. The following gcode configurations are each in their own folder.

### Default

The default start and stop gcode for the P1S printer. While the gcode is very reliable, the start takes about 6 min to complete and wastes a lot of filament during purging.

### Fast

The fast start and stop gcode for the P1S printer. The start takes about 3 min to complete and improves on the following:

- Preperation order is more efficient (preheating during movement, etc.)
- Purging is reduced to a minimum
- The bed is not leveled before every print (only if the tick mark in the slicer is set)

While the fast gcode is much faster and uses less filament, it is less reliable than the default gcode and skips some pre-print tests like the skirt line. If you have problems with the fast gcode, try the default gcode.

### Optimized

The optimized start and stop gcode is a balance between the default and fast gcode. The start takes about 4 min to complete and improves on the same points as the fast gcode, except that the pre-print tests are not skipped.

## Bambu Gcode commands

Bambu has some mistery commands in the gcode that are not documented in the Marlin Gcode Documentation. Here are some of them:

- `M620` ? has something to do with the AMS
- `Tn` where `n` is an integer number. ? also has something to do with the AMS
- `M621.1 E` ? has something to do with the AMS, maybe loading filament to the hotend
- `M622` controlls the camera and has the following attributes and subcommands:
  Attributes:
  - `Jn` where `n` is an integer number. ?
  Subcommands:
  - `M622.1 S1`? something to do with firmware being on or off
- `M623` Set the timelapse record flag. This should be set once in the start and once in the stop gcode
- `M970.3 Q1 A7 B30 C80 H15 K0`, `M970.3 Q0 A7 B30 C90 Q0 H15 K0` ? no idea
- `M974 Q1 S2 P0`, `M974 Q0 S2 P0` ? no idea
- `M975 Sn` where `n` is either `0` or `1`. This command is used to enable or disable the vibration suppression.
- `M991 S0 P-1` end smooth timelapse at safe pos
- `M1002 gcode_claim_action : n` where `n` is an integer number. This command is used to announce the printer state on the screen, the following states are supported:
  - `0` : Clear the screen
  - `1` : Display `Auto bed leveling`
  - `2` : Display `Heatbed preheating`
  - `3` : Dispaly `Sweeping XY mech mode`
  - `4` : ?
  - `5` : ?
  - `6` : ?
  - `7` : Display `Heating hotend`
  - `8` : ?
  - `9` : ?
  - `10` : ?
  - `11` : ?
  - `12` : ?
  - `13` : Display `Homing toolhead`
  - `14` : Display `Cleaning nozzle tip`

- `G380 S2 Zn Fm` where `n` is the distance in mm and `m` is the speed in mm/min. This command is used to move the Z axis without knowing the current location of the bed. CAUTION: This command is dangerous and can damage the printer if used incorrectly.

## General Gcode commands with Bambu flavour

Bambu mostly implements Marlin Gcode but some commands, while having the same name as the Marlin Gcode, have different behaviour. Here are some of them:

- `G28` Home all axes. This command acts as normal but has some additional atributes:
  - `Pn` Where `n` is either `1` or `0`. Use quick homing if `n` is `0`.
  - `Tn` Where `n` is an integer number, this sets the max allowed nozzle temperature
- `G29` Auto bed leveling. This command acts as normal bus has some sub commands:
  - `G29.1 Zn` Where `n` is the distance in mm. This command is used to set the z-trim value.
  - `G29.2 Sn` Where `n` is either `0` or `1`. This command is used to enable or auto bed leveling (ABL).
  `G29` also has some additional atributes:
  - `A` ?use abl mesh?
- `M221` Normally sets flow percentage but in Bambu is has something to do with soft endstops.

## Resources

- [The fast gcode written by Schmudi](https://forum.bambulab.com/t/bbl-p1s-organized-start-and-end-gcode/38795/19)
- [Marlin Gcode Documentation](https://marlinfw.org/meta/gcode/)
- BambuLab default start and stop gcode for P1S
