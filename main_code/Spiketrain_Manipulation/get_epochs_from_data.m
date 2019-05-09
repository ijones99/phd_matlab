function epochData = get_epochs_from_data(data, epochInds)
% epochData = GET_EPOCHS_FROM_DATA(data, epochInds)
%   GET_EPOCHS_FROM_DATA is for obtaining epochs of data from a specific channel
%   
%   data: [voltage values] x [channel] . Ex.: mea1.getData(:,1) 
%   epochInds: [number timepoints] x [time range]. Obtain from calculate_epoch_inds
%
%
%   epochData output: [number timepoints] x [time range]. To plot,
%   transpose the matrix.
%   
%
%   author: ijones

epochData = data(epochInds);

end
