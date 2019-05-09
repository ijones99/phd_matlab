function send_stimuli_to_chip(settings)

% settings.saveRecording
% settings.recNTKDir
% settings.stimCh = [86]% 6 74 114 21];
% settings.slotNum = 0;
% settings.amps = 20:20:100;
% settings.numReps = 25;
    idxAmps = repmat(1:length(settings.amps),1,settings.numReps);
    idxAmpsRandPermInds = randperm(length(idxAmps));
settings.ampsIndsRandomize = idxAmps(idxAmpsRandPermInds);
% settings.phaseMsec = 0.150;
% settings.delayInterSpikeMsec = 200;
% settings.delayInterAmpMsec = 500;
% settings.hostIP

clear k;
k = stimloop;

for iCh = 1:length(settings.stimCh)
    % connect ch
    settings.slotNum = 0; enable = 1; dacSel = 0; cLarge = 0;
    channel = settings.stimCh(iCh); broadcast = 0;
    k.push_connect_channel(settings.slotNum,enable,dacSel,cLarge, channel, broadcast);
    
    pause(1)
    if settings.saveRecording
        settings.stimTimesActual = zeros(size(settings.ampsIndsRandomize)); % rec stim times
        hidens_startSaving(settings.slotNum, settings.hostIP,settings.recNTKDir, num2str(settings.stimCh)); pause(.1);
        tic
    end
    
    % create repeats
    iTimeStamp= 1;
    for iAmp=settings.ampsIndsRandomize
        
        k.push_simple_pulse(settings.slotNum, 0, settings.amps(iAmp), settings.phaseMsec*20)
        k.push_simple_delay(20*5); % 30 ms delay
        
        k.flush
        settings.stimTimesActual(iTimeStamp) =  toc;
        iTimeStamp = iTimeStamp+1;
        pause(settings.delayInterSpikeMsec*1/1000)
    end
    pause(0.5)
    settings.slotNum = 0; enable = 0; dacSel = 0; cLarge = 0; channel = -1; broadcast = 1;
    k.push_connect_channel(settings.slotNum,enable,dacSel,cLarge, channel, broadcast);
    k.flush
    pause(1)
    if settings.saveRecording
        hidens_stopSaving(settings.slotNum,settings.hostIP);  pause(.1);
        log_stimulus(settings);
    end
    
    
end

end
