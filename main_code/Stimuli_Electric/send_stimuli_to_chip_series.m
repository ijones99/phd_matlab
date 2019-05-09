function send_stimuli_to_chip(settings)
% function SEND_STIMULI_TO_CHIP(settings)
%
% settings.saveRecording = 1;
% settings.slotNum = 0;
% settings.saveRecording = 1;
% settings.delayInterSpikeMsec = 200;
% settings.delayInterAmpMsec = 500;
% settings.hostIP = 'bs-hpws11';
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iStimGp = 1;
% settings.stimCh{iStimGp} = [3 86];%86;
% settings.dacSel{iStimGp} = [1 2];
% % rows: values to send seq.; cols: phase
% settings.amps1{iStimGp} = [repmat(20:20:60,2,1); [0 0 0]]';
%     settings.amps1{iStimGp}(:,2) = settings.amps1{iStimGp}(:,2)*-1;
%    
% settings.amps2{iStimGp} = -1*[repmat(20:20:60,2,1); [0 0 0]]';
%     settings.amps2{iStimGp}(:,2) = settings.amps2{iStimGp}(:,2)*-1;
% 
% settings.numReps{iStimGp} = 10;
% settings.phaseMsec{iStimGp} = repmat(0.150,1,3);

% defaults argumennts: 

if ~isfield(settings,'recNTKDir')
   settings.recNTKDir = '../proc/';
end

if ~isfield(settings,'doSaveLogFile')
   settings.doSaveLogFile = 1;
end


for iChGp = 1:length(settings.stimCh) % go through groups of stim channels
    % start stimulator
    clear k;
    k = stimloop;

    % connect all channels to correct DACs
    enable = 1; cLarge = 0; broadcast = 0;
    for iCh = 1:length(settings.dacSel{iChGp})
        channel = settings.stimCh{iChGp}(iCh); 
        k.push_connect_channel(settings.slotNum,enable,settings.dacSel{iChGp}(iCh)-1,cLarge, channel, broadcast);
    end
    k.flush
    % create random values for random presentation of amps
    if isfield(settings,'amps1')
        idxAmps = repmat(1:size(settings.amps1{iChGp},1),1,settings.numReps{iChGp});
    elseif isfield(settings,'amps2')
        idxAmps = repmat(1:size(settings.amps2{iChGp},1),1,settings.numReps{iChGp});
    else
        fprintf('Error: no amps.\n');
    end
    idxAmpsRandPermInds = randperm(length(idxAmps));
    settings.ampsIndsRandomize = idxAmps(idxAmpsRandPermInds);
    pause(1)
    if settings.saveRecording
        settings.stimTimesActual = zeros(size(settings.ampsIndsRandomize)); % rec stim times
        hidens_startSaving(settings.slotNum, settings.hostIP,settings.recNTKDir,''); % start saving
        tic % start timer
        pause(.1);
        
    end
    
    % create repeats
    iTimeStamp= 1;

    for iAmp=settings.ampsIndsRandomize
        %         k.push_simple_pulse(settings.slotNum, 0, settings.amps(iAmp), settings.phaseMsec*20)
        
        dacsInUse = unique(settings.dacSel{iChGp});
        numDACs = length(dacsInUse);
        if numDACs > 1
            offset = 512;
            k.push_triphasic_simdac_pulse(settings.slotNum, offset, ...
                settings.amps1{iChGp}(iAmp, 1),settings.amps1{iChGp}(iAmp,2),settings.amps1{iChGp}(iAmp,3), ...
                settings.amps2{iChGp}(iAmp,1),settings.amps2{iChGp}(iAmp,2),settings.amps2{iChGp}(iAmp,3),...
                settings.phaseMsec{iChGp}(1)*20, settings.phaseMsec{iChGp}(2)*20,settings.phaseMsec{iChGp}(3)*20,...
                settings.delayInterSpikeMsec*20)
        else
            if isfield(settings,'amps1')
                k.push_triphasic_pulse(settings.slotNum, settings.dacSel{iChGp}-1,...
                    settings.amps1{iChGp}(iAmp,1),settings.amps1{iChGp}(iAmp,2),settings.amps1{iChGp}(iAmp,3), ...
                    settings.phaseMsec{iChGp}(1)*20, settings.phaseMsec{iChGp}(2)*20,settings.phaseMsec{iChGp}(3)*20, ...
                    settings.delayInterSpikeMsec*20);
            elseif isfield(settings,'amps2')
                k.push_triphasic_pulse(settings.slotNum, settings.dacSel{iChGp}-1,...
                    settings.amps2{iChGp}(iAmp,1),settings.amps2{iChGp}(iAmp,2),settings.amps2{iChGp}(iAmp,3), ...
                    settings.phaseMsec{iChGp}(1)*20, settings.phaseMsec{iChGp}(2)*20,settings.phaseMsec{iChGp}(3)*20, ...
                    settings.delayInterSpikeMsec*20);
            end
        end
        k.push_simple_delay(20*5); % 30 ms delay
        k.flush
        settings.stimTimesActual(iTimeStamp) =  toc;
        iTimeStamp = iTimeStamp+1;
        pause(settings.delayInterSpikeMsec*1/1000)
    end
    pause(0.5)
    % disconnect
    enable = 0; cLarge = 0; channel = -1; broadcast = 1;
    for iDAC = 1:length(dacsInUse)
        k.push_connect_channel(settings.slotNum,enable,dacsInUse(iDAC)-1,cLarge, channel, broadcast);
        
    end
    k.flush
    pause(1)
    if settings.saveRecording
        hidens_stopSaving(settings.slotNum,settings.hostIP);  pause(.1);
        if settings.doSaveLogFile
            log_stimulus(settings);
        end
    end
    
    
    
end

end
