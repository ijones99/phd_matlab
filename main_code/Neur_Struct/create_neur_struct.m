function out = create_neur_struct(mea1, clusterNo, spikeTimes, stimType, fname, varargin)

fieldNames = {};

maxNumWFsForTemplate = 200;
out = {}; % init. output
out.stimType = stimType;
out.cluster_no = clusterNo;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'load_ntk_fields')
            fieldNames = varargin{i+1};
    
        end
    end
end

if ~isempty(fieldNames)
    ntkData = get_fields_from_ntk_file(fname, fieldNames);
    
    for i=1:length(fieldNames)
        firstPeriod = strfind(fieldNames{i}, '.');
        if isempty(firstPeriod )
            fieldName = fieldNames{i};
        else
            fieldName = fieldNames{i}(1:firstPeriod(1)-1);
        end
        eval(sprintf('out.%s = ntkData.%s;', fieldName, fieldName));
    end
    
end

preSpikeTime = 60; % in samples
postSpikeTime = 60; % in samples
for iCluster = 1:length(clusterNo) % go through cells containing spike times
    % init neurons struct
    out.neurons{iCluster} = {};
    % save cluster number
    out.neurons{iCluster}.cluster_no = clusterNo(iCluster);
    % get ts position for neuron
    out.neurons{iCluster}.ts_pos = find(spikeTimes(:,1)==clusterNo(iCluster));
    % set # waveforms to use for template
    if length(out.neurons{iCluster}.ts_pos) > maxNumWFsForTemplate
        numWFsForTemplate = length(out.neurons{iCluster}.ts_pos);
    end
    % 
    out.neurons{iCluster}.ts = spikeTimes(out.neurons{iCluster}.ts_pos,2);
    
    % flist name
    out.neurons{iCluster}.flist = fname;  
    
    % get h5data
    h5Data = mea1;

    % elidx
    out.neurons{iCluster}.el_idx = h5Data.MultiElectrode.electrodeNumbers';
    out.neurons{iCluster}.channel_nr = h5Data.getChannelNr';
    out.neurons{iCluster}.x = h5Data.MultiElectrode.electrodePositions(:,1)';
    out.neurons{iCluster}.y = h5Data.MultiElectrode.electrodePositions(:,2)';
    
    out.neurons{iCluster}.event_param.pre1 = preSpikeTime;
    out.neurons{iCluster}.event_param.post1 = postSpikeTime;
    
    try
        
        if length(out.neurons{iCluster}.ts)> maxNumWFsForTemplate
            waveformTS = out.neurons{iCluster}.ts(1:maxNumWFsForTemplate);
        else
            waveformTS = out.neurons{iCluster}.ts;
        end
     clear data   
    [data] = extract_waveforms_from_h5(h5Data, waveformTS, ...
        'pre_spike_time', preSpikeTime,'post_spike_time',postSpikeTime );
    
    % template information
    out.neurons{iCluster}.template = {};
    % pre and post spike cut time
    out.neurons{iCluster}.template.pre = preSpikeTime;
    out.neurons{iCluster}.template.post = postSpikeTime;
    % obtain template
    out.neurons{iCluster}.template.data = data.average';
    
    catch
       fprintf('No spikes for %d\n', iCluster);
    end
%     dataOffsetCorr = data.average-repmat(mean(data.average(:,end-30:end),2),1,size(data.average,2));
    progress_info(iCluster ,length(clusterNo))
    
    
end







end

