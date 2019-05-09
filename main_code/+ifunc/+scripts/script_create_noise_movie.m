% Two freq over one another

Fs = 1000;                    % Sampling frequency
T = 1/Fs;                     % Sample time
L = 1000;                     % Length of signal
t = (0:L-1)*T;                % Time vector
% Sum of a 50 Hz sinusoid and a 120 Hz sinusoid
x = 0.7*sin(2*pi*50*t) + sin(2*pi*120*t); 
y = x;
plot(Fs*t(1:50),y(1:50))
title('Signal')
xlabel('time (milliseconds)')

NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(y,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);

% Plot single-sided amplitude spectrum.
plot(f,2*abs(Y(1:NFFT/2+1))) 
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')
%% design fir2 filter

f = [0 60/500 60/500 1]; m = [1 1 0 0];
b = fir2(30,f,m);
[h,w] = freqz(b,1,128);
plot(f,m,w/pi,abs(h),'lineWidth',2)
legend('Ideal','fir2 Designed','FontSize', 18)
title('Comparison of Frequency Response Magnitudes','FontSize', 18)
set(gca,'FontSize',18);
xlabel('Decimal Fraction of Nyquist Frequency','FontSize',18)
ylabel('Filter Value','FontSize',18)
%% design fir2 filter similar to in Piscopo paper

nyq_cpd = 53;
fC_cpd = 0.05;
fC_nyq = fC_cpd/nyq_cpd;
fLowpass_cpd = 1.7;
fLowpass_nyq = fLowpass_cpd/nyq_cpd;
f = [0:0.001:1]; m = 1./(fC_nyq+f); m(round(fLowpass_nyq*1000):end) = 0;
b = fir2(400,f,m);
[h,w] = freqz(b,1,128);

figure
plot(f,m,w/pi,abs(h),'LineWidth',4)
legend('Ideal','fir2 Designed','FontSize', 24)
title('Spatial Filter for Noise Movie','FontSize', 24)
xlim([0 .07]); ylim([0 500 ])
xlabel('Frequency (cpd)','FontSize', 24), ylabel('Amplitude','FontSize', 24)
set(gca,'FontSize',24);
%% apply filter

umPerPix = 1.6;
rangeRecFieldUm = [ 1000 50];
rangeRecFieldPix = rangeRecFieldUm/umPerPix;
normFreq = 0.5*1./rangeRecFieldPix; %cycles per pixel
% b = fir1(101,[0.0000001 fLowpass_nyq]);
% b = fir1(101,[normFreq(1) normFreq(2)]);  % bandpass 
h = b'*b;  % 2D separable filtersqueeze(movie( 50,50,:))
% assume this is your image
im = wgn(750,750,0);        
imfilt = filter2(h,im,'same');
imfilt = imfilt-min(min(imfilt));
% imfilt = uint8(ifunc.basic.normalize(imfilt)*255);
figure, subplot(1,2,1), imagesc(im),  axis square, colorbar, subplot(1,2,2),imagesc(imfilt),, axis square, colorbar
title('Spatial Filtering of Gaussian Noise (Lowpass 1.7 cpd Rabbit)')
figure, freqz(b,1);

%% create movie
movieDuration = 45; %mins
frameRate_Hz = 8;
nFrames = 100%frameRate_Hz*60*movieDuration;
movie = double(zeros(750,750,nFrames));
for i=1:nFrames
%     randn('state',sum(100*clock))
    im = wgn(750,750,0);
    imfilt = filter2(h,im,'same');
    movie(:,:,i) = imfilt;
    i
    %     uint8(ifunc.basic.normalize(
end

%% Create temporal filter 
figure
frameRate_Hz = 30;
nyqFreq_Hz = frameRate_Hz/2;
fLowpass_Hz = 10;
fLowpass_Nyq = fLowpass_Hz/nyqFreq_Hz;
f = [0:0.001:1]; m = ones(1,length(f)); m(round(fLowpass_Nyq*1000):end) = 0;

b = fir2(50,f,m);
[h,w] = freqz(b,1,128);
plot(f,m,w/pi,abs(h))
title('Temporal Filtering of Gaussian Noise (Lowpass 10 Hz Rabbit)')
%% apply to movie

movieFilt = filter(b,1,double(movie),[],3);

movieFilt2 = movieFilt;


%% apply sine wave to movie
% normalize movie

movieFilt2 = 2*(ifunc.basic.normalize(real(movieFilt2))-0.5);

numSamples = size(movieFilt,3);
period_Sec = 0.5;
% frameRate_Hz

N = 1/frameRate_Hz;
t = N:N:N*numSamples;
sinWave = 0.5*sin(t.*2*pi./period_Sec)+0.5;

for i=1:length(sinWave)
   movieFilt2(:,:,i) = movieFilt2(:,:,i)*sinWave(i);
    
end

movieFilt2 = 0.5*(movieFilt2+1);

%% plot temporal frequences in movie
figure
temporalData = squeeze(ifunc.basic.normalize(movie(50,50,:)))';
Fs = frameRate_Hz;
F=fft(temporalData);
figure
N=Fs/length(F); % Fs is sampling frequency; F is the F100ourier transform of the data
baxis=(N:N:N*(length(temporalData)/2));
plot(baxis,real(F(1:length(F)/2))) 
hold on
temporalData = squeeze(ifunc.basic.normalize(movieFilt2(50,50,:)))';
Fs = frameRate_Hz;
F=fft(temporalData);
N=Fs/length(F); % Fs is sampling frequency; F is the Fourier transform of the data
baxis=(N:N:N*(length(temporalData)/2));
plot(baxis,real(F(1:length(F)/2)),'r') 
title('Temporal Filtering of Gaussian Noise (Lowpass 10 Hz Rabbit)')
%% plot spatial frequences in movie
figure, hold on
temporalData = movie(:,20,20);
Fs_cpd = 106; %
F=fft(temporalData);
N=Fs_cpd/length(F); % Fs is sampling frequency; F is the Fourier transform of the data
baxis=(N:N:N*(length(temporalData)/2));
plot(baxis,ifunc.basic.normalize(real(F(1:length(F)/2)))) 
%
figure
temporalData = movieFilt(:,20,20);
Fs_cpd = 106; %
F=fft(temporalData);
N=Fs_cpd/length(F); % Fs is sampling frequency; F is the Fourier transform of the data
baxis=(N:N:N*(length(temporalData)/2));
plot(baxis,ifunc.basic.normalize(real(F(1:length(F)/2))),'r') 

title('Temporal Filtering of Gaussian Noise')
xlabel('CPD Rabbit')
ylabel('Amp')
legend({'Before Temporal Filtering'; 'After Temporal Filtering'})
%% convert to 256-value
movieFilt3 = uint8(ifunc.basic.normalize(movieFilt2)*255);

%% play movie

figure
% movieFilt2 = ifunc.basic.normalize(movieFilt2);
for i=1:225
    subplot(15,15,i)
   imagesc((real(movieFiltSpatTemp(:,:,i))));axis square; axis off; caxis([0 255])
   colormap(gray)
%    subplot(1,2,2)
%    imagesc(movieFilt(:,:,i));axis square;
end 
% title('Gaussian White Noise (Spatial Filter HP 1.7 CPD Rabbit, Temporal LP 10Hz')

