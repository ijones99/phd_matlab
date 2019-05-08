function plot_spot_diameter_vs_peak_fr(R_, clusNo, stimChangeTs_, stimFrameInfo)


uniqueDiams = unique(stimFrameInfo.dotDiam);
uniqueRGB = unique(stimFrameInfo.rgb);


% get timestamps
stCurr = spiketrains.extract_st_from_R(R_, clusNo);
peakFiringRate = [];
% go through each position
for iRGB = 1:size(uniqueRGB,2)
    for iDiam = 1:size(uniqueDiams,2)
        % get idx
        currIdx = find(ismember(stimFrameInfo.dotDiam,uniqueDiams(iDiam)) & ismember(stimFrameInfo.rgb,uniqueRGB(iRGB)))';
        idxRaster = [(currIdx*2)-1 (currIdx*2)+1];
        
        % extract all current spiketrain segments
        spiketrainCell = spiketrains.extract_multiple_epochs(stCurr, stimChangeTs_, idxRaster);
        % get mean firing rate per position
        peakFiringRate(iRGB, iDiam) = max(ifunc.analysis.firing_rate.est_firing_rate_from_psth(spiketrainCell,[0 2*2e4]));
    end
end

figure, plot(repmat(uniqueDiams,2,1)', peakFiringRate');

legend({'OFF'; 'ON'})
xlabel('Spot Diameter (um)')
ylabel('Peak Firing Rate (Hz)')




end