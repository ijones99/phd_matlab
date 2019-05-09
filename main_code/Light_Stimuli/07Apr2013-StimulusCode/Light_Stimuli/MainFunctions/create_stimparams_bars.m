function create_stimparams_bars

pixTransferFuncDir = '../DataFiles/';
% load pixel transfer function
load(fullfile(pixTransferFuncDir, 'lookupTbMean_ND2_norm.mat'));

Settings.STIM_NAME = 'StimParams_Bars.mat'
Settings.UM_TO_PIX_CONV =  1.627;
load(Settings.STIM_NAME)
clear Settings
Settings.STIM_NAME = 'StimParams_Bars.mat'
Settings.UM_TO_PIX_CONV =  1.627;

Settings.BLACK_VAL = 0;
Settings.WHITE_VAL = apply_projector_transfer_function_nearest_neighbor(255,lookupTbMean_ND2_norm);
Settings.MID_GRAY_VAL = apply_projector_transfer_function_nearest_neighbor(255*4/8,lookupTbMean_ND2_norm);%163;
Settings.SURR_DIMS = [1200 1200];
Settings.BAR_REPEATS = 20;
Settings.BAR_PAUSE_BTWN_REPEATS = 1;
Settings.BAR_DRIFT_VEL_PX = 750;
Settings.BAR_BRIGHTNESS = [ ...
    apply_projector_transfer_function_nearest_neighbor(255*5/8,lookupTbMean_ND2_norm);
    apply_projector_transfer_function_nearest_neighbor(255*3/8,lookupTbMean_ND2_norm)...
]
Settings.BAR_DRIFT_ANGLE = [0 45 90 135 180 225 270 315];
Settings.BAR_HEIGHT_PX = 187.5000;
Settings.BAR_WIDTH_PX = 187.5000;

save(Settings.STIM_NAME, 'Settings');

end

