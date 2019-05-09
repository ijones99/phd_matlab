function print_fields(structName, fieldNames)
isCell1 = 0;
eval(sprintf('isCell1 = iscell(structName.%s);', fieldNames{1}));
isCell2 = iscell(structName);
if isCell1 | isCell2
eval(sprintf('lenStruct = length(structName.%s);', fieldNames{1}));
else
   lenStruct = 1; 
end
fprintf('\n\n');
% heading
for i=1:length(fieldNames)
    fprintf('%s | ', fieldNames{i})
end
fprintf('\n');
for i=1:lenStruct
    % print number
    fprintf('%d) ', i);
    
    % print values for each line
    for iFld=1:length(fieldNames)
        isCell = 0;
        eval(sprintf('isCell = iscell(structName.%s);', fieldNames{iFld}));
        if isCell
            eval(sprintf('currFldVal = structName.%s(i);', fieldNames{iFld}));
        else
             eval(sprintf('currFldVal = structName.%s;', fieldNames{iFld}));
        end
        if isnumeric(currFldVal)
            fprintf('%d | ',currFldVal);
        elseif iscell(currFldVal)
            fprintf('%s | ',currFldVal{1});
        else
            fprintf('%s | ',currFldVal);
        end
        
    end
    
    fprintf('\n');
    
    
    
    
end
