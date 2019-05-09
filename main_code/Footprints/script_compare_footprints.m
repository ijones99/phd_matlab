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
dirName.profiles = '../analysed_data/profiles/';
neurNames = extract_neur_names_from_files(dirName.profiles,'*.mat');

% load all neurons and put waveform amplitudes into struct
textprogressbar('start loading all waveform amps:>')
numNeurons = length(neurNames);
clear waveformAmps
for i=1:numNeurons 
    data = load_profiles_file(neurNames{i});
    waveformAmps{i} = max(data.White_Noise.footprint.averaged,[],2)'-min(data.White_Noise.footprint.averaged,[],2)';
    textprogressbar(100*i/numNeurons);
    clear data
end
textprogressbar('done')

save('waveformAmps.mat','waveformAmps');

%% compare the waveform amplitudes
elAmpDiffs = compare_amplitude_differences(waveformAmps );
elAmpDiffs = elAmpDiffs/max(max(elAmpDiffs ));
save('elAmpDiffs.mat', 'elAmpDiffs')

%% find similar groups
[matchingGps uniqueGps ] = find_similar_groups(elAmpDiffs, '<', 0.05);

%% print indices of neurons
fprintf('=========== Matching Groups (Inds) =============\n')
for i=1:length(matchingGps)
    for j = 1:length(matchingGps{i})-1
        fprintf('%d, ',  matchingGps{i}(j));
    end
    fprintf('%d',  matchingGps{i}(j+1));
    fprintf('\n')
end

fprintf('=================================================\n\n')


