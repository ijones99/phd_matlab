%% enter settings:
regionalOutFile = 'neur_regional_scan_01';
stimCellName =  'neur_stim_volt_02_dual_el_test';

%% plot regional footprint
% load regional footprint data
outRegional = load(regionalOutFile);outRegional = outRegional.out;
% plot regional scan footprint
[nrg ah] = open_neurorouter;
neur_struct.regional_scan.plot.plot_footprints(outRegional.footprint,...
    'format_for_neurorouter','scale', 65 )
%% create configuration for stimulus test 
% do this in the matlab neurorouter
dirName = ['../Configs/', stimCellName,'/'];
eval(sprintf('!rename unnamedConfig %s %s', stimCellName, fullfile(dirName, ['unnamedConfig*nrk2'])));
% plot_config_positions_from_el2fi(dirName, ['*',stimCellName,'*'],...
%     'do_plot','label_config_channel_nr');
[elidxInFile chNoInFile] = get_el_ch_no_from_el2fi(dirName, ...
        [stimCellName,'.el2fi.nrk2']);
%% create settings for test stim

clear settings
settings.sessionName = stimCellName;
settings.saveRecording = 1;
settings.recNTKDir = '../proc';
settings.slotNum = 0;
settings.delayInterSpikeMsec = 200;
settings.delayInterAmpMsec = 500;
settings.hostIP = 'bs-dw17'; %pt black setup: 'bs-hpws11'; retina room: 'bs-dw17'
settings.doSaveLogFile = 1;
settings.stimCh{1} = [ 53 108 ];%86;
settings.amps = 50:15:150;

for iStimGp = 1:length(settings.stimCh)
    
    settings.dacSel{iStimGp} = [1 2];
    settings.amps1{iStimGp} = -[settings.amps;-settings.amps; zeros(1,length(settings.amps))]';
    settings.amps2{iStimGp} = [settings.amps;-settings.amps; zeros(1,length(settings.amps))]';
    settings.numReps{iStimGp} = 10;
    settings.phaseMsec = repmat(0.150,1,3);
    
    settings.numTrainSpikes{iStimGp} = 1;
    settings.interTrainDelayMsec = 500;
    settings.stimType{iStimGp}='biphasic'
    
end
%% send stimuli
dirName = strcat('../Configs/', stimCellName, '/');
% get stimulation configuration names
stimInfo = neur_struct.cell_stim_volt.get_stimulation_info_from_el2fi_files(dirName);
configFileName =stimInfo.stimConfigNames{1};
configFileNameCmdraw = strrep(configFileName, '.el2fi.nrk2', '.cmdraw.nrk2');

if ~exist(sprintf('%s%s', dirName, configFileNameCmdraw ),'file')
    convert_config_hex2cmdraw(dirName,stimCellName )
end

% Send config to chip
send_config_to_chip([ dirName], strrep(configFileName,'.el2fi.nrk2',''));
discardAns = input(sprintf('Ok to send stimuli to chip and record to computer %s?',settings.hostIP ))
send_stimuli_to_chip(settings,'dir_log_file', settings.sessionName)
%% put into structure
out = neur_struct.cell_stim_volt.data_analysis.make_out_structure_for_volt_stimulus_response(...
    settings.sessionName)
% print stimulation info
print_stim_settings_data(out.configs_stim_volt, 'stimType', ...                        
    'stimCh', 'flist' );
%% plot response for test stimulus/stimuli
 
readOutChNo =99;
fileNo =2; % refers to log file
neur_struct.cell_stim_volt.plot.plot_volt_stim_response_traces(out, ...
    readOutChNo,'file_no', fileNo);