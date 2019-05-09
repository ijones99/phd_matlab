function [outputRGB fileNameMeanVal] = brightness2rgb( percentBrightness, varargin )
% rgb = brightness2rgb( percentBrightness )
%
% varargin
%   'dir'
%   'file_name_percent_vals'
%   'file_name_rgb_vals'
%
% Use: get rgb value to use for beamer
%

dirBrightnessMeasurements = ...
    '+beamer/settings/11Apr2014/';
fileNamePercentVal = '11Apr2014_RGB_percentVal.mat';
fileNameMeanVal = '11Apr2014_RGB_meanVal.mat';

fileNameXAxis = '11Apr2014_RGB_xAxis.mat';

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'dir')
            dirBrightnessMeasurements = varargin{i+1};
        elseif strcmp( varargin{i}, 'file_name_percent_vals')
            fileNamePercentVal = varargin{i+1};
        elseif strcmp( varargin{i}, 'file_name_rgb_vals')
            fileNameRGBVal = varargin{i+1};
        end
    end
end


% xaxis
loaddataAxis = load(fullfile(dirBrightnessMeasurements,fileNameXAxis));
clear fieldNames; fieldNames = fields(loaddataAxis);
xAxis=getfield(loaddataAxis,fieldNames{1});

% brightness
loaddataVal = load(fullfile(dirBrightnessMeasurements,fileNamePercentVal));
clear fieldNames; fieldNames = fields(loaddataVal);
valBrightnessPercent=getfield(loaddataVal,fieldNames{1})*100;

diffToInput = abs(valBrightnessPercent-percentBrightness);
[Y,diffToInputIdxAscend] = sort(diffToInput,1,'ascend');

%  idx of values nearest to input
diffToInputIdxMin = diffToInputIdxAscend(1:2);

% get linearly-calculated value
if diffToInputIdxMin(2) > diffToInputIdxMin(1)
    % range of RGB: valBrightnessPercent(diffToInputIdxMin)
    % 
    
    closestIdx = diffToInputIdxMin(1:2);
else
     % range of RGB: valBrightnessPercent(diffToInputIdxMin)
     closestIdx = diffToInputIdxMin(2:-1:1);
end
     closestBrightness = valBrightnessPercent(closestIdx);
     %      percentBrightness
     percentOfInterval = (percentBrightness-closestBrightness(1))/...
         diff(closestBrightness);
     closestRGBs = xAxis(closestIdx);
     outputRGB = round(closestRGBs(1)+diff(closestRGBs)*percentOfInterval);

end