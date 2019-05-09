function directoryNames = path_name_decomposition(pathName, varargin)
% directoryNames = path_name_decomposition(pathName, partNo)

partNo = [];
reverseRefDir = 0;
strOut = 0;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'part_no')
            partNo = varargin{i+1};
        elseif strcmp( varargin{i}, 'reverse')
            reverseRefDir = 1;
        elseif strcmp( varargin{i}, 'string_out')
            strOut = 1;
        
        end
    end
end


if ~strcmp(pathName(end),'/')
    pathName(end+1) = '/';
end

fwdSlashPts = [strfind(pathName,'/')];

if reverseRefDir
    fwdSlashPts= fwdSlashPts(end:-1:1);
end

% select file part numbers
if isempty(partNo)
    partInds=1:length(fwdSlashPts)-1;
else
    partInds = partNo;
end

directoryNames = cell(length(partInds),1);

if reverseRefDir
    for i=length(partInds):-1:1
        directoryNames{i} = pathName(fwdSlashPts(partInds(i)+1)+1:fwdSlashPts(partInds(i))-1);
        
    end
else
    for i=length(partInds):-1:1
        directoryNames{i} = pathName(fwdSlashPts(partInds(i))+1:fwdSlashPts(partInds(i)+1)-1);
        
    end
    
end

if strOut
    directoryNamesStr = directoryNames{1};
    clear directoryNames;
    directoryNames = directoryNamesStr;
end

end