function [spikes meaData dataChunkParts concatData] = ...
    load_and_spikesort_selected_els(flist, staticEls, varargin)
doAdjustForFirstConfig = 0;
forceFileConversion = 0;
doSpikeSorting = 1;
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'force_file_conversion')
            forceFileConversion = 1;
        elseif strcmp( varargin{i}, 'no_spikesorting')
            doSpikeSorting = 0;
        elseif strcmp( varargin{i}, 'first_config_is_block')
            doAdjustForFirstConfig = 1;
            
        end
    end
end


%% load all h5 files (regional scan)

% concatenate data
concatData = single([]);
dataChunkParts = 0;
dataChunkLengthMsec = 5;
dataChunkLengthSamples = 2e4*dataChunkLengthMsec;
 meaData = {};
 dataInds = {};
 meaData = mea1.load_mea1_data(flist);
 
for i=1:length(flist)
   
    
    
    % find inds for sel channels
    dataInds{i} = multifind_ordered(meaData{i}.getAllSessionsMultiElectrodes.electrodeNumbers, staticEls);
    nanInds = find(isnan(dataInds{i}));
    if sum(nanInds) > 0
        dataInds{i}(nanInds) = []
    end
    if i==1
        concatData = single(meaData{i}.getData(:,dataInds{i}));
    else
        if doAdjustForFirstConfig && i==2 % if i==2
            %             
            %             elNumberFirst =
            %             elidxFirst = allElsFirst(dataInds{1});
            %             flistIndsCurr = dataInds{2};
            allElsFirst = meaData{1}.MultiElectrode.getElectrodeNumbers;
            allElsCurr = meaData{2}.MultiElectrode.getElectrodeNumbers;
            sortElsFirst = allElsFirst(dataInds{1});
            sortElsCurr = allElsCurr(dataInds{2});
            commonConcatDataIdx = multifind(sortElsCurr,sortElsFirst,'J');
            concatDataNew = zeros(size(concatData,1), length(sortElsCurr));
            concatDataNew( :, commonConcatDataIdx) = concatData;
            concatData = concatDataNew;
            clear concatDataNew;
            
        end
        
        concatData = [concatData; single(meaData{i}.getData(:,dataInds{i}))];
    end
    dataChunkParts(i+1) = size(concatData,1);
    fprintf('Progress %3.0f\n', 100*i/length(flist));
end

%% spikesort all configs
% check for arguments
Fs = 2e4;
thrValue = 4.5;
numKmeansReps = 1;
% SPIKE SORTING
clear data
data{1} = concatData;

spikes = [];
if doSpikeSorting
    % default_waveformmode = 1 is for all traces mode
    spikes = ss_default_params(Fs, 'thresh', thrValue);
    spikes.elidx = staticEls;
    % spikes.channel_nr = chNumbers;untitled8.m
    fName = 'fileName';
    % SET VIEW MODE;
    spikes.params.display.default_waveformmode = 1; % 1: "show all spikes" mode; ...
    % 2: show bands
    
    % give file names to spike struct
    spikes.fname = fName;
    spikes.clus_of_interest=[];
    spikes.template_of_interest=[];
    
    % detect spikes
    runTime(1) = 0;
    tic
    spikes = ss_detect(data,spikes)
    runTime(2) = toc;
    fprintf('ss_detect. Time %3.0f.\n', runTime(2));
    tic
    spikes = ss_align(spikes);
    runTime(3) = toc;
    fprintf('ss_align. Time %3.0f.\n', runTime(3));
    % cluster spikes
    options.reps = numKmeansReps;
    options.progress = 0;
    tic
    spikes = ss_kmeans(spikes, options);
    runTime(4) = toc;
    fprintf('ss_kmeans. Time %3.0f.\n', runTime(4));
    tic
    spikes = ss_energy(spikes);
    runTime(5) = toc;
    fprintf('ss_energy. Time %3.0f.\n', runTime(5));
    tic
    spikes = ss_aggregate(spikes);
    runTime(6) = toc;
    fprintf('ss_agg. Time %3.0f.\n', runTime(6));
    fprintf('Total runtime: %3.0f mins\n', sum(runTime));
    
    spikes.params.display.default_waveformmode = 2;
    splitmerge_tool(spikes)
    
end

end

