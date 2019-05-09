function segmentBoundaries = get_segment_boundaries(stMatrix, selectSegment,frameno)
% function segmentBoundaries = get_segment_boundaries(stMatrix, selectSegment)
%
% This function takes the tsMatrix cell as input and returns the boundaries
% of the particular segment. This is used when multiple datasets are 
% spikesorted together.
% INPUTS:
%   tsMatrix: timestamp matrix cell
%   selectSegment: which segment of the data is selected

if isfield(stMatrix, 'file_switch_ts')
    numSegments = length(stMatrix.file_switch_ts);
else
    numSegments  = 1;
end
% Access switch information
if selectSegment == numSegments
     segmentBoundaries = [stMatrix.file_switch_ts(selectSegment)  ...
        length(frameno)]; % values are in raw increments (2e4 Hz)
    
else
    segmentBoundaries = [stMatrix.file_switch_ts(selectSegment)  ...
        stMatrix.file_switch_ts(selectSegment+1)-1]; % values are in raw increments (2e4 Hz)
    
end



% cannot have zero values
segmentBoundaries(find(segmentBoundaries==0))=1;

end