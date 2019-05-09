function [firingRate firingRateMax edges] = compute_firing_rates_for_data(...
    stimulusMatrix,allResponseRepeats, searchColumns,startStopTime)
% function [firingRate firingRateMax edges] = compute_firing_rates_for_data(...
%     stimulusMatrix,allResponseRepeats, searchColumns,startStopTime)
% ARGUMENTS
% stimulusMatrix: columns are stimulus variables (e.g. diameter,
% brightenss, etc.
%
% allResponseRepeats: a cell of the responses to the repeated stimuli
%
% search columns: a double matrix that specifies what variables to search
% for along the columns.
%
% startStopTime: what amount of time over which to compute firing rate
% ij
for i=1:size(searchColumns,1)
    
    rowInds = ifunc.mat.find_vals_in_cols(...
        stimulusMatrix, searchColumns(i,:)  );
    
    if isempty(rowInds)
       fprintf('No matches found.\n');
       return;
    end
    
    selRepeats = allResponseRepeats(rowInds);
    
    [firingRate{i} edges] = ifunc.analysis.firing_rate.est_firing_rate_ks(selRepeats,...
        startStopTime);
    firingRateMax(i) = max(firingRate{i});
    
end


end