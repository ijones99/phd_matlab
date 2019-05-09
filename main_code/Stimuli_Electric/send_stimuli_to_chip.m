function send_stimuli_to_chip(settings, varargin)
% function SEND_STIMULI_TO_CHIP(settings)
% 
% Note: 
% a group is defined as a series of stimuli sent to defined channels on the
% chip for one given configuration. Thus, each field in the structure must
% is composed of a cell for each group, unless the field is common to all
% groups.
%
% varargin:
%   'sel_group_no': stimulus group selection: which stimulus electrodes
%       will be used
%   'dir_log_file': designate directory for log file
%
%
% Mister Jones

%
% clear settings
% settings.sessionName = stimCellName;
% settings.saveRecording = 1;
% settings.recNTKDir = '../proc';
% settings.slotNum = 0;
% settings.delayInterSpikeMsec = 200;
% settings.delayInterAmpMsec = 500;
% settings.hostIP = 'bs-hpws11'; %pt black setup: 'bs-hpws11'; retina room: 'bs-dw17'
% settings.doSaveLogFile = 1;
% settings.stimCh = {92 80};%86;
% settings.amps = 100:100:700;
% 
% for iStimGp = 1:length(settings.stimCh)
%     
%     settings.dacSel{iStimGp} = [2];
%     % rows: values to send seq.; cols: phase
%     settings.amps2{iStimGp} = [settings.amps;-settings.amps; zeros(1,length(settings.amps))]';
%     %     settings.amps1{iStimGp}(:,2) = settings.amps1{iStimGp}(:,2)*-1;
%     settings.numReps{iStimGp} = 25;
%     settings.phaseMsec{iStimGp} = repmat(0.150,1,3);
%     
%     settings.numTrainSpikes{iStimGp} = 1;
%     settings.interTrainDelayMsec{iStimGp} = 500;
%     settings.stimType{iStimGp}='biphasic'
%     
% end

selGpNum = [];
dirLogFile = '';
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'sel_group_no')
            selGpNum = varargin{i+1};
        elseif strcmp( varargin{i}, 'dir_log_file')
            dirLogFile = varargin{i+1};
        end
    end
end

% defaults argumennts: 

if ~isfield(settings,'recNTKDir')
   settings.recNTKDir = '../proc/';
end

if ~isfield(settings,'doSaveLogFile')
   settings.doSaveLogFile = 1;
end

% a group is defined as a series of stimuli sent to defined channels on the
% chip for one given configuration
if isempty(selGpNum)
    idxGp = 1:length(settings.stimCh);
else
    idxGp = selGpNum;
end

for iChGp = idxGp % go through groups of stim channels
    % start stimulator
    clear k;
    k = stimloop;

    % connect all channels to correct DACs
    enable = 1; cLarge = 0; broadcast = 0;
    for iCh = 1:length(settings.dacSel{iChGp})
        channel = settings.stimCh{iChGp}(iCh); 
        fprintf('Connect channel %d\n', channel);
        k.push_connect_channel(settings.slotNum,enable,settings.dacSel{iChGp}(iCh)-1,cLarge,...
            channel, broadcast);
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
    pause(0.3)
    if settings.saveRecording
        settings.stimTimesActual = zeros(size(settings.ampsIndsRandomize)); % rec stim times
        hidens_startSaving(settings.slotNum, settings.hostIP,settings.recNTKDir,''); % start saving
        tic % start timer
        pause(.1);
        
    end
    
    % create repeats
    iTimeStamp= 1;

    for iAmp=settings.ampsIndsRandomize % go through each randomized voltage
        dacsInUse = unique(settings.dacSel{iChGp});
        numDACs = length(dacsInUse);
        if numDACs > 1
            offset = 512;
            for iTrain = 1:settings.numTrainSpikes{iChGp}
                if iTrain == settings.numTrainSpikes{iChGp}
                    delay = settings.delayInterSpikeMsec*20;
                else
                    delay = settings.interTrainDelayMsec*20;
                end
                k.push_triphasic_simdac_pulse(settings.slotNum, offset, ...
                    settings.amps1{iChGp}(iAmp, 1),settings.amps1{iChGp}(iAmp,2),settings.amps1{iChGp}(iAmp,3), ...
                    settings.amps2{iChGp}(iAmp,1),settings.amps2{iChGp}(iAmp,2),settings.amps2{iChGp}(iAmp,3),...
                    settings.phaseMsec(1)*20, settings.phaseMsec(2)*20,settings.phaseMsec(3)*20,...
                    delay);
            end
        else
            for iTrain = 1:settings.numTrainSpikes{iChGp}
                if iTrain == settings.numTrainSpikes{iChGp}
                    delay = settings.delayInterSpikeMsec*20;
                else
                    delay = settings.interTrainDelayMsec*20;
                end
                if isfield(settings,'amps1')
                    k.push_triphasic_pulse(settings.slotNum, settings.dacSel{iChGp}-1,...
                        settings.iStimGp{iChGp}(iAmp,1),settings.iStimGp{iChGp}(iAmp,2),settings.iStimGp{iChGp}(iAmp,3), ...
                        settings.phaseMsec(1)*20, settings.phaseMsec(2)*20,settings.phaseMsec(3)*20, ...
                        delay);
                elseif isfield(settings,'amps2')
                    k.push_triphasic_pulse(settings.slotNum, settings.dacSel{iChGp}-1,...
                        settings.amps2{iChGp}(iAmp,1),settings.amps2{iChGp}(iAmp,2),settings.amps2{iChGp}(iAmp,3), ...
                        settings.phaseMsec(1)*20, settings.phaseMsec(2)*20,settings.phaseMsec(3)*20, ...
                        delay);
                end

            end
        end
        k.push_simple_delay(20*5); % 20 ms delay
        k.flush
        settings.stimTimesActual(iTimeStamp) =  toc;
        iTimeStamp = iTimeStamp+1;
        pause(settings.delayInterSpikeMsec*1/1000)
    end
    pause(0.3)
    
    if settings.saveRecording
        hidens_stopSaving(settings.slotNum,settings.hostIP);  pause(.1);
        if settings.doSaveLogFile
            if isempty(dirLogFile)
                log_stimulus(settings,iChGp);
            else
                log_stimulus(settings,iChGp,'dir_path', dirLogFile);
            end
        end
    end
    % disconnect
    enable = 0; cLarge = 0; channel = -1; broadcast = 1;
    for iDAC = 1:length(dacsInUse)
        fprintf('disconnect\n')
        k.push_connect_channel(settings.slotNum,enable,dacsInUse(iDAC)-1,cLarge, channel, broadcast);
    end
    k.flush
    pause(0.3)

    
    progress_info(iChGp, length(idxGp));
    
end

end
