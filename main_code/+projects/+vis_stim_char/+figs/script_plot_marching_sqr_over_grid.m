    
% ++++++++++++ NOTE ++++++++++
% Folders containing relevant data can be accessed by 
% dirName = projects.vis_stim_char.analysis.load_dir_names;

% ++++++++++++ FIRST PROCESSING STEP +++++++++++
% Put all spiketrains in "profile" files.
% Profile data is saved in ../analysed_data/profiles/
% Profiles that were checked are saved with *merg* in title.
% Save idx's: idxFinalSel
open ../Matlab/script_get_footprints_v2.m

% ++++++++++++ MARCHING SQUARE OVER GRID ++++++++++++
% compute parameters for ON OFF bias for all directories
% Saves to ../analysed_data/marching_sqr_over_grid/
%   paramOut: processed data.
%   param_BiasIndex.mat: parameter info.
% Figure: plot T
open projects.vis_stim_char.analysis.marching_sqr_over_grid.process_data

% Obtain indices for all folders
dirNames = projects.vis_stim_char.analysis.load_dir_names;
absDirNames = dirNames.dataDirLong;
localDirName = 'analysed_data/marching_sqr_over_grid/';
fileName = 'param_BiasIndex';
fieldName = 'index';
paramCatOnOffBias = projects.vis_stim_char.analysis.gather_indices(...
    absDirNames, localDirName, fileName, fieldName)
% save params
save(fullfile(dirNames.common.params,'paramCatOnOffBias.mat'),'paramCatOnOffBias');

% plot histogram paramCatOnOffBias
figure, hist(paramCatOnOffBias,30)
dirNameFig = dirNames.common.figs;
fileNameFig = 'on_off_bias_params_all';
currGca = findobj(gca,'Type','patch');
set(currGca,'FaceColor',[1 1 1 ]*0.5) %,'k','EdgeColor',
xlabel('Parameter'), ylabel('Cell Count (unit cell)');
titleName = 'Preferred Moving Bar Width (Spline Fit)';
title(titleName)
figs.format_for_pub('journal_name','frontiers');
figs.save_for_pub(fullfile(dirNameFig,fileNameFig));




