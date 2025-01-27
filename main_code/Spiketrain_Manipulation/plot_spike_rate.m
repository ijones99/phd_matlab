binned = randint(1,100, [1 25])
sigma = 0.015                       % std of kernel = 15ms
edges = [-3*sigma:0.001:3*sigma] 		% Time ranges from -03 st. dev. to 3*st.dev.
kernel = normpdf(edges,0,sigma);
kernel = kernel*0.001               % multiply by bin width so that the prob. sum to zero
s=conv(binned,kernel);              % convolve spike data with the kernel
center = ceil(length(edges)/2)		% find the index of the kernel center
s=s(center:1000+center-1);  		% trim out the relevant portion of the spike density
