pathDef = dirdefs();
marchingSqrIdx = input('Marching square idx: >> ');
expName = get_dir_date
% load ref vars
load('refClusInfo.mat')
load('refFileCtrLoc.mat') % add stimuli names

% load data from R
R = analysis.visual_stim.load_R_data;
stimChangeTs = analysis.visual_stim.load_stim_change_ts; %('idx_include',3,'no_save','force_reload')
% load settings info
[stimFrameInfo Settings ] = analysis.visual_stim.load_settings;

while true
    fprintf('Marching square flist file: %s\n', refFileCtrLoc.flist{marchingSqrIdx});
    approveIt = input('ok? [y/n]','s')
    if approveIt ~= 'n'
        break, break
    end
end

h=figure,
runNo = 1; dirName = '../Figs/';
for iClus = 1:length(refClusInfo.clus_no)
    for directionSel = 1:2
        analysis.visual_stim.plot.plot_space_time_plot(...
            R{marchingSqrIdx }, refClusInfo.clus_no(iClus), ...
            stimChangeTs{marchingSqrIdx }, stimFrameInfo, directionSel);
        
        fileName = sprintf('%s_clus_%d_time_space_plot_run_%d_direction_%d', expName, refClusInfo.clus_no(iClus), runNo,directionSel);
        axis square
        suptitle(strrep(fileName,'_', ' '));
        colorbar
        save.save_plot_to_file(dirName, fileName,'fig');
        eval(sprintf('!cp %s %s', fullfile(dirName, [fileName,'.fig']), pathDef.plots_overview));
  
    end
end