function [choiceIdx choiceVal ] = choose_num_in_struct(structName, fieldName)
% choiceIdx = CHOOSE_NUM_IN_STRUCT(structName, fieldName)

fprintf('>>>>>>>>> Options: \n\n');

for i=1:length(structName)
    eval(sprintf('currStruct = structName(i).%s;', fieldName));
    fprintf('%d) %s\n', i, currStruct);

end

choiceIdx = input(sprintf('\nPlease enter number of choice [%d-%d] >> ',...
    1,length(structName)));




eval(sprintf('choiceVal = structName(choiceIdx).%s;', fieldName));

end