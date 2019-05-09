close all
for i=1:26
    figure
%    imshow(twoD_movie_upsampled1(:,:,i)); 
    imshow(newMov(:,:,i),map)
end

%%
H = fspecial('disk',25);
blurred = imfilter(twoD_movie_upsampled(:,:,j),H,'replicate');
figure
imagesc(blurred); title('Blurred Image');

%% plot all

%% stderror

numPerPatch = [ 12    31    13    18];
diffFromMean = numPerPatch-mean(numPerPatch)
stdError = sqrt(sum(diffFromMean.^2))/length(numPerPatch)


