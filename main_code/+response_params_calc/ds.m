function paramOut_ds = ds(stimDirections_deg, avgFRPerDir,varargin)
% paramOut_ds = DS(stimDirections_deg, avgFRPerDir,varargin )
%
% varargin
%   'min_thr'
%   'no_response_out_val'


minThreshold = 0;
outputForNoResponse = nan;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'min_thr')
            minThreshold = varargin{i+1};
        elseif strcmp( varargin{i}, 'no_response_out_val')
            outputForNoResponse = varargin{i+1};
        end
    end
end



%
% paramOut_ds = RESPONSE_PARAMS_CALC.DS(stimDirections_deg, avgFRPerDir)
%
% Purpose: Direction Selectivity Index (DS Index).
%
% Arguments: 
%   stimDirections_deg = stimulus directions
%   avgFRPerDir = average firing rate in each direction
%
% This measures the directional tuning of each cell. It was calculated from
% the cells' responses to the moving bar protocol. We calculated the average 
% firing rate during the presentation of a bar moving in eight equally 
% separated directions (Fig. 2D). The direction selectivity of each cell 
% was defined as the vector average of mean firing rate: 
%
% DS_idx = sum(over all directions) of N_d/R_d
%
% Where N_d are vectors pointing in the direction of the stimulus and having length R_d, 
% equal to the mean firing rate recorded during the stimulus presentation. 
% The DS Index ranges from 0, when the average firing rates are equal 
% in all stimulus directions, to 1, when a cell responds to a single direction only.
%
% 


% [directions (degrees), avg_firing_rate] -> calc xy vectors
% N_d = geometry.vector_xy_components(stimDirections_deg, avgFRPerDir);
[x, y] = pol2cart(stimDirections_deg*pi/180, avgFRPerDir);
N_d = [x' y'];

% divide by avg_firing_rate in each dir
% N_d_over_R_d = N_d./[avgFRPerDir', avgFRPerDir'];
% [rows,cols] = find(isnan(N_d));
% rowsUnique = unique(rows);
% N_d_over_R_d(rowsUnique,:) = [];

% sum responses & calculate final vector value
vectorSumN_d = sum(N_d);
% calculate DS param
% vectorSumL = geometry.vector_lengths(vectorSum(1),vectorSum(2));
sumAllLengths = sum(geometry.vector_lengths(N_d(:,1),N_d(:,2)));
vectorSumN_d_L = geometry.vector_lengths(vectorSumN_d(1),vectorSumN_d(2));


paramOut_ds = round2(vectorSumN_d_L/sumAllLengths,0.001);


