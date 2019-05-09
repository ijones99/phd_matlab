function angleOutChip = std2chip_angle_conversion(angleIn)
% angleOutChip = STD2CHIP_ANGLE_CONVERSION(angleIn)

angleOutPsych = psychtoolbox.standard2physch_angle_transfer_function_v2(angleIn);
angleOutChip = beamer.beamer2chip_angle_transfer_function_v2(angleOutPsych);



end