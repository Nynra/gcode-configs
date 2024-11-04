;===== machine: P1S =====
;===== date: 20240229 =====
;===== Version 6 - FINAL =====
;===== start G-Code by Schmudi =====
;===== !!! use at your own risk !!! =====
;===== P1S firmware: 1.05.02 =====
;===== AMS firmware: 00.00.06.40 =====
;===================================================
;===== reset machine status =================
G90 ; absolute positioning
M17 X1.2 Y1.2 Z0.75 ; set motor current to default
M290 X40 Y40 Z2.6666666; Use Babystepping
M220 S100 ;Reset Feedrate
M221 S100 ;Reset Flowrate
M73.2   R1.0 ;Reset left time magnitude
M1002 set_gcode_claim_speed_level : 5
M221 X0 Y0 Z0 ; turn off soft endstop to prevent protential logic problem
G29.1 Z{+0.0} ; clear z-trim value
M204 S10000 ; init ACC set to 10m/s^2

;=============turn on fans  =================
M106 P1 S125 ; Part fan
M106 P2 S50 ; AUX Fan
M106 P3 S125; Chamber fan BAMBU
M710 A1 S255; MC-board fan automatic

;===== heatbed preheat and home ====================
M1002 gcode_claim_action : 2
M140 S[bed_temperature_initial_layer_single] ;set bed temp
M104 S100 ; set extruder temp - low value to avoid blobs while homing
M190 S[bed_temperature_initial_layer_single] ;wait bed temp
M1002 gcode_claim_action : 13
; G28 P0 T300; fast Homing - permit 300deg temperature
G28 T300; Homing - permit 300deg temperature
M400 ; wait for finish homing

;===== prepare print temperature and material ==========
M1002 gcode_claim_action : 7
; M109 S250; set purge temp - only use if different type of filament in use (ABS/PLA/ASA/...)
M104 S{nozzle_temperature_range_high[initial_extruder]} ;wait extruder temp
G91
G1 Z10 F1200
G90
M975 S1 ; turn on mech mode supression
G1 X67 F12000
G1 Y240
G1 Y265 F3000

;===== bed leveling ====================
M1002 judge_flag g29_before_print_flag
M622 J1

    M1002 gcode_claim_action : 1
    G29 A X{first_layer_print_min[0]} Y{first_layer_print_min[1]} I{first_layer_print_size[0]} J{first_layer_print_size[1]}
    M400
    M500 ; save cali data

M623

;===== prepare AMS ==========
M1002 gcode_claim_action : 4
M620 M
M620 S[initial_extruder]A   ; switch material if AMS exist
    G1 X120 F12000
    T[initial_extruder]
    G1 X54 F12000
    G1 Y265
    M400
M621 S[initial_extruder]A
M620.1 E F{filament_max_volumetric_speed[initial_extruder]/2.4053*60} T{nozzle_temperature_range_high[initial_extruder]}

;===== purge extruder and nozzle ==========
M1002 gcode_claim_action : 14
M412 S1 ;turn on filament runout detection
; M104 S250 ;set nozzle to common flush temp - only for different materials
M109 S{nozzle_temperature_range_high[initial_extruder]}+5 ;set extruder temp+5
M106 P1 S0 ; Part fan off
G92 E0
G1 E40 F200 ; clean 40mm
M400
G92 E0
G1 E-1.5 F300 ; retract
M104 S[nozzle_temperature_initial_layer]
G92 E0
G1 E50 F400 ; clean 50mm
M400
M106 P1 S255 ; Part fan full
M400 S4
G92 E0
G1 E-0.5 F300
M106 P1 S200
M400 S2
G92 E0
G1 E-0.3 F300
G92 E0
M400 S2
G1 X70 F9000
G1 X76 F15000
G1 X65 F15000
G1 X76 F15000
G1 X65 F15000; shake to put down garbage
G1 X80 F6000
G1 X95 F15000
G1 X80 F15000
G1 X165 F15000
M400
M106 P1 S255
G92 E0

;===== wipe nozzle ===============================
M1002 gcode_claim_action : 14
M975 S1
M106 P1 S255
G1 X65 Y230 F18000
G1 Y264 F6000
G1 X100 F18000 ; first wipe
G29.2 S0 ; turn off ABL
G0 Z5 F12000
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
M400
G1 Z10
G29.2 S1 ; turn on ABL
M975 S1 ; turn on vibration supression
M106 P1 S125 ; Part fan on

;===== nozzle load line ===============================
M975 S1
G90
M83
T1000
G1 X18.0 Y1.0 Z0.8 F18000;Move to start position
M109 S{nozzle_temperature_initial_layer[initial_extruder]}
G1 Z0.2
G0 E2 F300
G0 X240 E15 F{outer_wall_volumetric_speed/(0.3*0.5)     * 60}
G0 Y11 E0.700 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60}
G0 X239.5
G0 E0.2
G0 Y1.5 E0.700
G0 X18 E15 F{outer_wall_volumetric_speed/(0.3*0.5)     * 60}
M400

;===== for Textured PEI Plate , lower the nozzle as the nozzle was touching topmost of the texture when homing ==
curr_bed_type={curr_bed_type}
{if curr_bed_type=="Textured PEI Plate"}
    G29.1 Z{-0.05} ; for Textured PEI Plate; personal PEI plate - corrct value to your own plate
{endif}
{if curr_bed_type=="High Temp Plate"}
    G29.1 Z{-0.00} ; for smooth PEI-plate
{endif}

;======== wait extrude temperature and prefill =============
M106 P3 S220 ; Chamber Fan BAMBU
; M106 P3 S25 ; Chamber Fan NOCTUA
G29.2 S1
M1002 gcode_claim_action : 2
M190 S[bed_temperature_initial_layer_single] ;set bed temp
M1002 gcode_claim_action : 7
M109 S[nozzle_temperature_initial_layer] ;set extruder temp
M1002 gcode_claim_action : 0
M975 S1 ; turn on mech mode supression
G92 E0
G92 E0.2 F200
G92 E0