clear settings
settings.sessionName = 'neur_stim_cell_volt_01'
settings.saveRecording = 1;
settings.recNTKDir = '../proc';
settings.slotNum = 0;
settings.saveRecording = 1;
settings.delayInterSpikeMsec = 200;
settings.delayInterAmpMsec = 500;
settings.hostIP = 'bs-dw17'; %'bs-hpws11'
settings.doSaveLogFile = 1;
settings.stimCh = {59 24 74 80 12 98 68 6 92 117 0 44 89};%86;
 

for iStimGp = 1:length(settings.stimCh)
    
    settings.dacSel{iStimGp} = [2];
    % rows: values to send seq.; cols: phase
    settings.amps2{iStimGp} = -1*[repmat(100:100:700,2,1); [0 0 0]]'
    %     settings.amps1{iStimGp}(:,2) = settings.amps1{iStimGp}(:,2)*-1;
    settings.numReps{iStimGp} = 5;
    settings.phaseMsec{iStimGp} = repmat(0.150,1,3);
    settings.numTrainSpikes{iStimGp} = 1;
    settings.interTrainDelayMsec{iStimGp} = 500;
    settings.stimType{iStimGp}='biphasic'
    
end

%%
% send stimuli to chip
send_stimuli_to_chip(settings)