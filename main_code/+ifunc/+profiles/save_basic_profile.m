function save_basic_profile(dirName, neurNames, stimName, flistFileNameID, Settings, StimMats, hdmea,varargin)
% % function save_basic_profile(dirName, neurNames, stimName, flistFileNameID, Settings, hdmea,varargin)
% P.save_frameno = 1;
% P.stimulus_type = [];

P.save_frameno = 1;
P.stimulus_type = [];
P = mysort.util.parseInputs(P, varargin, 'error');

if ischar(neurNames)
    neurNamesTemp = neurNames;clear neurNames;
    neurNames{1} = neurNamesTemp;
end

for i=1:length(neurNames)
    try
    fileNameSt = dir(fullfile(dirName.st,strcat('st_*', neurNames{i},'*.mat')));
    
    fprintf('processing %s\n', fileNameSt(1).name);
    load(fullfile(dirName.st, fileNameSt(1).name));
    % get spiketimes
    eval([  'spikeTimes = ',fileNameSt(1).name(1:end-4),'.ts*2e4;'])
    % name of neuron, derived from st_ file name
    neuronName = strrep(strrep(fileNameSt(1).name,'.mat',''),'st_','');
    save_to_profiles_file(neuronName, stimName, 'spiketimes', spikeTimes,1,'use_sep_dir', stimName)
    save_to_profiles_file(neuronName, stimName, 'neur_name', neuronName,1,'use_sep_dir', stimName)
    
    % assign spike times
    footprintMedian = ifunc.footprints.get_median_footprint(spikeTimes, hdmea);
    save_to_profiles_file(neuronName, stimName, 'footprint_median', ...
        footprintMedian,1,'use_sep_dir', stimName)
      
    % save frameno info
    if P.save_frameno
        [framenoInfo] = get_frameno_info(flistFileNameID ); 
        save_to_profiles_file(neuronName, stimName, 'frameno_info', ...
            framenoInfo,1,'use_sep_dir', stimName)
    end
    
    % stimulus-specific
    if strcmp(P.stimulus_type,'Moving_Bars')
        S = ifunc.stim.process_ds_rgc_data(spikeTimes, ...
            framenoInfo.stimFramesTsStartStopCol, Settings);
        save_to_profiles_file(neuronName, stimName, 'processed_data', ...
            S,1,'use_sep_dir', stimName);
    elseif strcmp(P.stimulus_type,'Flashing_Dots')
        S = ifunc.stim.process_flashing_dots(spikeTimes, ...
            framenoInfo.stimFramesTsStartStopCol(1:end,:), Settings, StimMats);
        save_to_profiles_file(neuronName, stimName, 'processed_data', ...
            S,1,'use_sep_dir', stimName);
    elseif strcmp(P.stimulus_type,'Movies')
        S = ifunc.stim.process_movies(spikeTimes, ...
            framenoInfo.stimFramesTsStartStopCol(1:end,:));
        save_to_profiles_file(neuronName, stimName, 'processed_data', ...
            S,1,'use_sep_dir', stimName);
    end

    fprintf('saved neuron %s\n', fileNameSt(1).name);
    
    clear(fileNameSt(1).name(1:end-4));
    clear footprintMedian
    fprintf('%d percent completed\n', round(100*i/(length(neurNames))))
    catch
        funcName = 'ifunc.profiles.save_basic_profile';
        message = sprintf('Could not process neur %s',  fileNameSt(1).name);
        ifunc.error.write_to_error_log_file(funcName, message)
    end
end