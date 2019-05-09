function [heatMap, neuronTs] = compare_ts(binWidthMs)
% function [heatMap, neuronTs] = compare_ts(binWidthMs)
% binWidth is in msec

% directory
dirName = '../analysed_data/T11_27_53_5/03_Neuron_Selection/';

% promtp
aa = input(strcat('dir name = ',dirName,' ok?'));

% bin width
binWidthSec = binWidthMs*0.001; % sec

% file types to open
fileNamePattern = fullfile(dirName,'st_*mat');

% obtain file names
fileNames = dir(fileNamePattern);

% init struct
neuronTs = struct('name', {}, 'ts', {});

for iFile=1:length(fileNames)
    %     iFile
    % load file
    inputFileName = fileNames(iFile).name;
    load(fullfile(dirName,inputFileName));
    
    % struct name for struct that is read into this function
    periodLoc = strfind(inputFileName,'.');
    inputMatrixName = inputFileName(1:periodLoc-1);
    
    % temporary name for matrix
    neuronTs{iFile}.name = inputMatrixName;
    % assign timestamps and round to nearest msec
    neuronTs{iFile}.ts = round2(eval([inputMatrixName,'.ts']),binWidthSec);
end

% create matrix for heat map
heatMap = zeros(length(neuronTs) );

for iHeatMapY = 1:length(neuronTs)
    %     iHeatMapY
    for iHeatMapX = 1:length(neuronTs)
        
        % subtract timestamps from each combination 
        matchedTs = intersect(neuronTs{iHeatMapY}.ts, neuronTs{iHeatMapX}.ts);
        
        heatMap(iHeatMapY, iHeatMapX) = ...
            length(matchedTs)/(length(neuronTs{iHeatMapY}.ts)+length(neuronTs{iHeatMapX}.ts));
        
    end
end
    

end