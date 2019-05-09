function stCell = extract_st_to_cell(gdf, clusNo, stimChangeTs, varargin)
% stCell = EXTRACT_ST_TO_CELL(gdf, clusNo, stimChangeTs)
% SETTINGS
adjustToZero = 1;

segIdx = [];

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'seg_idx')
            segIdx = varargin{i+1};
            warning('Not yet implemented');
        end
    end
end

%segments to output
if isempty(segIdx)
    segIdx = 1:length(stimChangeTs);
else
    segIdx = unique([segIdx segIdx+1]);
end

% get all st
stIdx = find(gdf(:,1)==clusNo);
stAll = gdf(stIdx,2);

stCell = extract_spiketrain_repeats_to_cell(stAll, ...
    stimChangeTs,adjustToZero);


end