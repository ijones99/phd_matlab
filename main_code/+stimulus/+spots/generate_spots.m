
um2Pix = 1.7500;

frameEdgeLength = 1200;
CircleDiameterUm = [75 150 300 600 900];
CircleDiameterPix = round(CircleDiameterUm/um2Pix);
blankMat = ones(frameEdgeLength,frameEdgeLength, length(CircleDiameterPix));

figure
for i=1:length(CircleDiameterPix)
    currIm = ones(frameEdgeLength);
    [indsSurround C] = get_circle_inds(frameEdgeLength, CircleDiameterPix(i), 'surround');
    [indsCtr C] = get_circle_inds(frameEdgeLength, CircleDiameterPix(i), 'center');
    currIm(indsCtr) = 0;
    blankMat(:,:,i) = currIm;
    subplot(2,3,i)
    imagesc(blankMat(:,:,i));axis square
end

