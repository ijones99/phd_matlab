function patternOut = create_randomly_long_bars( barLengthRangeUm, brightnessRange, totalLength    )
% patternOut = create_randomly_long_bars( barLengthRange, brightnessRange, totalLength    )
    

    barLengthRangePx = barLengthRangeUm/1.75;
    patternOut = zeros(1,totalLength);
    
    % get lengths
    randLengths = rand(1,totalLength)*(diff(barLengthRangePx))+barLengthRangePx(1);

    % get idxs
    idxEnd = cumsum(randLengths)';
    idxStart = [1; idxEnd(1:end-1)+1];
    
    % get cutoff
    numBars = find(idxEnd > totalLength);
    
    
    % brightness
    brightness = rand(1,length(numBars))*(diff(brightnessRange))+brightnessRange(1);
    
    for i=1:numBars
        patternOut(idxStart(i): idxEnd(i)) = brightness(i);
     
    end

    patternOut = patternOut(1:totalLength);

end