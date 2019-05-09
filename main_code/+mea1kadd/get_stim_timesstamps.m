function stimTimes = get_stim_timesstamps(X_stim)
% stimTimes = GET_STIM_TIMESSTAMPS(X_stim)
Fs = 2e4;

% find stimulus timestamps (peak detection)
stimInfo = ss_default_params(Fs,'thresh',2);
stimInfo = ss_detect({diff(X_stim(:,1))},stimInfo);
stimTimesSec = stimInfo.spiketimes(2:end);
stimTimes = stimTimesSec*Fs;

% warning('Check first timestamp');


end
