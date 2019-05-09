function s  = conv_gaussian_with_spike_train(binned, sigma, binWidth)
% function s = conv_gaussian_with_spike_train(binned, sigma, binWidth)
% binned: binned timestamps [ts_1....ts_end]
% binWidth: in seconds, size of bins to use
% sigma: gaussian kernel size

mu = 0;

if nargin < 3
    binWidth = 0.025;
end
if nargin < 2
    sigma = 0.025; %Standard deviation of the kernel = 15 ms
end

edges=[-6*sigma:binWidth:6*sigma]; %Time ranges form -3*st. dev. to 3*st. dev.

kernel = ifunc.basic.normalize(normpdf(edges,mu,sigma)); %Evaluate the Gaussian kernel

% kernel = kernel.*binWidth; %Multiply by bin width so the probabilities sum to 1
if ~isempty(binned)
    s=conv(binned,kernel,'same'); %Convolve spike data with the kernel
else
    s = 0;
end

% center = ceil(length(edges)/2); %Find the index of the kernel center s=s(center:1000+center-1); %Trim out the relevant portion of the spike density 

% figure, plot([1:length(binned)],binned), hold on
% plot(1:length(s),s,'r')

end