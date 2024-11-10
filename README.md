# Gcode Configs

Some gcode configurations for my P1S printer. Bambu makes amazing printers but they put significantly less effort in the gcode. The default gcode is very slow and wastes a lot of filament and sometimes even makes moves that are not necessary for this model (for example move to the front left is for the X1C QR code scan...).

## Gotchas

PLEASE READ BEFORE USE.

The P1S is a great 3D printer but due to the high performance the operator should be aware of some gotchas:

- The bed can get very hot (100C) and the normal operating temperature is around 70C, this means that the bed can burn you if you touch it too soon after the print job is done.
- The extruder head can move quite fast and can be dangerous if you are not careful. Please either pause the print or wait until the print is done (bed should lower to presenting height) before opening the door.
- The extruder head has a bigger XY plane than the bed, this means that the extruder can be outside of the bed area (used for wiping, etc.). Normally this isnt an issue, but when the print is cancelled when the extruder is outside of the bed area, the next Z homing or bed leveling will fail (bed cannot find the nozzle in z range). To fix this, move the extruder head to somewhere within the bed area before starting Z homing or bed leveling.

## Configs

### Default

The default start and stop gcode for the P1S printer. While the gcode is very reliable, the start takes about 6 min to complete and wastes a lot of filament during purging.

### Optimized

The optimized start and stop gcode for the P1S printer. The start takes about 3 min to complete and improves on the following:

- Preperation order is more efficient (preheating during movement, etc.)
- Purging is reduced to a minimum
- Extruder head is stored above the trash bin after the print is done to prevent oozing or the operator touching the hot nozzle by accident when removing the print.

Filament changing is also improved:

- The filament is retracted before the filament change (to prevent oozing and shorten the length of filament that is cut and purged)
- Heating starts before the filament change (to reduce the time the printer is idle)
- The extruder head moved directly to the trash bin.

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
- `M970.3 Q1 A7 B30 C80 H15 K0`, `M970.3 Q0 A7 B30 C90 Q0 H15 K0` Machine self testing, no idea what the attributes do or what is done with the results.
- `M974 Q1 S2 P0`, `M974 Q0 S2 P0` ? no idea
- `M975 Sn` where `n` is either `0` or `1`. This command is used to enable or disable the vibration suppression.
- `M991 S0 P-1` end smooth timelapse at safe pos
- `M1002 gcode_claim_action : n` where `n` is an integer number. This command is used to announce the printer state on the screen, the following states are supported:
  - `0` : Clear the screen
  - `1` : Display `Auto bed leveling`
  - `2` : Display `Heatbed preheating`
  - `3` : Display `Sweeping XY mech mode` (not available on P1S)
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
