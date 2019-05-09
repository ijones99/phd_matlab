function create_settings_marching_sqr

pixTransferFuncDir = '../DataFiles/';
% load pixel transfer function
load(fullfile(pixTransferFuncDir, 'lookupTbMean_ND2_norm.mat'));

Settings.STIM_NAME =  'StimParams_Marching_Sqr.mat';

Settings.umToPixConv = 1.627;
Settings.blackVal = 0;
Settings.whiteVal = apply_projector_transfer_function_nearest_neighbor(255,lookupTbMean_ND2_norm);
Settings.darkGrayVal = apply_projector_transfer_function_nearest_neighbor((2/8)*255,lookupTbMean_ND2_norm);
Settings.grayVal = apply_projector_transfer_function_nearest_neighbor((4/8)*255,lookupTbMean_ND2_norm);
Settings.lightGrayVal = apply_projector_transfer_function_nearest_neighbor((6/8)*255,lookupTbMean_ND2_norm);;
Settings.edgeLengthUm = 500;
Settings.screenSizeUm = 1500;

Settings.movementRangeUm = 900;
Settings.stepSizeUm = 30;

Settings.stimulusRepeats = 10;

Settings.frameShowIntervalSec = 1;


save(Settings.STIM_NAME, 'Settings');

end