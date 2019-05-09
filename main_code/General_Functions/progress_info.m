function progress_info(currState, totalNumStates, preStr)
% function PROGRESS_INFO(currState, totalNumStates,preStr)

if nargin < 3
    preStr = '';
end

fprintf('%sProgress %3.0f percent.\n', preStr, 100*currState/totalNumStates);


end