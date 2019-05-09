function outputLookupTable = create_projector_brightness_lookup_table(brightnessMeasurements)

numDiscreteVals = 255;
outputLookupTable = zeros(numDiscreteVals,2);
outputLookupTable(:,1) = 1:numDiscreteVals;


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

end