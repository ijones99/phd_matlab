function [outputData overDistThreshIdx ] = ...
    find_closest_bar_offset_match_for_given_point_v2(stimFrameInfo, xyPoint, varargin)
% FIND_CLOSEST_BAR_OFFSET_MATCH_FOR_GIVEN_POINT(stimFrameInfo, xyPoint)
%
% Purpose: find the moving bars that are closest to the location of the 
% neuron.
% 
% !!NOTE - does not do transformation for projector -> chip function
%
% Arguments:
%   stimFrameInfo
%   xyPoint
%
% outputData = [degreesScreen, degreesOnChip, offset, distance]

maxDistThresh = 100;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'dist_allow')
            maxDistThresh = varargin{i+1};
        end
    end
end


offsetVals = unique(stimFrameInfo.offset);
allAngles = unique(stimFrameInfo.angle);

for iAngle = 1:length(allAngles)
    d = zeros(1,3);
    for iOffset = 1:length(offsetVals)
        
        geometry.angle2xy(allAngles(iAngle),offsetVals(iOffset))
        
    end
    [junk idxMinD] = min(d);
    outputData(iAngle, 3) = offsetVals(idxMinD); %offset
    outputData(iAngle, 4) = d(idxMinD); 
    
end
overDistThreshIdx = find(outputData(:,4)> maxDistThresh);
if ~isempty(overDistThreshIdx)
   warning(sprintf('Distance threshold of %d um exceeded.',maxDistThresh )) 
end
end