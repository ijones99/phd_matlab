function elNumber = get_el_numbers_from_dir(dirName, fileNamePattern,varargin)

specificPartToRemove = [];
returnUniqueEls = 0;
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'part_to_remove')
            specificPartToRemove = varargin{i+1};
        elseif strcmp( varargin{i}, 'unique')
            returnUniqueEls = 1;
                    
        end
    end
end
filesInDir = dir(fullfile(dirName,fileNamePattern));
% cycle through files in dir
for iFileNameList=1:length(filesInDir)

    fileName = filesInDir(iFileNameList).name;
    if isempty(specificPartToRemove)
        locUnderscore = strfind(fileName,'_');
        locN = strfind(fileName,'n');
        elNumber(iFileNameList) = str2num(fileName(locUnderscore+1:locN-1));
    else
        
        locPartToRemove = strfind(fileName,specificPartToRemove );
        elNumber(iFileNameList) = ...
            str2num(strrep(fileName(locPartToRemove+length(specificPartToRemove):end),'.mat',''));
    end

end

if returnUniqueEls
    if exist('elNumber')
        elNumber = unique(elNumber);
    end
end

if ~exist('elNumber')
   elNumber = {}; 
end
end