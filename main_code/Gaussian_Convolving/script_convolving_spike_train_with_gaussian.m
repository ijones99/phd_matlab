rate=10;  % firing rate of the Poisson process [Hz]
dt=1; % time between two bins (time points) [ms]
duration=1000;% duration of the spike train [ms]
% time array [ms] % generate train of Poisson spikes
t=0:dt:duration;

% generate train of Poisson spikes
spikes=zeros(size(t )); % initialize spike train array with zeros
for i=1:duration/dt % loop over the whole number of time points
    if rand<=rate/1000*dt
        spikes( i )=1; % in case uniformly distributed random number ’rand ’
        % is below threshold set by desired rate ,
        % insert a spike into ccurrent time bin
    end
    
end

sigma=1/rate*1000;	%	[ms] 
gauss_duration=3*sigma*2;	%	[ms] 
gauss_t=-gauss_duration/2:dt: gauss_duration/2;	% time vector for the window
gauss=1/sqrt(2*pi*sigma^2)*exp(-gauss_t.^2/(2*sigma^2)); 
% (d) Convolving 2 vectors can be done with the function conv
convolvedSpikes=conv(double(spikes), gauss ,	'same')*1000;

figure, plot(convolvedSpikes)

hold on
plot(1:length(spikes), spikes*6,'r.')
