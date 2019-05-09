function outputBrightnessVal = temp_apply_projector_transfer_function_nearest_neighbor( ...
    inputBrightnessVal, lookupTable) 
    % This function uses a lookup table to adjust the brightness values for
    % a stimulus projector. 
    % INPUTS:
    % inputBrightnessVal: desired brightness setting value (e.g. a value
    % between 1 and 255
    % lookupTable: measurement at every possible projector value
    % (e.g. settings 1 through 255). Vector is normalized to 1
    % 
    
    % convert input val to percent: this is the desired value
    inputPercentBrightness = inputBrightnessVal/length(lookupTable);
    
    % compare percent brightness value to values in lookup table:
    % find where this occurs
    diffToLookupTable = abs(lookupTable - inputPercentBrightness);
    
    % look for min point of differences
    [C outputBrightnessValTemp ] = min(diffToLookupTable);
    
    % take first occurance
    outputBrightnessVal = outputBrightnessValTemp(1);
    



end