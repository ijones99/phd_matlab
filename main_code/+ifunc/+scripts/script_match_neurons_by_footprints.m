%% Do footprint median comparisons
acqFreq = 2e4;
% WHITE NOISE
%stimulus name
flistName{1} = 'flist_white_noise_050';stimName{1} = 'White_Noise';
% set up directories
[dirName suffixName flist flistFileNameID streamName tName]= ...
    ifunc.data_proc.set_dirs_for_init_processing(flistName{1},stimName{1});

% Prepare H5 File Access
h5File = strrep(strrep(flist,'../proc/',''),'ntk','h5');
h5File = h5File{1};
dateVal = get_dir_date
hdmea = ifunc.h5.prepare_h5_file_access(dateVal, h5File);
[selElsIdx elsToExcludeIdx] = ifunc.el_config.get_sel_el_ids(hdmea);
neurNames = {};
stimNames = {'White_Noise', 'Flashing_Dots', 'Moving_Bars', 'Movie_Original',...
    'Movie_Static_Surr_Median'};
for i=1:length(stimNames)
    dirNameProf{i} = strcat(fullfile(dirName.prof,stimNames{i}),'/'); mkdir(dirNameProf{i});
    dirNameFPMatch{i} = fullfile('../Figs/', stimNames{i},'Footprint_Matching/'); mkdir(dirNameFPMatch{i});
    neurNames{i} = extract_neur_names_from_files(dirNameProf{i},'*_*.mat');

end

comparisonSets = [1 2; 1 3; 1 4; 1 5];
for i=3:4
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
        'savePlot', dirNameFPMatch{i+1},'excludeEls',elsToExcludeIdx);
    
end
%% Put matches together
% Paste values from spreadsheet: col 1: inds for white noise
%                               col 2: selected footprint that matches
%                               (1 or 2 or3 or 4)
%                               col 3: same as 2, but for next stimuli
% 
% selMatchesMat 
% selNeurNamesQDS
clear indsQDS
% get inds
indsQDS = selMatchesMat(:,1);
neurNamesQDS = extract_neur_names_from_files(dirName.qds,'*.fig');
selNeurNames = neurNamesQDS(indsQDS);
neurNamesProfWn = extract_neur_names_from_files(dirName.prof_wn,'*_*.mat');
indsProfWn = find(ismember(neurNamesProfWn, selNeurNames));
comparisonSets = [1 2; 1 3];
selMatchesMat(:,1) = indsProfWn;

neurNameMat = cell(size(selMatchesMat,1),size(comparisonSets,1)+1);
neurNameMat(:,1) = neurNames{1}(selMatchesMat(:,1)); % neuron names for white noise

for i=1:2
    dirName.matching_footprint_plots = strcat('../analysed_data/Footprint_Matching/');
    load(fullfile(dirName.matching_footprint_plots,strcat('fp_matching_',...
        stimNames{comparisonSets(i,1)},'_vs_', stimNames{comparisonSets(i,2)},'.mat')));
    
    neurNameMat(:,i+1) = ifunc.neurname.extract_selected_neur_name_matrix(neurNames(comparisonSets(i,:)),...
    selMatchesMat(:,1), listMatches, selMatchesMat(:,i+1))
    
end
save('neurNameMat.mat', 'neurNameMat'); save('selMatchesMat.mat', 'selMatchesMat');
%% process selected neurons in movies
