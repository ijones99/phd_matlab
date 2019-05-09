function [I, J, outlineIm filtIm] = get_outline_of_receptive_field(inputImOrig, varargin)

try
P.erode_param = 10;
P.dil_param = 30;
P = mysort.util.parseInputs(P, varargin, 'error');
%%
% resize
inputIm = imresize(inputImOrig,10);

% filter 
h = fspecial('gaussian');
filtIm = imfilter(inputIm, h);

% normalize
filtNormIm = ifunc.basic.normalize(filtIm);
meanIm = mean(mean(filtNormIm));

imForDirection = filtNormIm(2:end-1,2:end-1)-meanIm;
maxAbsVal = (max(max(abs(imForDirection))));  maxValAbsInd = find(abs(imForDirection)==maxAbsVal(1));

% find the orientation
% 
figure
imagesc(filtIm)
% change to binary
RFDir = imForDirection(maxValAbsInd);
if RFDir < 0
    meanIm = meanIm*0.75;
else
    meanIm = meanIm*1.25;
end
binaryIm = filtNormIm;
binaryIm(find(binaryIm>meanIm)) = 1;
binaryIm(find(binaryIm<=meanIm)) = 0;

% complement of image if necessary
if RFDir < 0
    binaryIm = imcomplement(binaryIm);
end

% erode image
seErode = strel('ball',P.erode_param,P.erode_param);
seDil = strel('ball',P.dil_param,P.dil_param);
erodeIm = imerode(binaryIm,seErode);
erodeIm = ifunc.basic.normalize(erodeIm);
erodeIm(find(erodeIm==NaN))=0;
dilIm = imdilate(erodeIm,seDil);
dilIm = ceil(ifunc.basic.normalize(dilIm));

% get outline
outlineIm = bwperim(dilIm, 8);

% remove edges
outlineIm(1:5,:) = 0;outlineIm(end-4:end,:) = 0; outlineIm(:,1:5) = 0;outlineIm(:,end-4:end) = 0;

% get coords
[I,J] = ind2sub([size(outlineIm,1), size(outlineIm,2)],find(outlineIm==1));
catch
    I=0;J=0; outlineIm =0;filtIm=0;

end
