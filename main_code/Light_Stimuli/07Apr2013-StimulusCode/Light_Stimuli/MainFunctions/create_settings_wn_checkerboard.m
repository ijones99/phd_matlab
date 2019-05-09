function create_settings_wn_checkerboard

pixTransferFuncDir = '../DataFiles/';
% load pixel transfer function
load(fullfile(pixTransferFuncDir, 'lookupTbMean_ND2_norm.mat'));

Settings.STIM_NAME = 'StimParams_10_Wn100PerCheckerboard.mat'
% Settings.UM_TO_PIX_CONV =  1.627;

Settings.BLACK_VAL = 0;
Settings.MID_GRAY_VAL = apply_projector_transfer_function_nearest_neighbor(255*4/8,lookupTbMean_ND2_norm)% 
Settings.DARK_GRAY_75PER_VAL = apply_projector_transfer_function_nearest_neighbor(255*2/8,lookupTbMean_ND2_norm)% 

Settings.SURR_DIMS =  [750 750];
Settings.WN_EDGE_LENGTH = [750 750];
Settings.WN_STIM_RES_PX = 25;
Settings.STIM_DUR =  45;
Settings.STIM_FREQ = 20;
outputFileName =  'StimParams_10_Wn100PerCheckerboard.mat';
save(outputFileName, 'Settings');

end

