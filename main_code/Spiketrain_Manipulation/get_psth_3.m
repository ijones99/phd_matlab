function [psthOutput ] = get_psth_3(spikeTrain, binSize, repeatLengthSec, varargin)

%   -> spikeTrain: cells of spiketrain repeats. All are adjusted so that
%       the start of each repeat is zero
%   -> binSize: binning size in sec for binning of spikes
%   ARGUMENTS
%   -> 'convolve' sigma [0.8]

doConvolve = 0; % for convolving with gaussian

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'convolve')
            doConvolve = 1;
            sigmaVal = varargin{i+1};
        else
            if i/2 ~= round(i/2) % for odd numbers
                fprintf('argument not recognized\n');
            end
            
        end
    end
end


% settings
hsize = 7;

numberBins = round(repeatLengthSec/binSize); % binning of spikes

% bin spikes
psthData = hist(spikeTrain, numberBins); % bin all repeats


sumPsth = sum(psthData,1); % take the sum of the binned data

if doConvolve % convolve with Gaussian
    h = fspecial('gaussian', hsize,sigmaVal);
    psthOutput = conv(sumPsth,h(((hsize)-1)/2+1,:), 'same');
else
    psthOutput = sumPsth;
end

end
                       