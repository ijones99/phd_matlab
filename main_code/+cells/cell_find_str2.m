function outputIdx = cell_find_str(cellName, searchStr, varargin )
% outputIdx = CELL_FIND_STR(cellName, searchStr, varargin )
%
% varargin
%   'partial_match' (default is exact match)
%   'two_and_exp': cell of two strings. AND 

exactMatch = 1;
twoAnd = 0;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'partial_match')
            exactMatch = 0;
        elseif strcmp( varargin{i}, 'two_and_exp')
            twoAnd  = 1; 
            exactMatch = 0;
        end
    end
end

outputIdx = [];
for i=1:length(cellName)
    % exact match
    if exactMatch
        if strcmp(cellName{i},searchStr)
            outputIdx(end+1) = i;
        end
    elseif twoAnd
        if sum(strfind(cellName{i},searchStr{1})) && sum(strfind(cellName{i},searchStr{2}))
            outputIdx(end+1) = i;
        end
    else
        if sum(strfind(cellName{i},searchStr))
            outputIdx(end+1) = i;
        end
        
    end
end