;===== machine: P1S =====
;===== date: 20240229 =====
;===== Version 6.0 - FINAL =====
;===== End G-Code by Schmudi =====
;===== !!! Use at your own risk !!! =====
;===================================================
M400 ; wait for buffer to clear
M17 X1.2 Y1.2 Z0.75 ; set motor current to default
M204 S10000 ; init ACC set to 10m/s^2
M1002 set_gcode_claim_speed_level : 5
G92 E0 ; zero the extruder
G1 E-0.3 F600 ; retract, 0,8mm retract is done automatically by Slicer
M104 S175 ; Lower nozzle temp
G1 Z{max_layer_z + 5} F900 ; lower z a little
G1 X65 Y265 F9000 ; move to the bin 
; G1 X65 Y255 F12000 ; move to safe pos
M400 S5; wait
G92 E0 ; zero the extruder
G1 E-0.3 F700 ; retract
M400 S5; wait
G92 E0 ; zero the extruder
G1 Y265 F3000
M140 S0 ; turn off bed
; G1 X100 F12000 ; wipe
; G1 X60 Y265 F12000
M1002 gcode_claim_action : 4

;====== cut filament =======
M620 S255
; G1 X20 Y50 F12000
; G1 Y-3
T255
; G1 X65 F12000
; G1 Y265
M621 S255; pull back filament to AMS

;===== wipe nozzle =======
M104 S0 ; turn off hotend
M1002 gcode_claim_action : 14
G1 X100 F18000 ; first wipe
G29.2 S0 ; turn off ABL
G1 X60 Y265
G1 X100 F5000; second wipe
G1 X70 F15000
G1 X100 F5000
G1 X70 F15000
G1 X100 F5000
G1 X70 F15000
G1 X100 F5000
G1 X70 F15000
G1 X90 F5000
G0 X60 F15000
M400
G29.2 S1 ; turn on ABL
M975 S1 ; turn on vibration supression
M400
M1002 gcode_claim_action : 0
M621 S255; AMS
M104 S0 ; turn off hotend

;===== stop camera =======
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
M400 ; wait all motion done
M991 S0 P-1 ;end smooth timelapse at safe pos
M400 S3 ;wait for last picture to be taken
M623; end of “timelapse_record_flag”
M400

;===== lower heatbed =======
M17 S
M17 Z0.4 ; lower z motor current to reduce impact if there is something in the bottom
{if (max_layer_z + 100.0) < 250}
    G1 Z{max_layer_z + 100.0} F600
    G1 Z{max_layer_z +98.0}
{else}
    G1 Z249 F600
    G1 Z247
{endif}
M400 P100
G90
; Stay above the bin
; G1 X128 Y250 F3600

;===== reset printer =======
M220 S100 ; Reset feedrate magnitude
M201.2 K1.0 ; Reset acc magnitude
M73.2 R1.0 ;Reset left time magnitude
M1002 set_gcode_claim_speed_level : 0

;===== fast cool down chamber ==========
M106 P1 S100; part cooling fan
M106 P2 S125; Aux fan
; M106 P3 S25; Chamber fan NOCTUA
M106 P3 S125; Chamber fan BAMBU
M400 S30; 30 seconds fast cool down time

;===== second cool down ==========
; M106 P1 S100; part cooling fan
; M106 P2 S100; Aux fan
; M106 P3 S25; Chamber fan NOCTUA
; M106 P3 S125; Chamber fan BAMBU
; M400 S120; 120 second cool down time

;===== switch off machine ==========
M106 P1 S0; part cooling fan off
M106 P2 S0; Aux fan off
M106 P3 S0; Chamber fan off
M710 S0; MC-board fan off
M17 X0.8 Y0.8 Z0.5 ; lower motor current
M1002 gcode_claim_action : 0