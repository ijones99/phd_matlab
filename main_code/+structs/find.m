function idx = find(myStruct, searchTerm)

fieldName = '';

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'field')
            fieldName = varargin{i+1};
        end
    end
end

if ~isempty(fieldName) % fieldname specified
    
    
end








end
