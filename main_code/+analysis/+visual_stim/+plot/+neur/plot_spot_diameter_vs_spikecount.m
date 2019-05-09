function plot_spot_diameter_vs_spikecount(neur, clusNo)


uniqueDiams = unique(neur.spt.settings.dotDiam);
uniqueRGB = unique(neur.spt.settings.rgb);

timeInt = [0 2]*2e4;

spikeCount = [];
% go through each position
for iRGB = 1:size(uniqueRGB,2)
    for iDiam = 1:size(uniqueDiams,2)
        % get idx
        currIdx = find(ismember(neur.spt.settings.dotDiam,uniqueDiams(iDiam)) & ismember(neur.spt.settings.rgb,uniqueRGB(iRGB)))';
        spiketrainCell = neur.spt.spikeTrains(currIdx);
        numCells = length(spiketrainCell);
        % get mean firing rate per position
        numSpikes = 0;
        for iCell = 1:numCells
            numSpikes = length(find(spiketrainCell{iCell} >= timeInt(1) & spiketrainCell{iCell} <= timeInt(2)))+numSpikes;
        end
        spikeCount(iRGB, iDiam) = numSpikes;
    end
end

plot(repmat(uniqueDiams,2,1)', spikeCount');

legend({'OFF'; 'ON'})
xlabel('Spot Diameter (um)')
ylabel('Spike Count')




end