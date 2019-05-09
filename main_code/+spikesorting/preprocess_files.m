function preprocess_files(varargin)

configGpType = 'exclusive';
thresholdVal = 4.5;
numEls = 7;
% select stim type
stimTypes = {'_wn_checkerboard'; ...
    '_marching_sqr_and_moving_bars'; ...
    '_marching_sqr'; ...
    '_moving_bars'; ...
    '_spots';...
    }


% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'el_config_group_type')
            configGpType = varargin{i+1};

        end
    end
end

% create flist batch
iBatch = 1;
batchGp = {};
stimTypeSel = 1e10
while stimTypeSel ~= 0 % select 0 to quit
    fprintf('Enter "0" to quit. \n ')
    % select stim type
        % input stim run number, make flist name
    fileRunNameNumber = input('New Group: enter stim run number >>')
    fprintf('Select stimulation type:\n ')
    for i=1:length(stimTypes)
        fprintf('(%d) %s\n', i, stimTypes{i});
    end
    stimTypeSel = input('Select type [number] >> ');
    if stimTypeSel==0
        return;
    end

    batchGp{iBatch}.suffixName = sprintf('%s_n_%02d',stimTypes{stimTypeSel}, fileRunNameNumber);
    batchGp{iBatch}.flistName = sprintf('flist%s_n_%02d',...
        stimTypes{stimTypeSel}, fileRunNameNumber);
    
    % make flist
    batchGp{iBatch}.flist = make_flist_select([batchGp{iBatch}.flistName,'.m'])
    
    % get config info
    elConfigInfo = flists.get_elconfiginfo_from_flist(batchGp{iBatch}.flist(1));
    if strcmp('exclusive',configGpType)
        selectedPatches = select_patches_exclusive(numEls, elConfigInfo );
    end
    
    elIdxCtr = [];
    % number of electrode groups within config
    numElGps = input('number of electrode groups ([1-n] | 0 for "all") >> ');
    if numElGps == 0
        batchGp{iBatch}.patches =  selectedPatches;
    else
        for iGp = 1:numElGps
            batchGp{iBatch}.elIdxCtr(iGp ) = input('Enter center el idx >> ');
        end
        selIdxNos = configs.find_patches_containing_els(selectedPatches, batchGp{iBatch}.elIdxCtr );
        batchGp{iBatch}.patches = selectedPatches(selIdxNos);
        
    end
    iBatch = iBatch+1;
end

procFileCtrEl = [];
for iBatch=1:length(batchGp)
    % make flist, get ID
    
    flistFileNameID = get_flist_file_id(batchGp{iBatch}.flist(1), batchGp{iBatch}.suffixName);
    
    % dir names
    dirNameFFile = strcat('../analysed_data/',   flistFileNameID);
    dirNameSt = strcat('../analysed_data/',   flistFileNameID,'/03_Neuron_Selection/');
    dirNameEl = strcat('../analysed_data/',   flistFileNameID,'/01_Pre_Spikesorting/');
    dirNameCl = strcat('../analysed_data/',   flistFileNameID,'/02_Post_Spikesorting/');

    %
    pre_process_data(batchGp{iBatch}.suffixName, batchGp{iBatch}.flistName, 'config_type','exclusive',...
        'patches',batchGp{iBatch}.patches, 'kmeans_reps',1,'threshold', thresholdVal);

end


end
    

