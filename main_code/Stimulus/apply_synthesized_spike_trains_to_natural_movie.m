function [mean_final_spike_movie var_final_spike_movie timeStamps]= apply_synthesized_spike_trains_to_natural_movie ...
    (timeStamps, savedFrames,frameno, frameRate, varargin)
% -------------- SETTINGS ----------------%
projectorDelay = 860;
timeStamps = round(timeStamps-projectorDelay);
apertureDiameterPx = (400/1000)*630;
timeStamps(find(timeStamps<50))=[];
frameno = single(frameno);
preSpikeFramePoints=[];
n_frames_before_spikes= 26;
drawAperture = 0;
numberOfFrames = size(savedFrames,3); % number of8 stimulus frames


% -------------- VARARGINS ----------------%
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp(varargin{i},'draw_aperture')
            drawAperture = 1;
        end
    end
    
end

% % generate timeStamps
% N = length(timeStamps);
maxT = max(timeStamps);
% ts = sort(rand(1,N));
 
isi = diff([timeStamps maxT]);
isi2 = isi(randperm(length(isi)));
timeStamps = cumsum(isi2);



idx=(timeStamps)'; % idx: timestamps
idx = repmat(idx,1,n_frames_before_spikes+1); %idx: matrix of the timestamps
Interval = single([(-n_frames_before_spikes):0]); % Interval is the time points selected before the spike occurred
Interval = repmat(Interval,size(idx,1),1); % Interval is then made into a matrix of the number of spikes X number of points
preSpikeFramePoints = Interval+idx; % matrix of timepoints before spike occurred

mean_final_spike_movie = uint8(zeros(size(savedFrames,1),size(savedFrames,2), size(preSpikeFramePoints,2)+1));
var_final_spike_movie = uint8(zeros(size(savedFrames,1),size(savedFrames,2), size(preSpikeFramePoints,2)+1));
for i=-size(preSpikeFramePoints,2):1: 0 % go through all prespike timepoints
    
    selFrameno = frameno(timeStamps)+i; % use timestamps to access the frame numbers
    selFrameno(find(selFrameno<1))=[]; % remove the frame numbers that refer to frame 0, as this does not exist

    if max(selFrameno) >  numberOfFrames % check for size of frames vector
        fprintf('Error: number of specified frames exceeds number of available frames\n\n');
        return
    end
    
    mean_final_spike_movie(:,:,28+i)=mean(savedFrames(:,:,selFrameno ) ,3);
    var_final_spike_movie(:,:,28+i)=var(double(savedFrames(:,:,selFrameno )) ,3);
end



end