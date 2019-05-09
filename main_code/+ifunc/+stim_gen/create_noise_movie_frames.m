function [movieFiltSpatTemp movieFiltSpatTempContrastVary] = ...
    create_noise_movie_frames(varargin)

P.frameRate_Hz = 30;
P.movieDuration = 45; %mins
P.nFrames = 150%P.frameRate_Hz*60*P.movieDuration;
P.periodContrastVary_Sec = 10;%Sec

P = mysort.util.parseInputs(P, varargin, 'error'); 

% design fir2 filter similar to in Piscopo paper
nyq_cpd = 53;
fC_cpd = 0.05;
fC_nyq = fC_cpd/nyq_cpd;
fLowpass_cpd = 1.7;
fLowpass_nyq = fLowpass_cpd/nyq_cpd;
fSpatial = [0:0.001:1]; mSpatial = 1./(fC_nyq+fSpatial); mSpatial(round(fLowpass_nyq*1000):end) = 0;
bSpatial = fir2(400,fSpatial,mSpatial);
hSpatial = bSpatial'*bSpatial;

% Create temporal filter 


nyqFreq_Hz = P.frameRate_Hz/2;
fLowpass_Hz = 10;
fLowpass_Nyq = fLowpass_Hz/nyqFreq_Hz;
f = [0:0.001:1]; m = ones(1,length(f)); m(round(fLowpass_Nyq*1000):end) = 0;
b = fir2(50,f,m);
[h,w] = freqz(b,1,128);
% 
% figure
% plot(f,m,w/pi,abs(h),'LineWidth',4)
% legend('Ideal','fir2 Designed','FontSize', 24)
% title('Spatial Filter for Noise Movie','FontSize', 24)
% xlim([0 .07]); ylim([0 500 ])
% xlabel('Frequency (cpd)','FontSize', 24), ylabel('Amplitude','FontSize', 24)
% set(gca,'FontSize',24);

% create movie
movie = double(zeros(750,750,P.nFrames));
for i=1:P.nFrames
    im = wgn(750,750,0);
    imfilt = filter2(hSpatial,im,'same');
    movie(:,:,i) = imfilt;
   i 
end



movieFilt2 = filter(b,1,double(movie),[],3);
movieFiltSpatTemp = ifunc.basic.normalize(real(movieFilt2));
movieFilt2 = 2*((movieFiltSpatTemp)-0.5);

numSamples = size(movieFilt2,3);


% apply sin wave
N = 1/P.frameRate_Hz;
t = N:N:N*numSamples;
sinWave = 0.5*sin(t.*2*pi./P.periodContrastVary_Sec)+0.5;

for i=1:length(sinWave)
    movieFilt2(:,:,i) = movieFilt2(:,:,i)*sinWave(i);
end

movieFilt2 = 0.5*(movieFilt2+1);

movieFiltSpatTempContrastVary = uint8(ifunc.basic.normalize(movieFilt2)*255);
movieFiltSpatTemp = uint8(ifunc.basic.normalize(movieFiltSpatTemp)*255);

end



