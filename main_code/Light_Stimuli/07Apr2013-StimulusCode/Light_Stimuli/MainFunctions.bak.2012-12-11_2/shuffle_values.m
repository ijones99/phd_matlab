function values = shuffle_values(values,varargin)

% Function: shuffles input values 
% Inputs:
%     matrix of any dimensions
% Options:
%      varargin 'percent_shuffle': percent of the matrix to shuffle

amountToShuffle = 1;

if ~isempty(varargin)
    for i=1:length(varargin)
        % set percent to shuffle
        if strcmp(varargin{i},'percent_shuffle')
            amountToShuffle = varargin{i+1}/100;
        end
    end
end

% save original format of values
origDimsOfValues = size(values);

% reshape to linear vector
values = reshape(values,1,prod(origDimsOfValues));

% randomly determine which values to shuffle
valueIndsToShuffle = randperm(length(values));
valueIndsToShuffle = valueIndsToShuffle(1:round(length(values)*amountToShuffle));

% value pool to shuffle
valuesToShuffle = values([valueIndsToShuffle]);

% shuffle values
valuesToShuffle = valuesToShuffle(randperm(length(valuesToShuffle)));

% reinsert shuffled values back into main value vector
values(valueIndsToShuffle) = [valuesToShuffle];

% reformat values into original shape
values = reshape(values,origDimsOfValues);

end