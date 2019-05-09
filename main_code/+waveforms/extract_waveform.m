function extract_waveform(data, spiketimes, preSpike, postSpike)

frames = repmat(spiketimes,preSpike+postSpike+1,1);
rangeVals = repmat([-preSpike:postSpike]', 1, length(spiketimes));
frames = frames+rangeVals;
framesLinear = reshape(frames,1, size(frames,1)*size(frames,2));
cutoutData = data(framesLinear,:);
 
% waveform [reps x ch x width];
waveformData = reshape(cutoutData,[preSpike+postSpike+1,length(spiketimes),size(data,2)]);
waveform  = permute(waveformData ,[2 3 1]);


end