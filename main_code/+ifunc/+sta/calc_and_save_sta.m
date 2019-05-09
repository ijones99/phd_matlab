function calc_and_save_sta(dirName, neurNames, flistFileNameID, hdmea, frameno, varargin)
% function calc_and_save_sta(dirName, neurNames, flistFileNameID, hdmea, frameno, varargin)
% P.save_spiketimes = 1;
% P.save_sta = 1;
% P.save_footprint = 0;
% P.save_max_peak_to_peak = 0;
% P.save_inds_for_sorting_els = 0;
% P.save_footprint_median = 1;
% P.save_plot_info = 1;
% P.save_temporal_plot = 1;
% P.structure_name = 'White_Noise';
% P.restrict_spike_number = [];
% P.num_waveforms_to_use = [];
% P.restrict_spike_number_lower_res = [];


P.save_spiketimes = 1;
P.save_sta = 1;
P.save_footprint = 0;
P.save_max_peak_to_peak = 0;
P.save_inds_for_sorting_els = 0;
P.save_footprint_median = 1;
P.save_plot_info = 1;
P.save_temporal_plot = 1;
P.structure_name = 'White_Noise';
P.use_sep_dir = 'White_Noise';
P.restrict_spike_number = [];
P.num_waveforms_to_use = [];
P.restrict_spike_number_lower_res = [];
P = mysort.util.parseInputs(P, varargin, 'error');

if ischar(neurNames)
    neurNamesTemp = neurNames;clear neurNames;
    neurNames{1} = neurNamesTemp;
end

% load frameno info
frameInd = single(frameno);

% load white noise frames
if exist('StimCode/white_noise_frames.mat')
    
load StimCode/white_noise_frames.mat
else
   fprintf('!!!!!Error,  StimCode/white_noise_frames.mat does''nt exist.\n');
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
        % get all the frames for white noise sta
        [staFrames staTemporalPlot plotInfo ] = ifunc.sta.make_sta( spikeTimes, white_noise_frames, ...
            frameInd, 'neuron_name', neuronName); %
        if P.save_plot_info
            save_to_profiles_file(neuronName, P.structure_name, 'plot_info', plotInfo,1, 'use_sep_dir', P.use_sep_dir);
        end
        if P.save_temporal_plot
            save_to_profiles_file(neuronName, P.structure_name, 'sta_temporal_plot', staTemporalPlot,1, 'use_sep_dir', P.use_sep_dir);
        end
        if P.save_sta
            save_to_profiles_file(neuronName, P.structure_name, 'sta', staFrames,1, 'use_sep_dir', P.use_sep_dir);
        end
        if P.save_spiketimes
            save_to_profiles_file(neuronName, P.structure_name, 'spiketimes', spikeTimes,1,'use_sep_dir', P.use_sep_dir);
        end
        % compute footprints
        if or(P.save_footprint, P.save_footprint_median)
            % plot footprints
            % for cutting
            cutLeft = 15;
            cutLength = 30;
            currspiketimes = spikeTimes;
            if ~isempty(P.restrict_spike_number)
                if length(currspiketimes) > P.restrict_spike_number
                    if P.restrict_spike_number_lower_res
                        numSpikes = length(currspiketimes); % get num spikes
                        stepSize = floor(numSpikes/P.restrict_spike_number);%step size by which to reduce num spikes
                        if stepSize == 0, stepSize = 1;end
                        currspiketimes = currspiketimes(1:stepSize:end); % reduce num spikes by taking every nth spike
                    else
                        currspiketimes = currspiketimes(1:P.restrict_spike_number);
                    end
                end
            end
            footprint = hdmea.getWaveform(currspiketimes, cutLeft, cutLength);
            % convert waveforms to tensor
            footprint = single(mysort.wf.v2t(footprint, size(hdmea,2)));
        end
        if P.save_footprint
            
            save_to_profiles_file(neuronName, P.structure_name, 'footprint', footprint,1,'use_sep_dir', P.use_sep_dir)
        end
        data = load_profiles_file(neuronName, 'use_sep_dir', P.use_sep_dir);
        if P.save_max_peak_to_peak || P.save_footprint_median || P.save_footprint
            footprintMedian = ifunc.footprints.get_median_footprint(spikeTimes, hdmea);
            maxPeakToPeak = max(footprintMedian,[],1)-min(footprintMedian,[],1);
        end
        if P.save_max_peak_to_peak
            save_to_profiles_file(neuronName, P.structure_name, 'max_peak_to_peak', maxPeakToPeak,1,'use_sep_dir', P.use_sep_dir);
        end
        if P.save_inds_for_sorting_els
            eval([  'ClusteringEls = ',fileNameSt(1).name(1:end-4),'.inds_for_sorting_els;'])
        end
        if P.save_inds_for_sorting_els
            save_to_profiles_file(neuronName, P.structure_name, 'inds_for_sorting_els', ClusteringEls,1,'use_sep_dir', P.use_sep_dir);
        end
        if P.save_footprint_median
            save_to_profiles_file(neuronName, P.structure_name, 'footprint_median', ...
                footprintMedian,1,'use_sep_dir', P.use_sep_dir);
        end
        fprintf('saved neuron %s\n', fileNameSt(1).name);
        eval(['clear ',fileNameSt(1).name(1:end-4) ])
        
        fprintf('%3.0f\n', 100*i/(length(neurNames)))
    catch
        funcName = 'ifunc.profiles.save_basic_profile';
        message = sprintf('Could not process neur %s',  fileNameSt(1).name);
        ifunc.error.write_to_error_log_file(funcName, message)
    end
end
