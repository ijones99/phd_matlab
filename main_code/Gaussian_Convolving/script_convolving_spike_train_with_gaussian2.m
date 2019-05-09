
binned = [0 0 0 0 0 50 100 50 50 50 50 0 0 0 0 0 0 0 0 50 100 200 200 100 50 40 0 0 0 0 ];
sigma = .002; %Standard deviation of the kernel = 15 ms
binWidth = 0.001;
edges=[-3*sigma:binWidth:3*sigma]; %Time ranges form -3*st. dev. to 3*st. dev.
kernel = normpdf(edges,0,sigma); %Evaluate the Gaussian kernel
kernel = kernel*binWidth ; %Multiply by bin width so the probabilities sum to 1
s=conv(binned,kernel,'same'); %Convolve spike data with the kernel
center = ceil(length(edges)/2); %Find the index of the kernel center s=s(center:1000+center-1); %Trim out the relevant portion of the spike density 




figure, plot([1:length(binned)],binned), hold on
plot(1:length(s),s,'r')