%% Variables
%Brightness Values
blackVal = 0;
whiteVal = 255;
darkGrayVal = 115;
grayVal = 163;
lightGrayVal = 205;

%% load letter
try
    [imageLoaded map alpha] = imread('~/Matlab/Light_Stimuli/LetterStimuli/a_norm.png');
end
try
    [imageLoaded map alpha] = imread('a_norm.png');
end  
%% make it blue
imageVector = zeros(size(imageLoaded) ) ;
imageVector(:,:,2) = imageLoaded(:,:,2);
imageVector(:,:,3) = imageLoaded(:,:,3);

%% plot image
imshow(imageVector)

%% filter
close all
% imageVector = imageLoaded;
% find area of letter
letterAreaPix = length(find(imageVector == 0));
percentArea = .1; % percent of the area 
selArea = (percentArea/100)*letterAreaPix;
% radiusOfArea = sqrt( selArea/pi() ); % find the radius of a circle that describes this area
edgeLengthOfArea = sqrt(selArea);
HSIZE = [ ceil(edgeLengthOfArea) ceil(edgeLengthOfArea)];
SIGMA = 5;
h = fspecial('gaussian',HSIZE,SIGMA); 

% h = fspecial('motion', 50, 45);
% imageVector=im2double(imageVector);
% imageFiltered = imfilter(imageVector ,h);
% imageFiltered = imcomplement(imfilter(imcomplement( imageVector ),h));
%plot image
j=1;
for i=[.01 .1 1 10]
   figure
   letterAreaPix = length(find(imageVector(:,:,2) == 0));
   percentArea = i; % percent of the area
   selArea = (percentArea/100)*letterAreaPix;

   edgeLengthOfArea = sqrt(selArea);
   HSIZE = [ ceil(edgeLengthOfArea) ceil(edgeLengthOfArea)];
   SIGMA = 5;
   h = fspecial('gaussian',HSIZE,SIGMA);
   imageFiltered = imcomplement(imfilter(imcomplement( imageVector ),h));
   imshow(imageFiltered);
   save( strcat('image',num2str(j)), 'imageFiltered')
   j=j+1;
end





