function calculate_sta_info(dirName, neurNames, flistFileNameID, ntk2,hdmea)

if ischar(neurNames)
    neurNamesTemp = neurNames;clear neurNames;
    neurNames{1} = neurNamesTemp;
end

close all
% load frameno info
load(fullfile(dirName.gp,strcat('frameno_', flistFileNameID,'_shift860.mat'))); 
frameInd = single(frameno);

% load white noise frames
load StimCode/white_noise_frames.mat

for i=1:length(neurNames)
        
        fileNameSt = dir(fullfile(dirName.st,strcat('st_*', neurNames{i},'*.mat')));
        
        fprintf('processing %s\n', fileNameSt(1).name);
        load(fullfile(dirName.st, fileNameSt(1).name));
        % get spiketimes
        eval([  'spikeTimes = ',fileNameSt(1).name(1:end-4),'.ts*2e4;'])
        % name of neuron, derived from st_ file name
        neuronName = strrep(strrep(fileNameSt(1).name,'.mat',''),'st_','');
        % get all the frames for white noise sta
        staOut = white_noise_reverse_correlation_simple_4( spikeTimes, white_noise_frames, ...
            frameInd, 'neuron_name', neuronName, 'flist_name', flistFileNameID, ...
            'output_dir', dirName.sta); %
        
        save_to_profiles_file(neuronName, 'White_Noise', 'spiketimes', spikeTimes,1)
        % compute footprints
        footprint = extract_waveforms_from_ntk2(ntk2, spikeTimes/2e4 );
        save_to_profiles_file(neuronName, 'White_Noise', 'footprint', footprint,1)
        data = load_profiles_file(neuronName);
        maxPeakToPeak = max(data.White_Noise.footprint.averaged,[],2)-min(...
            data.White_Noise.footprint.averaged,[],2);
        save_to_profiles_file(neuronName, 'White_Noise', 'max_peak_to_peak', maxPeakToPeak,1);
        eval([  'ClusteringEls = ',fileNameSt(1).name(1:end-4),'.inds_for_sorting_els;'])
        save_to_profiles_file(neuronName, 'White_Noise', 'inds_for_sorting_els', ClusteringEls,1);

        footprintMedian = ifunc.footprints.get_median_footprint(spikeTimes, hdmea);
        save_to_profiles_file(neuronName, stimName, 'footprint_median', ...
            footprintMedian,1,'use_sep_dir', stimName)
        
        fprintf('saved neuron %s\n', fileNameSt(1).name);
        
        eval(['clear ',fileNameSt(1).name(1:end-4) ])
        clear footprint
%         catch
%             fprintf('Error; probably no spikes for index %d\n', i);
%         end
    fprintf('%d\n', i/(length(neurNames)))
end
