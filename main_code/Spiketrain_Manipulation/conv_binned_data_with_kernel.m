function s = conv_binned_data_with_kernel(binnedData,binWidth, sigma, kernelStepSize)
% FUNCTION S = CONV_BINNED_DATA_WITH_KERNEL(BINNEDDATA,BINWIDTH, SIGMA, KERNELSTEPSIZE)
% binnedData = data that has been binned (each value is a count of spikes)
% binWidth = the width of the bins (in seconds)
% sigma = time range for kernel (in seconds)
% kernelStepSize = step size for the edges of the kernel
%
% author: ijones

if nargin < 2
    binWidth = 0.001;
end
if nargin < 2
    sigma = 0.003;
end
if nargin < 3
    kernelStepSize = 0.001;
end

edges = [-3*sigma:kernelStepSize:3*sigma] 		% Time ranges from -03 st. dev. to 3*st.dev.
kernel = normpdf(edges,0,sigma);                % create gaussian kernel
kernel = kernel*binWidth;                       % multiply by bin width so that the prob. sum to zero
s=conv(binnedData,kernel,'same');               % convolve spike data with the kernel

end