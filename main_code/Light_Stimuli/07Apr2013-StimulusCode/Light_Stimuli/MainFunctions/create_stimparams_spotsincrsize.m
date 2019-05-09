function create_stimparams_spotsincrsize

pixTransferFuncDir = '../DataFiles/';
% load pixel transfer function
load(fullfile(pixTransferFuncDir, 'lookupTbMean_ND2_norm.mat'));

Settings.STIM_NAME = 'StimParams_SpotsIncrSize.mat'
Settings.UM_TO_PIX_CONV =  1.627;

load(Settings.STIM_NAME)
clear Settings
Settings.STIM_NAME = 'StimParams_SpotsIncrSize.mat'
Settings.BLACK_VAL = 0;
Settings.WHITE_VAL = apply_projector_transfer_function_nearest_neighbor(255,lookupTbMean_ND2_norm);
Settings.MID_GRAY_VAL = apply_projector_transfer_function_nearest_neighbor(255*4/8,lookupTbMean_ND2_norm);
Settings.MID_GRAY_DECI = Settings.MID_GRAY_VAL/255;
Settings.SURR_DIMS = [750 750];

Settings.DOT_INTER_SUB_SESSION_WAIT = 1;
Settings.DOT_DOT_SHOW_TIME = 1;
Settings.DOT_BRIGHTNESS_VAL = [Settings.WHITE_VAL 0];


save(Settings.STIM_NAME, 'Settings', 'StimMats');

end

