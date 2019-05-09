% load data directories
dirName = projects.vis_stim_char.analysis.load_dir_names;

for iDir = 1:length(dirName.dataDirLong) % loop through directories
    
    cd([dirName.dataDirLong{iDir},'Matlab/']); % enter directory
    clearvars -except dirName iDir param_BiasIndex % clear vars
    script_load_data; load idxNeur ; load idxToMerge.mat; load idxFinalSel% load data
    
    
    
    
    
    mkdir(dirName.marching_sqr_over_grid);
    save(fullfile(dirName.marching_sqr_over_grid,'dataOut'),'dataOut')
    progress_info(iDir,length(dirName.dataDirLong),'batch mode: ')
end