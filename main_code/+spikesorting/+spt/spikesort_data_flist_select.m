function [flistFileNameID flist flistName] = spikesort_data_flist_select(varargin)
% [flistFileNameID flist flistName] = SPIKESORT_DATA_FLIST_SELECT(varargin)
%
% Purpose: do spikesorting by selecting flist file and then center
% electrode
%

patchIdx= [];
sortInputOpt = 'elidx';
selectedPatches = {};
thresholdVal = 4.5;
doSaveWithFlistID = 0;
doUseProcFilesList = 0;
doInputFlist= 0;
numEls = 7;
quitLoopFlist = 0;
runNo = -1;

doRunFromInput = 0;
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'input_cluster_info_cell')
            doRunFromInput = 1; 
            clusterInfo = varargin{i+1};
            if strcmp( varargin{i}, 'runNo')
                doRunFromInput = 1;
                runNo = varargin{i+1};
            end
        end
    end
end


while quitLoopFlist == 0 & runNo ~= 0
    % make flist
    if ~doRunFromInput 
        runNo = input('Enter run no >> ');
    end
    [stimNames  stimNamesIdx] = stimulus.select_stim_type;
    flistName = sprintf('flist_%s_n_%02d',stimNames{stimNamesIdx}, runNo);
    flist = make_flist_select([flistName,'.m']);
    suffixName = strrep(flistName,'flist','');
    
    % load patches
    elConfigInfo = flists.get_elconfiginfo_from_flist(flist);
    selectedPatches = select_patches_exclusive(numEls, elConfigInfo );
    
    % enter ctr els
    ctrElidx = input('Enter center elidx values >> ');
    
    % select patches
%     selIdxNos = configs.find_patches_containing_els(selectedPatches, ctrElidx);
  
    for iPatch = 1:length(ctrElidx)
        sort_ums_output(flist, 'add_dir_suffix',suffixName, 'sel_els_in_dir', ...
            ctrElidx(iPatch));
    end
    fileInfoCell.runNo = runNo;
    fileInfoCell.flist = flist;
    fileInfoCell.flistName = flistName;
    fileInfoCell.stimType = stimNames{stimNamesIdx};
    spikesorting.extract_spiketimes_from_cl_files('input_file_info_cell',fileInfoCell,'force');
    
end

end
