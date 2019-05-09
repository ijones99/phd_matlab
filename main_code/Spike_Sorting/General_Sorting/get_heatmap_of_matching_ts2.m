function [heatMap] = get_heatmap_of_matching_ts2(binWidthMs,  tsMatrix, varargin)
selFileInds = [];

% function [heatMap, neuronTs] = compare_ts(binWidthMs)
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp(varargin{i}, 'sel_inds')
            selFileInds = varargin{i+1}; 
        end
        
    end
end


% restrict to selected indices
if ~isempty(selFileInds)
    tsMatrix =  tsMatrix(selFileInds);
    
    
end
% binWidth is in msec
% create matrix for heat map
heatMap = single(zeros(length(tsMatrix) ));
% bin the timestamps

for i=1:length(tsMatrix)
    tsMatrix{i}.ts = single(round2(tsMatrix{i}.ts,binWidthMs*0.001)) ;
end

textprogressbar('calculating heat map... ')
iProgress = 1; numberCalculations = single(length(tsMatrix)^2);
savedMatchingPercentages = [];
for iHeatMapY = 1:length(tsMatrix)
    %     iHeatMapY
    for iHeatMapX = 1:length(tsMatrix)
        % subtract timestamps from each combination
        %         matchedTs = intersect(tsMatrix{iHeatMapY}.ts, tsMatrix{iHeatMapX}.ts);
        if length(tsMatrix{iHeatMapY}.ts) >= length( tsMatrix{iHeatMapX}.ts)
            numMatchedTs = sum(ismember(tsMatrix{iHeatMapY}.ts, tsMatrix{iHeatMapX}.ts));
            savedMatchingPercentages(iProgress)=single(numMatchedTs/length(tsMatrix{iHeatMapY}.ts));
        else
            savedMatchingPercentages(iProgress)=single(0);
        end
        heatMap(iHeatMapY, iHeatMapX) = ...
            savedMatchingPercentages(iProgress);
        iProgress = iProgress+1;
    end
    
    textprogressbar(100*iProgress/numberCalculations);

end
textprogressbar('end.');
figure, plot(savedMatchingPercentages);
end