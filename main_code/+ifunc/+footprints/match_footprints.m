%% Do footprint median comparisons
plot_electrode_config('plot_el_ind',1)
acqFreq = 2e4;
% WHITE NOISE
%stimulus name
flistName{1} = 'flist_white_noise_checkerboard';stimName{1} = 'White_Noise';
% set up directories
[dirName suffixName flist flistFileNameID streamName tName]= ...
    ifunc.data_proc.set_dirs_for_init_processing(flistName{1},stimName{1});

% Prepare H5 File Access
h5File = strrep(strrep(flist,'../proc/',''),'ntk','h5');
h5File = h5File{1};
dateVal = get_dir_date
hdmea = ifunc.h5.prepare_h5_file_access(dateVal, h5File);
% [selElsIdx elsToExcludeIdx] = ifunc.el_config.get_sel_el_ids(hdmea);
neurNames = {};
stimNames = {'White_Noise', 'Flashing_Dots'};

%%
for i=1:length(stimNames)
    dirNameProf{i} = strcat(fullfile(dirName.prof,stimNames{i}),'/'); mkdir(dirNameProf{i});
    dirNameFPMatch{i} = fullfile('../Figs/', stimNames{i},'Footprint_Matching/'); mkdir(dirNameFPMatch{i});
    neurNames{i} = extract_neur_names_from_files(dirNameProf{i},'*_*.mat');

end
%%
comparisonSets = [1 2]%[1 2; 1 3; 1 4; 1 5];
for i=1:size(comparisonSets,1)
    [listMatches reverseMatExpNorm outputMat medianFootprints neurNames1]  = ...
        ifunc.footprints.compute_footprint_similarity_for_two_groups(neurNames(comparisonSets(i,:)), ...
        stimNames(comparisonSets(i,:)));
    
    dirName.matching_footprint_plots = strcat('../analysed_data/Footprint_Matching/');mkdir(dirName.matching_footprint_plots)
    
    save(fullfile(dirName.matching_footprint_plots,strcat('fp_matching_',...
        stimNames{comparisonSets(i,1)},'_vs_', stimNames{comparisonSets(i,2)},'.mat')) , ...
        'listMatches', 'reverseMatExpNorm', 'outputMat', 'medianFootprints', 'neurNames');
    
    % plot matching footprints
    ifunc.plot.footprints.plot_footprint_median_comparisons(neurNames(comparisonSets(i,:)),...
        stimNames(comparisonSets(i,:)), medianFootprints, listMatches, ...
        hdmea.MultiElectrode.electrodePositions, ...
        'savePlot', dirNameFPMatch{i+1},'excludeEls',elsToExcludeIdx,'totalNumEls',length(hdmea.MultiElectrode.electrodePositions) );
    
end
