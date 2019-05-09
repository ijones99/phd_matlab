function plot_spot_diameter_vs_peak_fr(neur, clusNo)


uniqueDiams = unique(neur.spt.settings.dotDiam);
uniqueRGB = unique(neur.spt.settings.rgb);


peakFiringRate = [];
% go through each position
for iRGB = 1:size(uniqueRGB,2)
    for iDiam = 1:size(uniqueDiams,2)
        % get idx
        currIdx = find(ismember(neur.spt.settings.dotDiam,uniqueDiams(iDiam)) & ismember(neur.spt.settings.rgb,uniqueRGB(iRGB)))';
        spiketrainCell = neur.spt.spikeTrains(currIdx);
        % get mean firing rate per position
        peakFiringRate(iRGB, iDiam) = max(ifunc.analysis.firing_rate.est_firing_rate_from_psth(spiketrainCell,[0 2*2e4]));
    end
end

plot(repmat(uniqueDiams,2,1)', peakFiringRate');

legend({'OFF'; 'ON'})
xlabel('Spot Diameter (um)')
ylabel('Peak Firing Rate (Hz)')




end