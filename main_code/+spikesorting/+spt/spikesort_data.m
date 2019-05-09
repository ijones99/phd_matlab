function [flistFileNameID flist flistName] = spikesort_data(varargin)

patchIdx= [];
sortInputOpt = 'elidx';
selectedPatches = {};
thresholdVal = 4.5;
doSaveWithFlistID = 0;
doUseProcFilesList = 0;
doInputFlist= 0;
loadingMethod = '';
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'patch_no')
            sortInputOpt = varargin{i};
            patchIdx = varargin{i+1};
        elseif strcmp( varargin{i}, 'patches') % use actual patch structures
            selectedPatches = varargin{i+1};
        elseif strcmp( varargin{i}, 'use_proc_files_list') % use actual patch structures
            doUseProcFilesList = varargin{i+1};
        elseif strcmp( varargin{i}, 'save_with_flist_id') % use actual patch structures
            doSaveWithFlistID = 1;
        elseif strcmp( varargin{i}, 'flistName') % use actual patch structures
            doInputFlist = 1;
            flistName = varargin{i+1};
        end
    end
end

flist = {}; eval(flistName);
suffixName = strrep(flistName,'flist','');

for i=1:length(flist)
    fprintf('(%d) %s\n', i, flist{i});
end
flistIdx = input('Select files to process >> ');

if strcmp(loadingMethod, 'patches')
    if doInputFlist
        for i=1:length(flistIdx)
            sort_ums_output(flist(flistIdx(i)), 'add_dir_suffix',suffixName, 'patches', ...
                selectedPatches)
        end
        
    end
    
end

end