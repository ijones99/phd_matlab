dirName.movies_500um = '/home/ijones/Stimuli/Natural_Movies/BiolCyb2004_movies/labelb12ariell/500umAperture/'
dirName.movie_original_500um = fullfile(dirName.movies_500um, 'Original_Movie/');

frameNames = dir(fullfile(dirName.movie_original_500um,'*.bmp'));

frame = double(imread(fullfile( dirName.movie_original_500um, ...
    frameNames(1).name),'bmp'));

motionVectorForMovieOverlay = zeros(30,2);

for i=2:30%1/0.0333
    frame(:,:,i) = double(imread(fullfile( dirName.movie_original_500um, ...
        frameNames(i).name),'bmp'));
    frameBase = frame(:,:,i-1);
    framePart = frame(375-150:375+149, 375-150:375+149,i);
    motionVectorXY(i-1,:) = ifunc.im_proc.get_image_offset(frameBase, framePart)+375;
    i
end
%% plot motion with star over movie
ifunc.gui.stimulus_movie_viewer(frame, motionVectorXY)

%% plot frames
figure, subplot(1,3,1), imagesc(frame(:,:,i)), axis square, subplot(1,3,2), ...
    imagesc(frame(:,:,i-1)), axis square,, subplot(1,3,3), imagesc(xCorr), axis square
%% plot motion

motionVectorXY = motionVectorXY-375;
distMoved = sqrt(motionVectorXY(:,1).^2+ sqrt(motionVectorXY(:,2).^2));
% h1 = figure;
figure(9)
% plot(2:length(distMoved)+1, distMoved*1.75/(1/30),'r*--')
plot(2:length(distMoved)+1, distMoved*0.6/max(distMoved),'r*--')
title('Image Shifts During Natural Movie (labelb12ariell)','FontSize', 12)
xlabel('Frame Number','FontSize', 12)
ylabel('Speed (um/sec)','FontSize', 12)

%% motion angle
motionAngle = 0;
for i=1:length(relMotion)
    motionAngle(i) = atan(relMotion(i,2)/relMotion(i,1))*360/(2*pi());
end

h2 = figure;
plot(motionAngle,'r*--'), title('Motion Vector Angle')

%% plot movement compared to difference in spiking between normal movie and static surround.
outputDir = '../Figs/Natural_Movie/Saccad_and_Spiking';
if ~exist(outputDir,'dir')
   mkdir(outputDir) 
end

load motionVector;
distMoved = sqrt(motionVector(:,1).^2+ sqrt(motionVector(:,2).^2));

for iNeur = 1:length(firingRatesOut_Orig)
    
    diffFiringRates = firingRatesOut_Orig{iNeur}.firing_rate ...
        - firingRatesOut_Stat_Surr{iNeur}.firing_rate;
    diffFiringRatesConv = ifunc.conv.conv_gaussian_with_spike_train(diffFiringRates,...
        0.02,0.0333);
    
    figPos = [402          53        1026        1023];
    
    
    h = figure, set(h,'Position', figPos);hold on,
    plot(diffFiringRatesConv)
    
    umPerPix = 1.6; frameRate = 30;
    speedVector = distMoved'*umPerPix*frameRate;
    plot(speedVector/1000+10,'r')
    grid minor
    legend('Firing Rate Difference (Original Minus Stat. Surr.)','Saccad Speed','FontSize', 18)
    title(sprintf('Neuron %s',firingRatesOut_Orig{iNeur}.neuron_name),'FontSize', 20)
    xlabel('Frame Number','FontSize', 18);
    set(gca,'FontSize',18)
    ylabel('Firing Rate Difference (Hz) and Saccad Speed (um/s x 1/1000 + 10','FontSize', 18)
    
    saveas(h,fullfile(outputDir,sprintf('saccad_and_fr_neur_%s.fig',firingRatesOut_Orig{iNeur}.neuron_name)),'fig');
    close(h)
end