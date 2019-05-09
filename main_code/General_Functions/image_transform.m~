%% load image
[imageLoaded map alpha] = imread('~/Matlab/Light_Stimuli/LetterStimuli/a_norm.png');

%% show image
imshow(imageLoaded);

%% blur image
h = fspecial('gaussian',10,10);
I=imfilter(imageLoadedInv,h);
imshow(I);

%% 