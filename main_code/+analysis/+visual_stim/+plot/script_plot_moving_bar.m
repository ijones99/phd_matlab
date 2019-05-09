expName = get_dir_date;

% idx SETTINGS
wnCheckRIdx = 5;
barsRIdx = 2;
configIdx = 1;

% load config
eval(sprintf('load ~/ln/sorting_in/%s/configurations.mat',expName));

% load stim params
stimFrameInfo = file.load_single_var('settings/',...
    'stimFrameInfo_Moving_Bars_v3.mat');



% load data from R
Rall = analysis.visual_stim.load_R_data;

% load and save frameno info
frameno = analysis.visual_stim.load_frameno('run_no',1,'r_idx', wnCheckRIdx);
stimChangeTs = analysis.visual_stim.load_stim_change_ts('idx_exclude',wnCheckRIdx);

%% plot bars

close all
figure , hold on

for i=1:200
    hold off, clf, hold on
    plot.vis_stim.plot_moving_bars_narrow(Rall{barsRIdx, configIdx}, ...
        stimChangeTs{barsRIdx}, stimFrameInfo, i,'rgb', 1);
    junk = input('enter >> ');
end
