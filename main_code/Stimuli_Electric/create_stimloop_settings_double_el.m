function [settings ] = create_stimloop_settings_double_el(settings, ...
    elStim, amps, numReps, phaseWidthMsec)
% function [settings iStimGp] = create_stimloop_settings_single_el(settings, ...
%     iStimGp, elStim, amps, numReps, phaseWidthMsec)


if isfield(settings,'stimType')
    iStimGp = length(settings.stimType)+1;
else
    iStimGp = 1;
end
%%% -----------------
stimType = 'biphasic_double_el_opposed';
settings.stimType{iStimGp} = stimType;
settings.stimCh{iStimGp} = elStim;%86;
settings.dacSel{iStimGp} = [1 2];
% rows: values to send seq.; cols: phase  
settings.amps1{iStimGp} = [amps' -amps' zeros(length(amps),1)];
settings.amps2{iStimGp} = -[amps' -amps' zeros(length(amps),1)];
settings.numReps{iStimGp} = numReps;
settings.phaseMsec{iStimGp} = repmat(phaseWidthMsec,1,3);

%%% -----------------
stimType = 'biphasic_double_el_same';
iStimGp = iStimGp+1;
settings.stimType{iStimGp} = stimType;
settings.stimCh{iStimGp} = elStim;%86;
settings.dacSel{iStimGp} = [1 2];
% rows: values to send seq.; cols: phase  
settings.amps1{iStimGp} = [amps' -amps' zeros(length(amps),1)];
settings.amps2{iStimGp} = [amps' -amps' zeros(length(amps),1)];
settings.numReps{iStimGp} = numReps;
settings.phaseMsec{iStimGp} = repmat(phaseWidthMsec,1,3);

%%% -----------------
stimType = 'triphasic_double_el_opposed';
iStimGp = iStimGp+1;
settings.stimType{iStimGp} = stimType;
settings.stimCh{iStimGp} = elStim;%86;
settings.dacSel{iStimGp} = [1 2];
% rows: values to send seq.; cols: phase  
settings.amps1{iStimGp} = [2/3*amps' -amps' 1/3*amps'];
settings.amps2{iStimGp} = -[2/3*amps' -amps' 1/3*amps'];
settings.numReps{iStimGp} = numReps;
settings.phaseMsec{iStimGp} = repmat(phaseWidthMsec,1,3);

%%% -----------------
stimType = 'triphasic_double_el_same';
iStimGp = iStimGp+1;
settings.stimType{iStimGp} = stimType;
settings.stimCh{iStimGp} = elStim;%86;
settings.dacSel{iStimGp} = [1 2];
% rows: values to send seq.; cols: phase  
settings.amps1{iStimGp} = [2/3*amps' -amps' 1/3*amps'];
settings.amps2{iStimGp} = [2/3*amps' -amps' 1/3*amps'];
settings.numReps{iStimGp} = numReps;
settings.phaseMsec{iStimGp} = repmat(phaseWidthMsec,1,3);





end