%% Initial setup to run analysis
% get electrode configuration file data: ELCONFIGINFO
% the ELCONFIGINFO file has x,y coords and electrode numbers
% ---------- Settings ----------
flistName = 'flist_white_noise_050';
dirName.figs = '../Figs/';
dirName.sta = strcat('../analysed_data/responses/sta/'); mkdir(dirName.sta); 
suffixName = strrep(flistName ,'flist','');
[ suffixName flist flistFileNameID dirName.gp  dirName.st ...
    dirName.el dirName.cl ] = setup_for_ntk_data_loading(flistName, suffixName);
elConfigClusterType = 'overlapping'; elConfigInfo = get_el_pos_from_nrk2_file;
elConfigInfo = add_ntk2_el_list_order_to_elconfiginfo(flist, elConfigInfo);
save('elConfigInfo.mat', 'elConfigInfo');
stimNames = {'White_Noise', 'Orig_Movie', 'Static_Median_Surround', 'Dynamic_Median_Surround', ...
    'Dynamic_Median_Surround_Shuffled', 'Pixelated_Surround_10_Percent', ...
    'Pixelated_Surround_50_Percent', 'Pixelated_Surround_90_Percent', 'Dots_of_Different_Sizes', 'Moving_Bars'};

%% get all neuron names
clear medianFootprints
dirName.profiles{1} = '../analysed_data/profiles/White_Noise/';
load(fullfile(dirName.profiles{1},'neurNames')); neurNames{1} = neurNames;
dirName.profiles{2} = '../analysed_data/profiles/Moving_Bars/';
neurNames{2} = extract_neur_names_from_files(dirName.profiles{2},'*.mat');

stimNum = 1;stimNameNum = 1;
% load all neurons and put waveform amplitudes into struct
numNeurons{stimNum} = length(neurNames{stimNum});
for i=1:numNeurons{stimNum} 
    data = load_profiles_file(neurNames{stimNum}{i},'use_sep_dir',stimNames{stimNameNum} );
    stimStruct = getfield(data,stimNames{stimNameNum});
    medianFootprints{stimNum}{i} =  stimStruct.footprint_median;
    clear data
end

stimNum = 2;stimNameNum = 10;
% load all neurons and put waveform amplitudes into struct
numNeurons{stimNum} = length(neurNames{stimNum});
for i=1:numNeurons{stimNum} 
    data = load_profiles_file(neurNames{stimNum}{i},'use_sep_dir',stimNames{stimNameNum} );
    stimStruct = getfield(data,stimNames{stimNameNum});
    medianFootprints{stimNum}{i} =  stimStruct.footprint_median;
    clear data
    i
end
%% compare footprint medians
outputMat = ifunc.footprints.compare_footprints_two_sources(medianFootprints{1},medianFootprints{2});
reverseMat = 1-outputMat./max(max(outputMat));

reverseMatExp = exp(reverseMat);
reverseMatNorm = reverseMatExp/max(max(reverseMatExp));
figure, imagesc((reverseMatNorm)), colormap(gray), colorbar
threshVal = 0.95;
reverseMatNormThresh = zeros(size(reverseMatNorm,1), size(reverseMatNorm,2));
reverseMatNormThresh(reverseMatNorm>threshVal) = 1;
figure, imagesc(reverseMatNormThresh), colormap(gray)
[row, col] = find(reverseMatNormThresh==1)
length(unique(row))
%% get list of closest matching for different stimuli
listMatches = ifunc.footprints.find_closest_matching_footprints_from_sim_mat(reverseMatNorm,8);
fprintf('----------------------------------------\n');
fprintf('Matches between diff stimuli\n');
fprintf('----------------------------------------\n\n');
for i=1:length(neurNames{1})
   fprintf('%d) %s -> %s (%3.0f), %s (%3.0f), %s (%3.0f), %s (%3.0f), %s (%3.0f), %s (%3.0f), %s (%3.0f), %s (%3.0f)\n', i,...
       neurNames{1}{listMatches(i,1)}, ...
       neurNames{2}{listMatches(i,2)},100*reverseMatNorm(i, listMatches(i,2)), ...  
       neurNames{2}{listMatches(i,3)},100*reverseMatNorm(i, listMatches(i,3)), ...
       neurNames{2}{listMatches(i,4)},100*reverseMatNorm(i, listMatches(i,4)), ...
       neurNames{2}{listMatches(i,5)},100*reverseMatNorm(i, listMatches(i,5)), ...
       neurNames{2}{listMatches(i,6)},100*reverseMatNorm(i, listMatches(i,6)), ...
       neurNames{2}{listMatches(i,7)},100*reverseMatNorm(i, listMatches(i,7)), ...
       neurNames{2}{listMatches(i,8)},100*reverseMatNorm(i, listMatches(i,8)), ...
       neurNames{2}{listMatches(i,9)},100*reverseMatNorm(i, listMatches(i,9)))
    
end
.e.eee = {};
for i=1:length(neurNames{1})
     neurNamesStim2{i} = neurNames{2}{listMatches(i,2)}
    
end



%% Find similar groups
threshold = 0.;
 [matchingGps uniqueClusters] = find_similar_groups(reverseMatNorm, '>', threshold );
 neurNamesOut = neurNames{1};
fName = 'Possible_Duplicates_Footprint_Comparison.txt';         %# A file name
fid = fopen(fullfile('',fName),'w'); %# Open the file
fprintf(fid, 'Possible duplicates footprint comparison (Threshold %2.0f) - Date: %s\n\n', threshold*100,get_dir_date);
for i=1:length(matchingGps)
    for j=1:length(matchingGps{i})
        fprintf(fid, '%s (%d), ', neurNamesOut{matchingGps{i}(j)}, matchingGps{i}(j));
        fprintf('%s (%d), ', neurNamesOut{matchingGps{i}(j)}, matchingGps{i}(j));
    end
    fprintf(fid, '\n');
    fprintf('\n');
end
fclose(fid);
open(fullfile('',fName))

