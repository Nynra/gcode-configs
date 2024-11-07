;===== machine: P1S                 =====
;===== date: 20241106               =====
;===== Version 1                    =====
;===== start G-Code by Nynra        =====
;===== !!! use at your own risk !!! =====
;===== P1S firmware: 1.05.02        =====
;===== AMS firmware: 00.00.06.40    =====
;========================================
;Steps
;- Reset the machine settings
;- Prepare for operation to save time
;   - Turn on the fans
;   - Preheat the bed and nozzle (low temp)
;   - Turn up the fans to prevent PLA jamming
;   - Fast home XYZ
;- Load the material (AMS)
;- Turn on filament runout detection
;- Purge the nozzle
;   - Heat to common purge temp
;   - Move to trash position
;   - Wait for the temp to be reached
;   - Purge the nozzle
;   - Lower the nozzle to prevent oozing
;- Quick wipe the nozzle
;- Heat the nozzle to the correct temp
;- Home XYZ
;- Level the bed (if checkbox is checked)
;- Lower the nozzle temp to prevent oozing during wipe
;- Full wipe the nozzle
;- Home XY
;- Set the nozzle to the correct temp
;- Enable the correction methods
;   - Enable the vibration suppression
;   - Enale the mechanical mode suppression
;   - Turn on ABL
;- Print the load line (to remove the last bit of oozing)
;===================================================
;########### reset machine status ##################
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

;########### prepare for operation ##################
;=============turn on fans  =================
M106 P1 S125 ; Part fan
M106 P2 S100 ; AUX Fan
M106 P3 S125; Chamber fan BAMBU
M710 A1 S255; MC-board fan automatic

;===== heatbed preheat and home ====================
M1002 gcode_claim_action : 2
M140 S[bed_temperature_initial_layer_single] ;set bed temp
M104 S150 ; set extruder temp - low value to avoid blobs while homing
; M104 S{nozzle_temperature_range_high[initial_extruder]}-30 ;set extruder temp-30
M190 S[bed_temperature_initial_layer_single] ;wait bed temp
M1002 gcode_claim_action : 13
G28 X Y
G1 X128 Y128 F12000
G28 Z P0 T300; home z with low precision,permit 300deg temperature
; G28 T300; Homing - permit 300deg temperature
M106 P1 S125 ; Part fan, stopped by G28
M400 ; wait for finish homing

;===== prepare print temperature and material ==========
M1002 gcode_claim_action : 7
M109 S240; set purge temp - only use if different type of filament in use (ABS/PLA/ASA/...)
; M104 S{nozzle_temperature_range_high[initial_extruder]} ;wait extruder temp
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
    G1 X65 F5000
    M400

    M1002 gcode_claim_action : 1
    G29 A X{first_layer_print_min[0]} Y{first_layer_print_min[1]} I{first_layer_print_size[0]} J{first_layer_print_size[1]}
    M400
    M500 ; save cali data

M623

;=============turn on fans to prevent PLA jamming=================
{if filament_type[initial_extruder]=="PLA"}
    {if (bed_temperature[initial_extruder] >45)||(bed_temperature_initial_layer[initial_extruder] >45)}
        M106 P3 S180
    {endif};Prevent PLA from jamming
{endif}

; ############ load the material (AMS) ############
; move to the bin
; G1 x65 F9000
; M400
G1 X65 Y265 F9000

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
M412 S1 ;turn on filament runout detection

;===== purge extruder and nozzle ==========
M1002 gcode_claim_action : 14
M104 S240 ;set nozzle to common flush temp - only for different materials
; M109 S{nozzle_temperature_range_high[initial_extruder]}+5 ;set extruder temp+5
M106 P1 S0 ; Part fan off
G92 E0
; 30MM INSTEAD OF 40MM
G1 E30 F200 ; clean 40mm
M400
G92 E0
G1 E-1.5 F300 ; retract
M104 S[nozzle_temperature_initial_layer]
G1 E1.5 F300 ; extrude
G92 E0
; 30MM INSTEAD OF 50MM
G1 E30 F400 ; clean 50mm
M400
; M106 P1 S255 ; Part fan full
M106 P1 S125 ; Part fan on 50%
M400 S4
G92 E0
G1 E-0.5 F300 ; retract
M106 P1 S200
M400 S2
G92 E0
G1 E-0.3 F300 ; retract
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
G1 X65 F15000
M400
M106 P1 S255
G92 E0

M975 S1 ; turn on vibration supression
M106 P1 S125 ; Part fan on

;===== for Textured PEI Plate , lower the nozzle as the nozzle was touching topmost of the texture when homing ==
G29.1 Z{-0.05} ; for Textured PEI Plate; personal PEI plate - corrct value to your own plate

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
G1 X65 F5000
M400

;======== wait extrude temperature and prefill =============
M106 P3 S220 ; Chamber Fan BAMBU
; M106 P3 S25 ; Chamber Fan NOCTUA
G29.2 S1 ; turn on ABL
M1002 gcode_claim_action : 2
M190 S[bed_temperature_initial_layer_single] ;set bed temp
M1002 gcode_claim_action : 7
M109 S[nozzle_temperature_initial_layer] ;set extruder temp
M1002 gcode_claim_action : 0
M975 S1 ; turn on mech mode supression
G92 E0
G92 E0.2 F200
G92 E0

;===== mech mode fast check============================
G1 X128 Y128 Z10 F20000
M400 P200
M970.3 Q1 A7 B30 C80  H15 K0
M974 Q1 S2 P0

G1 X128 Y128 Z10 F20000
M400 P200
M970.3 Q0 A7 B30 C90 Q0 H15 K0
M974 Q0 S2 P0

M975 S1

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