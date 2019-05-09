function [metaData doubleEls] = load_metadata(filename, varargin)
% [metaData doubleEls] = LOAD_METADATA(filename)

doInterleavedStim = 0;
rgcRank = 1;
headerLineSkip =[];
numHeaderLines=2;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'file_dir')
            name1 = varargin{i+1};
        elseif strcmp( varargin{i}, 'file_name')
            name2 = varargin{i+1};
        elseif strcmp( varargin{i}, 'rgcNo')
            rgcRank = varargin{i+1};
            doInterleavedStim = 1;
        elseif strcmp( varargin{i}, 'interleaved_stim')
            doInterleavedStim = 1;
        elseif strcmp( varargin{i}, 'skip_header_line')
            headerLineSkip = varargin{i+1};
        elseif strcmp( varargin{i}, 'number_header_line')
            numHeaderLines = varargin{i+1};
        end
    end
end


delimiterIn = ':';

str = fileread(filename);
str = strrep(str,'+/- ','');

% look for doubles
commaLoc = find(str==',');
doubleEls = [];
if ~isempty(commaLoc)
    expr = '[^\n]*,[^\n]*';
    fileread_info = regexp(str, expr, 'match');
    if ~isempty(headerLineSkip)
        fileread_info(headerLineSkip:numHeaderLines:end)=[];
    end
    for i=1:length(fileread_info);
       currElRead = sscanf(fileread_info{i}, '%*s %*s %d,%d ', [1, inf]);
       
       if ~isempty(currElRead)
           doubleEls(end+1,:)=currElRead;
       end
    end
end
strToRem = {',', 'StimChannel:','ReadoutChannel:'};
strToRep = {'', 'StimChannel','ReadoutChannel'};
for i=1:length(strToRem)
    str = strrep(str,strToRem{i},strToRep{i});
end
% Read the first line of the file, ignoring the characters Type in the second field.
metaData = textscan(str,'%s%d', 'delimiter', ':');
 
if doInterleavedStim
    metaData{2} = metaData{2}(1:2:end);
    metaData{1} = metaData{1}(1:2:end);
    if rgcRank == 1
        idxStart = 1;
    elseif rgcRank == 2
        idxStart = 2;
    end
    metaData{2} = metaData{2}(idxStart:2:end);
    metaData{1} = metaData{1}(idxStart:2:end);
    
end
end

