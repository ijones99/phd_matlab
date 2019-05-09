function outStruct = run_function_in_all_dirs(commandToRun, dirNames)
% outStruct = RUN_FUNCTION_IN_ALL_DIRS(commandToRun, dirNames)
% 
% note: values can be written to outStruct within the loop. Use "i" to
% access struct positions.
%
% Arguments:
%   commandToRun: can be a string or a cell
%   dirNames: cell or string of directory names


outStruct = [];

if isstr(dirNames) % in case a string is entered. 
    dirNamesNew = {dirNames};
    clear dirNames;
    dirNames = dirNamesNew;
end

if isstr(commandToRun) % check whether input is a string or a cell.
    commandType = 1; %string
else
    commandType =2; % cell
end

for i =1:length(dirNames)
    cd(dirNames{i});
    fprintf('cd %s:\n', dirNames{i});
    if commandType==1
        eval([commandToRun]);
    elseif commandType==2
        for iCom = 1:length(commandToRun)
            eval(commandToRun{iCom});
        end
    else
        error('wrong input type')
    end
    fprintf('+++++++++++++++++++++++++++\n'); % spacer
end