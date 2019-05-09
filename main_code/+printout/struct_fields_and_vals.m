function struct_fields_and_vals(myStruct,varargin)
% struct_fields_and_vals(myStruct)
%
% Purpose:
%   Print out 

doPlotFldNums =0;


% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'numbered')
            doPlotFldNums = 1;
   
        end
    end
end


fieldNames = fields(myStruct);
numFields = length(fieldNames);
numEntries = length(getfield(myStruct,fieldNames{1}));

for i = 1:numFields
    currFld = fieldNames{i};
    currVal = getfield(myStruct, currFld);
    
    if doPlotFldNums
       fprintf('%d) ', i); 
    end
    
    if isnumeric(currVal)
        fprintf('%s = %d\n',currFld,currVal  );
    else
         fprintf('%s = %s\n',currFld,currVal  );
    end
    
    
end




end