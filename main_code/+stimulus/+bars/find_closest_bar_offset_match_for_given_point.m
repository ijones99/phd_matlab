function [outputData overDistThreshIdx ] = ...
    find_closest_bar_offset_match_for_given_point(stimFrameInfo, xyPoint, varargin)
% FIND_CLOSEST_BAR_OFFSET_MATCH_FOR_GIVEN_POINT(stimFrameInfo, xyPoint)
%
% Purpose: find the moving bars that are closest to the location of the 
% neuron.
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


allAngles = [0:45:359]';
% angles on chip
allAnglesOnChip = beamer.beamer2array_vector_transposition(allAngles);

outputData(:,1) = (allAngles) ;
outputData(:,2) = (allAnglesOnChip);
offsetVals = unique(stimFrameInfo.offset);

for iAngle = 1:length(allAngles)
    d = zeros(1,3);
    for iOffset = 1:length(offsetVals)
        % calc distance all offsets
        lineScreen = beamer.beamer2array_vector_offset_and_transpose2(...
            allAngles(iAngle), offsetVals(iOffset));
        d(iOffset) = geometry.perpendicular_dist_pt_to_line(lineScreen,xyPoint);
        
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