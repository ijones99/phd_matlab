function outputMat = compare_footprints_two_sources(inputWaveforms1,inputWaveforms2 )
%  outputMat = compare_footprints_two_sources(inputWaveforms1,inputWaveforms2 )

numWaveformUnits1 = length(inputWaveforms1); 
numWaveformUnits2 = length(inputWaveforms2);

% initialize matrix
outputMat = zeros(numWaveformUnits1, numWaveformUnits2);

textprogressbar('start comparing all combos')
for i=1:numWaveformUnits1
    numEls = 7; % num els
    
    for j=1:numWaveformUnits2
        if i==17
            i
        end
        [indsMaxAmpTemp{1} ampsMaxAmpTemp1] = ifunc.footprints.get_max_amp_footprint(inputWaveforms1{i}, ...
            numEls); %get the amplitudes of electrodes
        [indsMaxAmpTemp{2} ampsMaxAmpTemp2] = ifunc.footprints.get_max_amp_footprint(inputWaveforms2{j}, ...
            numEls); %get the amplitudes of electrodes
        [Y ,I] = max([max(ampsMaxAmpTemp1) max(ampsMaxAmpTemp2)]);
        indsMaxAmp = indsMaxAmpTemp{I};
        footprintAtMaxAmps = inputWaveforms1{i}(:,indsMaxAmp);
        ctrWaveform1 = ifunc.footprints.center_footprints(footprintAtMaxAmps); % center waveforms
                
        %take diff of footprints
        ctrWaveform2 = ifunc.footprints.center_footprints(inputWaveforms2{j}(:,indsMaxAmp));
        
        diffFootprints = ctrWaveform1-ctrWaveform2;
        diffFootprints(isnan(diffFootprints)) = [];
        outputMat(i,j) =mean(rms(diffFootprints));
%         
        
        
    end

    textprogressbar(100*i/numWaveformUnits2)
end
textprogressbar('end')


end