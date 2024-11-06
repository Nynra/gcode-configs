M620 S[next_extruder]A
M204 S9000
{if toolchange_count > 1 && (z_hop_types[current_extruder] == 0 || z_hop_types[current_extruder] == 3)}
    G17
    G2 Z{z_after_toolchange + 0.4} I0.86 J0.86 P1 F10000 ; spiral lift a little from second lift
{endif}
G1 Z{max_layer_z + 3.0} F1200


; Save/Pullback XX mm filament before cut (as this small part of filament is not yet in the melting area)
; This value may need to be adjusted or removed and I cant guarantee that it will be good choice for all situation
; If modified search and replace all occurrences of "flush_length_1 - xx" by "flush_length_1 - yy (and flush_length_2 3 4 ...)"
G92 E0
G1 E-15 F1800 ;May need to be low as it can make random clog/underextrusions 


;Set fan 1 (part cooling) to 100%
;- try to reduce filament spillage while cutting filament and until hotend reach purge bucket;
;- this also make the filament purged more brittle
;- I was not able to determine the best value : 
;   * lower value make could sticky blobs, more chance that they pop out of the purge bucket orclog it
;   * higer value make purged filament like spagetti, and took a lots more space
M106 P1 S256
M106 P2 S0 ; Auxiliary fan set to zéro

;Fastly go near the filament cutter pusher
G1 X54 F24000
G1 Y0 F24000

{if toolchange_count == 2}
    ; get/set travel path for change filament
    M620.1 X[travel_point_1_x] Y[travel_point_1_y] F24000 P0 ;X=54 Y=0 => probably cutter
    M620.1 X[travel_point_2_x] Y[travel_point_2_y] F24000 P1 ;X=54 Y=0 => probably cutter
    M620.1 X[travel_point_3_x] Y[travel_point_3_y] F24000 P2 ;X=54 Y=245 (travel_point_3_y = 245) => probably purge bucket
{endif}

M620.1 E F{old_filament_e_feedrate * 3}
T[next_extruder] ; Cut the filament, purge the remaining old filament, unload old filament & load new filament
M620.1 E F{new_filament_e_feedrate * 3}

M400

;  Purge filament by pulse : the main change from original code is that here :
; - we are using constante time pause between pulse rather than a proportional time based on purge volume. Constant pulse pauses use a lot less time.
; - we use purge filament flow rate higher, it is safe as we are making little pause that let the plastic get molted more before extruding each pulse
{if next_extruder < 255}
    M104 S[nozzle_temperature_range_high] ;Set filament temperature to high
    M106 P1 S50 ;set fans to 50% to enable filament to clump
    M106 P2 S50 ;set fans to 50% to enable filament to clump
    G92 E0
    G1 E{new_retract_length_toolchange + 13} F200 ;Filament is pushed back in 13 mm + the retract amount from the tool change. 
    G1 E2 F20       ;Filament is pushed back in 2 mm but slower.
    G92 E0
    M400; this is needed to make sure the higher temperature is used while flushing

    ; FLUSH_START
    {if (flush_length_1 + flush_length_2 + flush_length_3 + flush_length_4 - 10) > 23.7}
        G1 E22.7 F{old_filament_e_feedrate * 1.2} ; do not need pulsatile flushing for start part
        G1 E-2 F1800 ;retract a little to dislodge stuck filament in the nozzle
        G1 E2 F300
        G1 E0.2 F120
        G1 E{((flush_length_1 + flush_length_2 + flush_length_3 + flush_length_4 - 10) - 22.7) * 0.25} F{old_filament_e_feedrate * 1.2}
        G1 E-2 F1800
        G1 E2 F300
        G1 E0.2 F120
        G1 E{((flush_length_1 + flush_length_2 + flush_length_3 + flush_length_4 - 10) - 22.7) * 0.25} F{new_filament_e_feedrate * 1.2}
        G1 E-2 F1800
        G1 E2 F300
        G1 E0.2 F120
        G1 E{((flush_length_1 + flush_length_2 + flush_length_3 + flush_length_4 - 10) - 22.7) * 0.25} F{new_filament_e_feedrate * 1.2}
        G1 E-2 F1800
        G1 E2 F300
        G1 E0.2 F120
        G1 E{((flush_length_1 + flush_length_2 + flush_length_3 + flush_length_4 - 10) - 22.7) * 0.25} F{new_filament_e_feedrate * 1.2}
        G1 E-2 F1800
        G1 E2 F300
        G1 E0.2 F120
    {else}
        G1 E{(flush_length_1 + flush_length_2 + flush_length_3 + flush_length_4)} F{old_filament_e_feedrate * 1.2}
    {endif}

    ; FLUSH_END
    M400 ;this is needed to make sure the higher temperature is used while flushing
    M104 S[new_filament_temp] ;Set filament temperature to the printing temperature

    ;The main change here is that we are extruding very slowly to let time for pressure to be released from the nozzle in addition to the 1 mm extrusion
    ;This help (IMHO and based on my tests) in making using a purge tower useless
    G1 E1 F30 ; Compensate/slow down for filament spillage / pressure during two second
    ; FLUSH_END

    M400
    M106 P1 S255
    G92 E0
    G1 E-[new_retract_length_toolchange] F1800

    G1 E-0.5

    ;I have no clue of what S3 parameter means
    M400 S3; this one is required : if it is missing time will be counted as "Sparse/Wall or other Print" time, if it is present time will be couted as "Travel" time


    ;The followng comment is a TEST COMMENT
    ;The following line make mess on Bambu Lab printer so it is commented, I don't know why but all 
    ;  following moves speed goes down to a very slow speedwhen using this "G1 Y245 F18000"
    ;G1 Y245 F18000; Actually nozzle seems to be already there but to have a right preview on Bambu Studio it is required to add this move
    ;/END TEST COMMENT

    ;The main change here is that as the filament is cooled and brittle we can (try) to break it before wiping the nozzle
    ;try to break the filament before wiping
    G1 Y250 F18000
    G1 Y235 F18000
    G1 Y250 F18000
    G1 Y235 F18000
    G1 Y265 F18000

    ; shake to put down garbage
    G1 Y260 F20000
    G1 X80 F20000
    G1 X60 F20000
    G1 X80 F20000
    G1 X60 F20000 ;shake to put down garbage

    G1 X70 F20000
    G1 X90 F20000
    G1 Y255 F20000
    G1 X100 F5000
    G1 Y265 F5000
    G1 X70 F15000
    G1 X100 F10000
    G1 Y263 F5000
    G1 X70 F20000
    G1 X100 F15000
    G1 X70 F15000
    G1 X100 F10000
    G1 Y265 F5000
    G1 X70 F20000
    G1 X100 F15000
    G1 X70 F20000
    G1 X100 F15000
    G1 X165 F20000 ;wipe and shake
    G1 Y256 ; move Y to aside, prevent collision

    G1 Z{max_layer_z + 3.0} F3000
    {if layer_z <= (initial_layer_print_height + 0.001)}
        M204 S[initial_layer_acceleration]
    {else}
        M204 S[default_acceleration]
    {endif}
{else}
    G1 X[x_after_toolchange] Y[y_after_toolchange] Z[z_after_toolchange] F18000
{endif}

M621 S[next_extruder]A
G1 E0.5

