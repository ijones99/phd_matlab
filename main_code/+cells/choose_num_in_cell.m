function [choiceIdx choiceVal ] = choose_num_in_struct(cellName)
% [choiceIdx choiceVal ]  = CHOOSE_NUM_IN_STRUCT(cellName)

fprintf('>>>>>>>>> Options: \n\n');

for i=1:length(cellName)
    fprintf('%d) %s\n', i, cellName{i});
end

choiceIdx = input(sprintf('\nPlease enter number of choice(s) [%d-%d] >> ',...
    1,length(cellName)));

% selection
for i=1:length(choiceIdx)
    fprintf('choice = %d) %s\n', i, cellName{choiceIdx(i)});
end

choiceVal = cellName(choiceIdx);

end