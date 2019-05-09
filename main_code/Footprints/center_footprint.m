function footPrintOut = center_footprint(footPrintIn)

%   waveform: [118x30 single]

% calculate max peak to peak values for each electrode
maxPeakToPeak = max(footPrintIn,[],2)-min(footPrintIn,[],2);

[junk, IMaxP2P] = sort(maxPeakToPeak,'descend');

indsHighestP2P = IMaxP2P(1:5);

selWaveforms = footPrintIn(indsHighestP2P,:); % [118x30 single]

% get minimum value for each waveform
[junk1, IndsMinValueWaveforms ] = min(selWaveforms,[],2); % [7x30 single]

meanAmountToShift =-round(1+mean(IndsMinValueWaveforms)-round(size(selWaveforms,2)/2));

footPrintOut = circshift(footPrintIn,[0  meanAmountToShift]);


end