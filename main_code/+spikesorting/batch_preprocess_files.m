function batch_preprocess_files(varargin)

configGpType = 'exclusive';
thresholdVal = 4.5;
numEls = 7;
batchData = {};
% select stim type
stimTypes = {'wn_checkerboard'; ...
    'marching_sqr_and_moving_bars'; ...
    'marching_sqr'; ...
    'moving_bars'; ...
    'spots';...
    };

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'el_config_group_type')
            configGpType = varargin{i+1};
        elseif strcmp( varargin{i}, 'batch_list_cell')
            batchData = varargin{i+1};
            
        end
    end
end
if isempty(batchData)
    batchData = spikesorting.create_batch_cell(stimTypes);
end
% fprintf('Will process:\n');
% for i=1:length(batchGp)
%     fprintf('(%d) %s\n', i, batchGp{i}.flistName);
% end
% pause(2);
procFileCtrEl = [];
for iBatch=1:length(batchData)
    % make flist, get ID
    flistFileNameID = get_flist_file_id(batchData{iBatch}.flist);
    dirNameSave = sprintf('%s_%s_n_%02d', flistFileNameID,batchData{iBatch}.stimType, batchData{iBatch}.runNo);
    % dir names
    dirNameFFile = strcat('../analysed_data/',   dirNameSave);
    dirNameSt = strcat('../analysed_data/',   dirNameSave,'/03_Neuron_Selection/');
    dirNameEl = strcat('../analysed_data/',   dirNameSave,'/01_Pre_Spikesorting/');
    dirNameCl = strcat('../analysed_data/',   dirNameSave,'/02_Post_Spikesorting/');
    
    %
    suffixName = ['_',batchData{iBatch}.stimType];
    flistName = ['flist_', batchData{iBatch}.stimType];
    if isempty(batchData{iBatch}.elIdxCtr)
        pre_process_data(suffixName, [], 'config_type','exclusive',...
            'kmeans_reps',1,'threshold', thresholdVal, 'flist', batchData{iBatch}.flist, ...
            'dir_name', dirNameSave);
    else
        
        pre_process_data(suffixName, [], 'config_type','exclusive',...
            'kmeans_reps',1,'threshold', thresholdVal,'sel_by_els', ...
            batchData{iBatch}.elIdxCtr, 'flist', batchData{iBatch}.flist,'dir_name', dirNameSave);
    end
    
end


end


