 dirName.movies_500um = '/home/ijones/Stimuli/Natural_Movies/BiolCyb2004_movies/labelb12ariell/500umAperture/'
 dirName.movie_original_500um = fullfile(dirName.movies_500um, 'Original_Movie/');
 
 frameNames = dir(fullfile(dirName.movie_original_500um,'*.bmp'));
 
 frame = double(imread(fullfile( dirName.movie_original_500um, ...
     frameNames(1).name),'bmp'));
 
 motionVectorForMovieOverlay = zeros(30,2);
 
 for i=2:length(frameNames)
     frame(:,:,i) = double(imread(fullfile( dirName.movie_original_500um, ...
         frameNames(i).name),'bmp'));
     frameBase = frame(:,:,i-1);
     framePart = frame(375-150:375+149, 375-150:375+149,i);   
     % motion vector XY
     motionVector(i-1,:) = -ifunc.im_proc.get_image_offset(frameBase, framePart);
     i
 end
 %% plot motion with star over movie
 
ifunc.gui.stimulus_movie_viewer(frame, -motionVectorForMovieOverlay+375)

%% plot frames
figure, subplot(1,3,1), imagesc(frame(:,:,i)), axis square, subplot(1,3,2), ...
 imagesc(frame(:,:,i-1)), axis square,, subplot(1,3,3), imagesc(xCorr), axis square
%% plot motion
 relMotion = diff(motionVector)
 h = figure, plot(sqrt(relMotion(:,1).^2+ sqrt(relMotion(:,2).^2)),'*--')
 title('Speed')
 
 motionAngle = 0;
 for i=1:length(relMotion)  
     motionAngle(i) = atan(relMotion(i,2)/relMotion(i,1))*360/(2*pi());    
 end
 
 h2 = figure;
 plot(motionAngle,'r*--'), title('Motion Vector Angle')
%% save all the info about the movie processed data to a structure



%% look for correlation
load firingRatesOut.mat; load motionVector.mat;

% movie length: 29.9640 sec
% frame interval = 0.0333 sec

x = firingRatesOut{1}.firing_rate;
y = motionVector;

[r,p] = corrcoef(x,y);






