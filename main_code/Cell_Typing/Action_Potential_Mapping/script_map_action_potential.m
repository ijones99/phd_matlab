
meanAllFrames = mean(zAll,3);
zDiff = [];
hsize = [10 10];
sigma = 5;

figure, axis square

h = fspecial('disk',sigma)
zDiff = [];
for i=1:size(zAll,3)-1
    % take difference
    zDiff(:,:,end+1) = zAll(:,:,i) - zAll(:,:,i+1);
    % get median value
    zDiffRow = remove_dims(zDiff(:,:,end));
    medianZDiff= nanmedian(zDiffRow);
    % calibrate each image
    zDiff(:,:,end) = abs(zDiff(:,:,end) - medianZDiff);
    
    % filter frame
    zDiff(:,:,end) = imfilter(zDiff(:,:,end),h,'replicate');
    imagesc(zDiff(:,:,end));
    pause(0.1);
    
end

%%
maxZDiff = sum((zDiff),3);
h = fspecial('unsharp');
% maxZDiff = imfilter(maxZDiff, h, 'replicate');
figure
imagesc(maxZDiff )
