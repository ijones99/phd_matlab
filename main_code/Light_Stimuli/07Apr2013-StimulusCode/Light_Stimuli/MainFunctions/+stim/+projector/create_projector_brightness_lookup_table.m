function outputLookupTable = create_projector_brightness_lookup_table(brightnessMeasurements)

numDiscreteVals = length(brightnessMeasurements);
outputLookupTable = zeros(numDiscreteVals,2);
outputLookupTable(:,1) = 0:numDiscreteVals-1;
brightnessMeasurements= ifunc.basic.normalize(brightnessMeasurements);

% convert input val to percent: this is the desired value
inputPercentBrightness = outputLookupTable(:,1)/length(brightnessMeasurements);

for i=1:numDiscreteVals
    
    % compare percent brightness value to values in lookup table
    % find where this occurs in the output
    diffToLookupTable = abs(brightnessMeasurements - inputPercentBrightness(i));
    
    % look for min point of differences
    [C outputBrightnessValTemp ] = min(diffToLookupTable);
    
    % take first occurance
    outputLookupTable(i,2) = outputBrightnessValTemp(1);
    
end
outputLookupTable = outputLookupTable(:,2);
end