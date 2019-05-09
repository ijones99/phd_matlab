function [avgNumSpikes stdNumSpikes] = count_num_spikes(segmentTs)

numSpikes = 0;
for i=1:length(segmentTs)
    numSpikes(i) = length(segmentTs{i});
end

avgNumSpikes = mean(numSpikes);
stdNumSpikes = std(numSpikes);

end