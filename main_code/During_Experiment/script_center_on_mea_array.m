%% Focus & light setup
% 1. Focus on naked chip
% 2. move -25 mm along Z axis
% ND filter 2
% exposure time: 350msec
% gain 11dB
% binning : 2x2

%% Matlab centering on MEA array

numElsAlongX = 6;
numElsAlongY = 18;


x_dist=16.2*numElsAlongX;
y_dist=19.588*numElsAlongY;

fprintf('Move %4.1f in x direction, %4.1f in y direction.\n', x_dist, y_dist);


%% get coordinates from saved file

dirNameConfig = '/home/ijones/Experiments/Configs/Projects/Electrical_Stimulation/18x6_spc1_tile7x14_main_ds_scan/';
% [configCtrX configCtrY configCtrXAll configCtrYAll] = ...
%     plot_config_positions_from_el2fi(dirNameConfig, '*el2fi.nrk2','do_plot',0,'label_center')
load(fullfile(dirNameConfig,'configCtrXY'))

%% plot config
nrg = nr.Gui
set(gcf, 'currentAxes',nrg.ChipAxesBackground)
ah = nrg.ChipAxes;

dirNameConfig = '/home/ijones/Experiments/Configs/Projects/Electrical_Stimulation/18x6_spc1_tile18x3_suboptimal/';
fileNameConfig = '18x6_spc1_tile18x3_s067';

[configX configY ] = get_el_pos_from_el2fi(dirNameConfig, ...
    fileNameConfig);

plot( configX, configY,'co')



 
%% center on config
% NOTE! 
% Vertical Offset: 197mm down (pull joystick towards you)
% Horizontal Offset:  10mm left 
% Vert mm/pix = 1.72
% Horiz mm/pix = 1.80

selElNumber =4946;
dirNameConfig = '/home/ijones/Experiments/Configs/Projects/Electrical_Stimulation/18x6_spc1_tile7x14_main_ds_scan/';
[configName idx] = configs.get_closest_config_to_point(selElNumber, ...
    dirNameConfig);
fprintf('Config name: %s\n', configName);
configNum = idx-1;
fprintf('Config number: %d\n', configNum);
configIndNum = configNum+1;

moveX = configCtrX(configIndNum)-configCtrXAll;
moveY = configCtrYAll-configCtrY(configIndNum);

fprintf('Move %4.1f in x direction, %4.1f in y direction.\n', moveX, moveY);

%% center on config
% NOTE! 
% Vertical Offset: 197mm down (pull joystick towards you)
% Horizontal Offset:  10mm left 
% Vert mm/pix = 1.72
% Horiz mm/pix = 1.80

configNum = 31;
fprintf('Config number: %d\n', configNum);
configIndNum = configNum+1;

moveX = configCtrX(configIndNum)-configCtrXAll;
moveY = configCtrYAll-configCtrY(configIndNum);

fprintf('Move %4.1f in x direction, %4.1f in y direction.\n', moveX, moveY);



%% centering on right-hand side markings

% right-hand top notch to top: 659 um
% right-hand lower notch to bottom: 631um

