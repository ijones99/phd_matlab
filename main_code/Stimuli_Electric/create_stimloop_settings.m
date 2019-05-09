function [settings ] = create_stimloop_settings(settings, stimType, ...
    elStim, amps, numReps, phaseWidthMsec, varargin)
% function [settings ] = create_stimloop_settings(settings, stimType ...
%     elStim, amps, numReps, phaseWidthMsec)
%
% iStimGp is the name of the cell in settings into which the new data
% is introduced.
numTrainSpikes = 20;


% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'num_train_spikes')
            numTrainSpikes = varargin{i+1};
        end
    end
end

if isfield(settings,'stimType')
    iStimGp = length(settings.stimType)+1;
else
    iStimGp = 1;
end
%%% -----------------
% single els
if strcmp(stimType, 'biphasic_single_el')
    settings.stimType{iStimGp} = stimType;
    settings.stimCh{iStimGp} = elStim(1);%86;
    settings.dacSel{iStimGp} = [2];
    % rows: values to send seq.; cols: phase
    settings.amps2{iStimGp} = [amps' -amps' zeros(length(amps),1)];
    settings.numReps{iStimGp} = numReps;
    settings.phaseMsec{iStimGp} = repmat(phaseWidthMsec,1,3);
    settings.interTrainDelayMsec{iStimGp} = [];
    settings.numTrainSpikes{iStimGp} = 1;
    
    
elseif strcmp(stimType, 'triphasic_single_el')
    settings.stimType{iStimGp} = stimType;
    settings.stimCh{iStimGp} = elStim(1);%86;
    settings.dacSel{iStimGp} = [1];
    % rows: values to send seq.; cols: phase
    settings.amps2{iStimGp} = [2/3*amps' -amps' 1/3*amps'];
    settings.numReps{iStimGp} = numReps;
    settings.phaseMsec{iStimGp} = repmat(phaseWidthMsec,1,3);
    settings.interTrainDelayMsec{iStimGp} = [];
    settings.numTrainSpikes{iStimGp} = 1;
    
    
elseif strcmp(stimType, 'biphasic_double_el_opposed')
    settings.stimType{iStimGp} = stimType;
    settings.stimCh{iStimGp} = elStim;%86;
    settings.dacSel{iStimGp} = [1 2];
    % rows: values to send seq.; cols: phase
    settings.amps1{iStimGp} = [amps' -amps' zeros(length(amps),1)];
    settings.amps2{iStimGp} = -[amps' -amps' zeros(length(amps),1)];
    settings.numReps{iStimGp} = numReps;
    settings.phaseMsec{iStimGp} = repmat(phaseWidthMsec,1,3);
    settings.interTrainDelayMsec{iStimGp} = [];
    settings.numTrainSpikes{iStimGp} = 1;
    
    
elseif strcmp( stimType, 'biphasic_double_el_same')
    settings.stimType{iStimGp} = stimType;
    settings.stimCh{iStimGp} = elStim;%86;
    settings.dacSel{iStimGp} = [1 2];
    % rows: values to send seq.; cols: phase
    settings.amps1{iStimGp} = [amps' -amps' zeros(length(amps),1)];
    settings.amps2{iStimGp} = [amps' -amps' zeros(length(amps),1)];
    settings.numReps{iStimGp} = numReps;
    settings.phaseMsec{iStimGp} = repmat(phaseWidthMsec,1,3);
    settings.interTrainDelayMsec{iStimGp} = [];
    settings.numTrainSpikes{iStimGp} = 1;
    
    
elseif strcmp(stimType, 'triphasic_double_el_opposed')
    settings.stimType{iStimGp} = stimType;
    settings.stimCh{iStimGp} = elStim;%86;
    settings.dacSel{iStimGp} = [1 2];
    % rows: values to send seq.; cols: phase
    settings.amps1{iStimGp} = [2/3*amps' -amps' 1/3*amps'];
    settings.amps2{iStimGp} = -[2/3*amps' -amps' 1/3*amps'];
    settings.numReps{iStimGp} = numReps;
    settings.phaseMsec{iStimGp} = repmat(phaseWidthMsec,1,3);
    settings.interTrainDelayMsec{iStimGp} = [];
    settings.numTrainSpikes{iStimGp} = 1;
    
    
elseif strcmp(stimType, 'triphasic_double_el_same')
    settings.stimType{iStimGp} = stimType;
    settings.stimCh{iStimGp} = elStim;%86;
    settings.dacSel{iStimGp} = [1 2];
    % rows: values to send seq.; cols: phase
    settings.amps1{iStimGp} = [2/3*amps' -amps' 1/3*amps'];
    settings.amps2{iStimGp} = [2/3*amps' -amps' 1/3*amps'];
    settings.numReps{iStimGp} = numReps;
    settings.phaseMsec{iStimGp} = repmat(phaseWidthMsec,1,3);
    settings.interTrainDelayMsec{iStimGp} = [];
    settings.numTrainSpikes{iStimGp} = 1;
    
    
% ------- burst stimulation -------- %
elseif strcmp(stimType, 'train_biphasic_single_el_same')
    settings.stimType{iStimGp} = stimType;
    settings.stimCh{iStimGp} = elStim(1);%86;
    settings.dacSel{iStimGp} = [2];
    % rows: values to send seq.; cols: phase
    settings.amps2{iStimGp} = [amps' -amps' zeros(length(amps),1)];
    settings.numReps{iStimGp} = numReps;
    settings.phaseMsec{iStimGp} = repmat(phaseWidthMsec,1,3);
    settings.interTrainDelayMsec{iStimGp} = 10;
    settings.numTrainSpikes{iStimGp} = numTrainSpikes;
    
    
end

end