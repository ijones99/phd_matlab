function cellOut = fields_to_cell(myStruct, varargin)
% cellOut = FIELDS_TO_CELL(myStruct)
%
% varargin:
%      'strrep_char'
%
%
strRepChar = '';

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'strrep_char')
            strRepChar = varargin{i+1};
        end
    end
end


fieldNames = fields(myStruct);

numFlds = length(fieldNames);

cellOut  = cell(numFlds,1);

for i=1:numFlds
    
    currFldVal = getfield(myStruct,fieldNames{i});
    
    if ~isempty(strRepChar)
        currFldName = strrep(fieldNames{i},'_',strRepChar);
    else
        currFldName = fieldNames{i};
    end
    
    if isnumeric(currFldVal)
        cellOut{i}= sprintf('%s: %03.2f', currFldName , currFldVal);
    else
        cellOut{i}= sprintf('%s: %s', currFldName , currFldVal);
    end

end



end