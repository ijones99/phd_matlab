function calculate_basic_profile(dirName, neurNames, stimName, flistFileNameID, ntk2)

if ischar(neurNames)
    neurNamesTemp = neurNames;clear neurNames;
    neurNames{1} = neurNamesTemp;
end

close all
% load frameno info
% load(fullfile(dirName.gp,strcat('frameno_', flistFileNameID,'_shift860.mat'))); 
% frameInd = single(frameno);

for i=1:length(neurNames)
    
    fileNameSt = dir(fullfile(dirName.st,strcat('st_*', neurNames{i},'*.mat')));
    
    fprintf('processing %s\n', fileNameSt(1).name);
    load(fullfile(dirName.st, fileNameSt(1).name));
    % get spiketimes
    eval([  'spikeTimes = ',fileNameSt(1).name(1:end-4),'.ts*2e4;'])
    % name of neuron, derived from st_ file name
    neuronName = strrep(strrep(fileNameSt(1).name,'.mat',''),'st_','');
    save_to_profiles_file(neuronName, stimName, 'spiketimes', spikeTimes,1,'use_sep_dir', stimName)
    % compute footprints
    footprint = extract_waveforms_from_ntk2(ntk2, spikeTimes/2e4 );
    save_to_profiles_file(neuronName, stimName, 'footprint', footprint,1,'use_sep_dir', stimName)
%     data = load_profiles_file(neuronName,'use_sep_dir', stimName);
    
    maxPeakToPeak = max(footprint.averaged,[],2)-min(footprint.averaged,[],2);
    save_to_profiles_file(neuronName, stimName, 'max_peak_to_peak', maxPeakToPeak,1,'use_sep_dir', stimName);
    
    eval([  'ClusteringEls = ',fileNameSt(1).name(1:end-4),'.inds_for_sorting_els;'])
    save_to_profiles_file(neuronName, stimName, 'inds_for_sorting_els', ClusteringEls,1,'use_sep_dir', stimName);
    
    fprintf('saved neuron %s\n', fileNameSt(1).name);
    
    eval(['clear ',fileNameSt(1).name(1:end-4) ])
    clear footprint
    fprintf('%d\n', round(100*i/(length(neurNames))))
end
