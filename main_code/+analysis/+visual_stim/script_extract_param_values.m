def = dirdefs(); expName = get_dir_date;
dirName = def.neuronsSaved;
fileStr = '*mat'
[fileList dirsFound numFilesFound]  = file.build_filelist_from_ground_up(...
    dirName, fileStr) ;

%% test for params

dirSettings = '../Matlab/settings/'
for i=1:length(fileList)
    try
    
    eval(sprintf('cd ../../%s/Matlab/', fileList{i,1}))
    
    load(fullfile(dirName, fileList{i,1}, fileList{i,2}));
    spotsSettings = file.load_single_var(dirSettings, 'stimFrameInfo_spots.mat');
    barsSettings = file.load_single_var(dirSettings,...
        'stimFrameInfo_movingBar_2Reps.mat');
    
    neur = response_params_calc.compute_vis_stim_parameters2(neur,...
        spotsSettings, barsSettings,'plot');%
    catch
       warning(sprintf('error idx %d', i)) 
    end
close all
end

%%
paraOutputMat = {};
paraOutputMat.neur_names = {};
paraOutputMat.params= zeros(size(fileList,1)-1,6);

for i=1:length(fileList)

    load(fullfile(dirName, fileList{i,1}, fileList{i,2}));
    paraOutputMat.neur_names{i} = [fileList{i,1}, '/',fileList{i,2}];
    try
        
        
        if isfield( neur.paramOut,'spt_pref_brightness')
            neur.paramOut = rmfield( neur.paramOut,'spt_pref_brightness')
        end
        paraOutputMat.params(i,1:length(fields(neur.paramOut))) = struct2array(neur.paramOut);
    catch
        warning(sprintf('idx %d'));
    end
    
    progress_info(i, length(fileList))
    
end