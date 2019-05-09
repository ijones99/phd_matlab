% >>>>>>>>> #9) whole field: white noise
% >>>>>>>>>
allMoviesDir = strcat('/net/bs-filesvr01/export/group/hierlemann/projects/', ...
    'retina_project/Light_Stimuli/White_Noise_Checkerboard');
pixTransferFuncDir = '/home/ijones/Matlab/Equipment/Projector';

frameCount = 45 * 60 * 30;% 45 mins x 60 secs/min * 30 frames/sec;

% load pixel transfer function
load(fullfile(pixTransferFuncDir, 'polyFitCoeff.mat'));

for i=1:frameCount 
    
    % ----- const settings -----
    brightness =  255/2;
    contrast = round(0.25*255/2);
    edgeLengthSize = 600;
    numPixelsEdge = 30;
    
    % get random values with specified brightness and contrast
    tempFrame = make_whitenoise_frame(brightness, contrast, edgeLengthSize, numPixelsEdge);
    
    % specific stimulus movie dir
    specificMovieDir = 'White_Noise_Checkerboard';
    
    % save to file
    apply_transfer_func_and_save_image(tempFrame, specificMovieDir, allMoviesDir, p, i);
    
    i


end