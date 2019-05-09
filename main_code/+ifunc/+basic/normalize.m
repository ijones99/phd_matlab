function outputMat = normalize(outputMat, varargin)
% function outputMat = normalize(outputMat, varargin)
% VARARGIN: norm_to_max_value

P.norm_to_max_value=1; 

% check for arguments
P = mysort.util.parseInputs(P, varargin, 'error');

outputMat = outputMat-min(min(min(outputMat)));
outputMat = outputMat/max(max(max(max(abs(outputMat)))))*P.norm_to_max_value;

end