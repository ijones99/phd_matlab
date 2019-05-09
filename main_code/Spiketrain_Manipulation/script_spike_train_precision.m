


%% script analysis of spike train precision 

binWidth = 0.001; % seconds
repeatLengthSec = 29; % seconds
sigma = 0.003; % seconds

% get psth 
psthOutput = get_psth(spikeTrain, binWidth, repeatLengthSec);

% convolve data
psthOutConv = conv_binned_data_with_kernel(binnedData,binWidth,sigma,kernelStepSize);

% get local minima and maxima
[pksMins,locsMins] = findpeaks(psthOutConv);
[pksMaxs,locsMaxs] = findpeaks(-psthOutConv); pksMaxs = -pksMaxs;



