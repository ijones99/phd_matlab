function struct_to_commandline(myStruct)
% struct_to_commandline(myStruct)
%
% Purpose:
%   Print out 



fieldNames = fields(myStruct);
numFields = length(fieldNames);
numEntries = length(getfield(myStruct,fieldNames{1}));

for i = 1:numFields
   fprintf('%s\t', fieldNames{i})
   if i<numFields
       fprintf('|\t');
   else
       fprintf('\n');
   end
end

extractedData= {};
for iField = 1:numFields 
    extractedData{iField} = getfield( myStruct,fieldNames{iField});
    if isrow(extractedData{iField})
        extractedData{iField} = extractedData{iField}';
    end
end

for iEntry = 1:numEntries
    for iField = 1:numFields
        if isnumeric(extractedData{iField})
            lengthCurrField = length(extractedData{iField}(iEntry,:));
            if lengthCurrField  > 1
                fprintf('[');
            end
            for i=1:lengthCurrField 
                fprintf( '%d\t', extractedData{iField}(iEntry,i));
            end
            if lengthCurrField  > 1
                fprintf('\b]\t');
            end
        else 
                fprintf( '%s\t', extractedData{iField}{iEntry});
        end
        
    end
    fprintf('\n');
end


end