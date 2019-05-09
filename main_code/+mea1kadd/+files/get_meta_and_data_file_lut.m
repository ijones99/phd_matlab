function metaAndDataLUT = get_meta_and_data_file_lut(expDate,varargin)
% metaAndDataLUT = GET_META_AND_DATA_FILE_LUT(expDate)
%
% Descr. This function creates a lookup table for the meta data
% and the data files. There can be one meta data file for many data files,
% as there is one file for each stimulation electrode combination. When only one
% stimulation electrode combination in the set, then the meta file will
% provide information for one data file.

dirName = ['/net/bs-filesvr01/export/group/hierlemann/recordings/Mea1k/ijones/', expDate,'/data/'];

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'dir_name')
            dirName = varargin{i+1};
        elseif strcmp( varargin{i}, 'file_name')
            name2 = varargin{i+1};
        end
    end
end


fileNames = filenames.get_filenames('*',dirName);

metaAndDataLUT = {};
fileNamesOnly = {};

for i = 1:length(fileNames)
    % get fileNames
    if ~strcmp(fileNames(i).name,'.') && ~strcmp(fileNames(i).name,'..')
        fileNamesOnly{end+1} = fileNames(i).name;
    end
end
%%

% get metafile indices
idxMeta = cells.strfind(fileNamesOnly,'meta');
idxH5 = cells.strfind(fileNamesOnly,'.raw.h5');

for i=2:length(idxMeta)
    % idx for files between meta files
    currBtwnMetaIdx = idxMeta(i-1)+1:idxMeta(i)-1;
    currDataFileIdx = intersect(currBtwnMetaIdx,idxH5);
    
    
    if ~isempty(currDataFileIdx)
        szLUT = size(metaAndDataLUT,1);
        metaAndDataLUT(szLUT+1:szLUT+length(currDataFileIdx),1) = fileNamesOnly(idxMeta(i));
        metaAndDataLUT(szLUT+1:szLUT+length(currDataFileIdx),2) = fileNamesOnly(currDataFileIdx);
    end
end

end

