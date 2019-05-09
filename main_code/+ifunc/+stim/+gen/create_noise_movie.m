 
smallestRFsize = 50; % smallest RF = 50mu m
biggestRFsize = 600;
hpInmum = 2*smallestRFsize; % => 100mu m period
lpInmum = 2*biggestRFsize; % => 100mu m period
mumPerDegree = 170; % mu m per degree on retina
framesPerSecond = 30;
dimensionsInPixel = [1000 1000];
pixelSizeOnRetina = 1.6; %mu m
bpCPD = [hpInmum lpInmum]/mumPerDegree; % in cycles per degree (cpd)
bp = [hpInmum lpInmum];
 
durationInSeconds = 10;
nFrames = framesPerSecond*durationInSeconds;
% S = randn(nFrames, dimensionsInPixel(1), dimensionsInPixel(2));
%%
gaussianWhiteNoise = wgn(750,750,0);
figure,
imagesc(y2)


%% testing filtering
% (cycles/second) / (samples/second) = cycles/sample.

Fc    = 0.1; % cyc/sample
% cyclesPerRad = 1/2*pi();
% cyclesPerSec = 
N = 100;   % FIR filter order
% Hf = fdesign.lowpass('N,Fc',N,Fc);

%%  create frame of filtered gaussian noise
im = wgn(750,750,0);
umPerPix = 1.6;
rangeRecFieldUm = [ 1000 50];
rangeRecFieldPix = rangeRecFieldUm/umPerPix;
normFreq = 0.5*1./rangeRecFieldPix; %cycles per pixel

% b = fir1(101,[normFreq(1) normFreq(2)]);  % bandpass 
h = b'*b;  % 2D separable filter
% assume this is your image
imfilt = filter2(h,im,'same');
imfilt = imfilt-min(min(imfilt));
imfilt = uint8(ifunc.basic.normalize(imfilt)*255);
figure, subplot(1,2,1), imagesc(im), subplot(1,2,2),imagesc(imfilt)
figure, freqz(b,1)
%% check frequency
Fs = 1/1.6;                    % Sampling frequency
T = 1/Fs;                     % Sample time
L = 1000;                     % Length of signal
t = (0:L-1)*T;                % Time vector
% Sum of a 50 Hz sinusoid and a 120 Hz sinusoid
x = 0.7*sin(2*pi*50*t) + sin(2*pi*120*t); 
y = imfilt(50,:);     % Sinusoids plus noise
plot(Fs*t(1:50),y(1:50))
title('Signal Corrupted with Zero-Mean Random Noise')
xlabel('time (milliseconds)')

NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(y,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);

% Plot single-sided amplitude spectrum.
plot(f,2*abs(Y(1:NFFT/2+1))) 
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')


%%  create movie of filtered gaussian noise
umPerPix = 1.6;
rangeRecFieldUm = [ 1000 50];
rangeRecFieldPix = rangeRecFieldUm/umPerPix;
normFreq = 0.5*1./rangeRecFieldPix;

b = fir1(101,[normFreq(1) normFreq(2)]);  % bandpass 
h = b'*b;  % 2D separable filter
numFrames = 50;
imSizePix = [750 750];
noiseMovie = uint8(zeros(imSizePix(1),imSizePix(2),numFrames));
for i=1:50
    im = wgn(750,750,0);
    imfilt = filter2(h,im,'same');
    imfilt = imfilt-min(min(imfilt));
    noisemovie(:,:,i) = uint8(ifunc.basic.normalize(imfilt)*255);
end
% figure, freqz(b,1)
%% filter temporally



%%
figure
for i=1:numFrames
   imagesc( noisemovie(:,:,i))
    pause(1/30)
end

