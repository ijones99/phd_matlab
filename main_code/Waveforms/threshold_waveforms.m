function crossingPosition = threshold_waveforms(waveforms, threshold, polarity, dims)

if dims == 2
    waveforms = waveforms';
end

crossingPosition = zeros(size(waveforms,dims),1);


if strcmp(polarity,'negative')
    [ row col] = find(waveforms>=threshold);
end

for i=1:size(waveforms,1)
    crossingPosition(i) = col(find(row==i,1,'first') );
end
    
end