%% get 2 frames
% Dirs
dirName.movies_500um = '/home/ijones/Stimuli/Natural_Movies/BiolCyb2004_movies/labelb12ariell/500umAperture/'
dirName.movie_original_500um = fullfile(dirName.movies_500um, 'Original_Movie/');
% file names
frameNames = dir(fullfile(dirName.movie_original_500um,'*.bmp'));
% sel files
frameBase = double(imread(fullfile( dirName.movie_original_500um, ...
    frameNames(1).name),'bmp'));
frameBase2 = double(imread(fullfile( dirName.movie_original_500um, ...
    frameNames(2).name),'bmp'));
frameBaseDims = size(frameBase);
offsetXY = [0 0];
framePartRect = [round(frameBaseDims(2)/2)+offsetXY(1)-150 ...
    round(frameBaseDims(1)/2)-150+offsetXY(2)  299 299];
framePart = imcrop(frameBase2, framePartRect);
framePartInNans = nan(frameBaseDims(1),frameBaseDims(2));
framePartInNans(framePartRect(2):framePartRect(2)+framePartRect(4),...
    framePartRect(1):framePartRect(1)+framePartRect(3))=framePart;






%% show frame differences
figure, imshowpair(frameBase, framePartInNans), axis on



%% Take a part of the image and shift it

c = normxcorr2(framePart, frameBase);
figure, imagesc(c);
% offset found by correlation
[max_c, imax] = max(abs(c(:)));
[corrPeak(2), corrPeak(1)] = ind2sub(size(c),imax(1));
offsetXY = (corrPeak-750/2-150)+1
%%

figure, imagesc(frameBase), figure, imagesc(framePart)

c = normxcorr2(framePart, frameBase);
figure, imagesc(c)

% onion = part; peppers = base



sizeDiffs = size(c) - size(framePart);




%%


