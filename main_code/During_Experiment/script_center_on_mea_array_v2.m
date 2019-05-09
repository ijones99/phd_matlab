function center_on_config
%% Focus & light setup
% 1. Focus on naked chip
% ND filter 2
% exposure time: 350msec
% gain 11dB
% binning : 2x2


%% get coordinates from saved file

dirNameConfig = '/home/ijones/Experiments/Configs/Projects/Electrical_Stimulation/18x6_spc1_tile7x14_main_ds_scan/';
% [configCtrX configCtrY configCtrXAll configCtrYAll] = ...
%     plot_config_positions_from_el2fi(dirNameConfig, '*el2fi.nrk2','do_plot',0,'label_center')
load(fullfile(dirNameConfig,'configCtrXY'))
 
%% center on config
% NOTE! 
fprintf('Remember to center initially: vert. 197mm down (pull joystick towards you); horiz: 10mm left.\n')
% Horizontal Offset:   
% Vert mm/pix = 1.72
% Horiz mm/pix = 1.80

configNum = input('Enter config ID number (not file number) >> ');
fprintf('Config number: %d\n', configNum);
configIndNum = configNum+1;

moveX = configCtrX(configIndNum)-configCtrXAll;
moveY = configCtrYAll-configCtrY(configIndNum);

fprintf('Move %4.1f in x direction, %4.1f in y direction.\n', moveX, moveY);
end