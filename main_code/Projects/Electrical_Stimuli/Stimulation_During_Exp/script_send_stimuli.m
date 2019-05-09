%% start stimloop
k = stimloop;
k.setTimeout(5000);
%% disconnect el
slotNum = 0; enable = 0; dacSel = 0; cLarge = 0; channel = -1; broadcast = 1;
k.push_connect_channel(slotNum,enable,dacSel,cLarge, channel, broadcast);
k.flush
%% connect el
slotNum = 0; enable = 1; dacSel = 0; cLarge = 0; channel = 83; broadcast = 0;
k.push_connect_channel(slotNum,enable,dacSel,cLarge, channel, broadcast);
k.flush
%% biphasic pulse
phaseMsec = 4;
delayMsec = 100;
for i = 1:5
    amp = 50;
    k.push_simple_pulse(slotNum, 0, amp, phaseMsec*20)
    k.push_simple_delay(delayMsec*20); % 30 ms delay
    
end
k.flush
%% triphasic pulse
ampsTriPhasic = [100 -150 50];
phaseTriPhasic = [4 4 4 ];
phaseMsec = 4;
delayMsec = 100;
for i = 1
    k.push_triphasic_pulse(slotNum,dacSel,ampsTriPhasic(1),ampsTriPhasic(2),...
       ampsTriPhasic(3), ...
       phaseTriPhasic(1), phaseTriPhasic(2), phaseTriPhasic(3), delayMsec*20);
   k.push_simple_delay(delayMsec*20); % 30 ms delay
end
k.flush
%% create configurations below cell
sortingRunName = 'neur_stim_cell_volt_01'
staticEls = [];
[scanEls indsLocalInside] = select_els_in_sel_pt_polygon( all_els, 'num_points',15 )
fprintf('Done selecting scanning electrodes.\n')

pause(0.5)
% get area to scan
configs_stim_light = generate_specific_point_defined_stim_configs(scanEls, ...
    staticEls, sortingRunName, 'no_plot','stim_els')



%% send multiple biphasic pulses

% --- constants ---
recNTKDir = '../proc';
SAVE_RECORDING = 1;
runName = 'neur_stim_cell_volt_01';
junk = input(sprintf('Save = %d and run name is "%s." Ok? [enter]', SAVE_RECORDING, ...
    runName));
hostIP = 'bs-dw17'; 
    % // Host IPs
    % bs-dw17: recording computer in retina room
    % bs-hpws11: pt black deposition computer

% --- settings----
clear k
k = stimloop
settings.saveRecording = SAVE_RECORDING;
settings.recNTKDir = recNTKDir;
settings.hostIP = hostIP;
settings.stimCh = [86]% 6 74 114 21];
settings.slotNum = 0;
settings.amps = 20:20:100;
settings.numReps = 25;
    idxAmps = repmat(1:length(settings.amps),1,settings.numReps);
    idxAmpsRandPermInds = randperm(length(idxAmps));
settings.ampsIndsRandomize = idxAmps(idxAmpsRandPermInds);
settings.phaseMsec = 0.150;
settings.delayInterSpikeMsec = 200;
settings.delayInterAmpMsec = 500;
if sum(settings.amps(:,1))~=0 && sum(settings.amps(:,2))~=0 && sum(settings.amps(:,3))==0
   settings.pulse_type = 'biphasic'; 
end
pause(1)
% --- loop ------
for iCh = 1:length(settings.stimCh)
    % connect ch
    settings.slotNum = 0; enable = 1; dacSel = 0; cLarge = 0; 
    channel = settings.stimCh(iCh); broadcast = 0;
    k.push_connect_channel(settings.slotNum,enable,dacSel,cLarge, channel, broadcast);

        pause(1)
    if SAVE_RECORDING
        hidens_startSaving(settings.slotNum, hostIP,recNTKDir, num2str(settings.stimCh)); pause(.1);
    end

    % create repeats
    for iAmp=settings.ampsIndsRandomize
        
        k.push_simple_pulse(settings.slotNum, 0, settings.amps(iAmp), settings.phaseMsec*20)
        k.push_simple_delay(20*5); % 30 ms delay
        k.flush
        pause(settings.delayInterSpikeMsec*1/1000)
    end
    pause(0.5)
    settings.slotNum = 0; enable = 0; dacSel = 0; cLarge = 0; channel = -1; broadcast = 1;
    k.push_connect_channel(settings.slotNum,enable,dacSel,cLarge, channel, broadcast);
    k.flush
    pause(1)
    if SAVE_RECORDING
        hidens_stopSaving(settings.slotNum,hostIP);  pause(.1);
        log_stimulus(settings, iCh, 'dir_path', runName);
    end
    
  
end

%% send multiple triphasic pulses
clear k
k = stimloop
% --- settings----
recNTKDir = '../proc/';
SAVE_RECORDING = 1;
hostIP = 'bs-dw17';
stimCh = [9];
slotNum = 0;
ampsTriPhasic = [75 -100 25];
ampsMult = [1:0.5:10];
phaseTriPhasic = [1 1 1 ]*0.150;
numReps = 15;
delayInterSpikeMsec = 200;
delayInterAmpSec = 0.5;
% --- loop ------
for iCh = 1:length(stimCh)
    % connect ch
    slotNum = 0; enable = 1; dacSel = 0; cLarge = 0; channel = stimCh(iCh); broadcast = 0;
    k.push_connect_channel(slotNum,enable,dacSel,cLarge, channel, broadcast);
    k.flush
    
    if SAVE_RECORDING
        hidens_startSaving(slotNum, hostIP,recNTKDir,[]); pause(.1);
    end

    % create repeats
    for iAmp=1:length(ampsMult)
        amps = ampsTriPhasic*ampsMult(iAmp);
        for iRep = 1:numReps
            k.push_triphasic_pulse(slotNum,dacSel,amps(1),amps(2), amps(3), ...
                phaseTriPhasic(1)*20, phaseTriPhasic(2)*20, phaseTriPhasic(3)*20, delayInterSpikeMsec*20);
            
        
            k.push_simple_delay(delayInterSpikeMsec*20); % 30 ms delay
        end
        k.flush
        fprintf('Amps %d ...\n', amps(2));
        pause(delayInterAmpSec);
    end

    if SAVE_RECORDING
        hidens_stopSaving(slotNum,hostIP);  pause(.1);
    end
    
    slotNum = 0; enable = 0; dacSel = 0; cLarge = 0; channel = -1; broadcast = 1;
    k.push_connect_channel(slotNum,enable,dacSel,cLarge, channel, broadcast);
    k.flush
end

%% send multiple opposed biphasic pulses
% RANDOMIZE!!!!
clear k
k = stimloop
% --- constants ---
hostIP = 'bs-dw17';
recNTKDir = '../proc';

SAVE_RECORDING = 1;
doSaveSettingsFile = 1;
% --- settings----

settings.stimCh = [59]% 6 74 114 21];
settings.stimCh2 = [123]% 6 74 114 21];
settings.slotNum = 0;
settings.amps = [20:50:500]%:50:1000];
settings.numReps = 25;
settings.phaseMsec = 0.150;
settings.delayInterSpikeMsec = 200;
settings.delayInterAmpMsec = 500;
pause(1)
% --- loop ------
for iCh = 1:length(settings.stimCh)
    % connect ch
    settings.slotNum = 0; enable = 1; dacSel = 0; cLarge = 0; channel = settings.stimCh(iCh); broadcast = 0;
    k.push_connect_channel(settings.slotNum,enable,dacSel,cLarge, channel, broadcast);
    % connect ch2
    settings.slotNum = 0; enable = 1; dacSel = 1; cLarge = 0; channel = settings.stimCh2(iCh); broadcast = 0;
    k.push_connect_channel(settings.slotNum,enable,dacSel,cLarge, channel, broadcast);
    
    k.flush
    for iAmp=1:length(settings.amps)
        for iRep = 1:settings.numReps
%             k.push_simple_pulse(settings.slotNum, 1, settings.amps(iAmp), settings.phaseMsec*20);
%             k.push_simple_pulse(settings.slotNum, 0, settings.amps(iAmp), settings.phaseMsec*20);
           k.push_triphasic_simdac_pulse(settings.slotNum, 512, settings.amps(iCh),-settings.amps(iCh),0, ...
               -settings.amps(iCh),settings.amps(iCh), 0,settings.phaseMsec*20, settings.phaseMsec*20,settings.phaseMsec*20,...
               settings.delayInterSpikeMsec*20)
            k.push_simple_delay(settings.delayInterSpikeMsec*20); % 30 ms delay
        end
    end
    if SAVE_RECORDING
        hidens_startSaving(settings.slotNum, hostIP,recNTKDir,[]); pause(.1);
    end

    % create repeats
    for iAmp=1:length(settings.amps)
      
        k.flush
        fprintf('Amps %d\n', settings.amps(iAmp));
        pause(settings.delayInterAmpMsec/1000);
    end

    if SAVE_RECORDING
        hidens_stopSaving(settings.slotNum,hostIP);  pause(.1);
    end
    
    settings.slotNum = 0; enable = 0; dacSel = 0; cLarge = 0; channel = -1; broadcast = 1;
    k.push_connect_channel(settings.slotNum,enable,dacSel,cLarge, channel, broadcast);
    k.flush
end
if doSaveSettingsFile
    dirStimSettings = 'stim_settings'; mkdir(dirStimSettings);
    fileNameStimSettings = ['stim_settings_',datestr(now, 'yyyy-mmmm-dd'),'_time_',datestr(now,'HH-MM-SS'),'.mat'];
    save(fullfile(dirStimSettings,fileNameStimSettings),'settings');
end

