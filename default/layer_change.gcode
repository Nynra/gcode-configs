; layer num/total_layer_count: {layer_num+1}/[total_layer_count]
M622.1 S1 ; for prev firware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1

{if timelapse_type == 0} ; timelapse without wipe tower
    M971 S11 C10 O0
{elsif timelapse_type == 1} ; timelapse with wipe tower
    G92 E0
    G1 E-[retraction_length] F1800
    G17
    G2 Z{layer_z + 0.4} I0.86 J0.86 P1 F20000 ; spiral lift a little
    G1 X65 Y245 F20000 ; move to safe pos
    G17
    G2 Z{layer_z} I0.86 J0.86 P1 F20000
    G1 Y265 F3000
    M400 P300
    M971 S11 C11 O0
    G92 E0
    G1 E[retraction_length] F300
    G1 X100 F5000
    G1 Y255 F20000
{endif}

M623
; update layer progress
M73 L{layer_num+1}
M991 S0 P{layer_num} ;notify layer change