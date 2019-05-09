function neur = obtain_vis_stim_parameters(neur)

% bias index
%data
clear paramOut
load ~/Matlab/settings/stimFrameInfo_spots.mat

% get switch times
interStimTime = 0.5;
stimChangeTs = get_stim_start_stop_ts2(neur.spt.frameno,interStimTime);

if length(stimChangeTs)/2 ~= length(stimFrameInfo.rep)
    error('timestamps do not match.')
end
framenoSeparationTimeSec = 0.5;
adjustToZero = 1;
neur.spt.spikeTrains = extract_spiketrain_repeats_to_cell(neur.spt.st, ...
    stimChangeTs,adjustToZero);


[onOff,stimIdx, spikeCountsMean] = response_params_calc.spt.find_preferred_stim(...
    neur.spt.spikeTrains, stimFrameInfo);

ONcntStAvg = spikeCountsMean(1,stimIdx);
OFFcntStAvg = spikeCountsMean(2,stimIdx);

% calculate parameter
paramOut.bias = response_params_calc.bias_index2(ONcntStAvg,OFFcntStAvg);

% latency
load ~/Matlab/settings/stimFrameInfo_spots.mat
% find preferred stim
[onOff,stimIdx, spikeCountsMean] = response_params_calc.spt.find_preferred_stim(...
    neur.spt.spikeTrains, stimFrameInfo);
% calculate mean firing rate
spotDiams = unique(stimFrameInfo.dotDiam);
dotRGBVal = unique(stimFrameInfo.rgb);
startStopTime = [-0.5 1]*2e4;
clear peakFR
for jRGB = 1:length(dotRGBVal)
    for iDiam=1:length(spotDiams)
        selResponseIdx = find(stimFrameInfo.dotDiam == ...
            spotDiams(iDiam)&stimFrameInfo.rgb == dotRGBVal(jRGB) );
         [firingRate edges] = ifunc.analysis.firing_rate.est_firing_rate_ks(...
            neur.spt.spikeTrains(selResponseIdx ),startStopTime);
        peakFR(iDiam, :, jRGB) = firingRate;       
    end
end
integWinTime_sec = 0.025;
preferredIdx = [stimIdx onOff];
paramOut.latency = response_params_calc.latency(peakFR, ...
    preferredIdx, integWinTime_sec);

% transience
paramOut.transience = ...
    response_params_calc.transience(peakFR, ...
    preferredIdx, integWinTime_sec);
% RF 
paramOut.rf = response_params_calc.rf(spotDiams, spikeCountsMean(onOff,:));

% DS index
neur.mb.presentationTimeRangeSec = [0 2];
load(fullfile('~/Matlab/settings', 'stimFrameInfo_movingBar_2reps'))

barDirUnique = unique(stimFrameInfo.angle,'stable');
barRGBVal = unique(stimFrameInfo.rgb);
startStopTime = neur.mb.presentationTimeRangeSec*2e4;
clear peakFR
firingRateAll = [];

% get switch times
interStimTime = 0.5;
stimChangeTs = get_stim_start_stop_ts2(neur.mb.frameno,interStimTime); 
framenoSeparationTimeSec = 0.5;

if length(stimChangeTs)/2 ~= length(stimFrameInfo.rep)
    error('timestamps do not match.')
end

adjustToZero = 1;
neur.mb.spikeTrains = extract_spiketrain_repeats_to_cell(neur.mb.st, ...
    stimChangeTs,adjustToZero);

peakFR = [];
for jRGB = 1:length(barRGBVal)
    for i=1:length(barDirUnique)
        selResponseIdx = find(stimFrameInfo.angle == barDirUnique(i)&...
            stimFrameInfo.rgb == barRGBVal(jRGB)&...
            stimFrameInfo.offset == 0);
        [firingRate edges] = ifunc.analysis.firing_rate.est_firing_rate_ks(...
            neur.mb.spikeTrains(selResponseIdx ),startStopTime);
        firingRateAll(i,:) = firingRate;
        
        peakFR(jRGB,i) = max(firingRate);
        
    end
end
peakFRNorm = peakFR/max(max(peakFR));
angleOut = beamer.beamer2chip_angle_transfer_function(barDirUnique);
peakFRSel = peakFR( onOff,:);
paramOut.ds = response_params_calc.ds(angleOut, peakFRSel);
%Save
neur.paramOut = paramOut;
% save(fullfile('../analysed_data/', neurFileName), 'neur');
end