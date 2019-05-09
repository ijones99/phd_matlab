%% enter settings:
regionalOutFile = 'neur_regional_scan_99.mat';
stimCellName =  'neur_stim_volt_99_test';

%% plot regional footprint
% load regional footprint data
outRegional = load(regionalOutFile);outRegional = outRegional.out;
% plot regional scan footprint
[nrg ah] = open_neurorouter;
neur_struct.regional_scan.plot.plot_footprints(outRegional.footprint,...
    'format_for_neurorouter','scale', 65 )
neur_struct.regional_scan.plot.plot_peak2peak_amplitudes(outRegional)

%% create configuration for stimulus test 
% do this in the matlab neurorouter
dirName = ['../Configs/', stimCellName,'/'];
eval(sprintf('!rename unnamedConfig %s %s', stimCellName, fullfile(dirName, ['unnamedConfig*nrk2'])));
% plot_config_positions_from_el2fi(dirName, ['*',stimCellName,'*'],...
%     'do_plot','label_config_channel_nr');
[elidxInFile chNoInFile] = get_el_ch_no_from_el2fi(dirName, ...
        [stimCellName,'.el2fi.nrk2']);

%% plot regional footprint
% load regional footprint data
figure
outRegional = load(regionalOutFile);outRegional = outRegional.out;
gui.plot_hidens_els('marker_style', 'c.'), hold on
neur_struct.regional_scan.plot.plot_footprints(outRegional.footprint,'scale', 65 )
neur_struct.regional_scan.plot.plot_peak2peak_amplitudes(outRegional)

%% create configs for regional footprint

all_els=hidens_get_all_electrodes(2);
figNum = input('fig #>> '); figure(figNum);
fprintf('Select test els\n');
junk = input('Zoom to position and press [enter] to begin:');
numElsPerConfig = 15;
staticEls = clickelectrode('color', 'r','num_els',numElsPerConfig);
recEls = [];scanEls = staticEls ;
configPath = sprintf('../Configs/%s/', stimCellName); mkdir(configPath);
configs.create_stim_configurations(scanEls, staticEls, recEls, ...
    numElsPerConfig, stimCellName, configPath  );


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
settings.stimCh{1} = [92 ];%86;
settings.amps = 50:50:550;
for iStimGp = 1:length(settings.stimCh)
    
    settings.dacSel{iStimGp} = [2];
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
    'stimCh', 'stimEl', 'flist' );
%% plot response for test stimulus/stimuli
all_els=hidens_get_all_electrodes(2);
figure
gui.plot_hidens_els('marker_style', 'c.'), hold on
neur_struct.regional_scan.plot.plot_footprints(outRegional.footprint,...
    'scale', 65 );
plot_els_from_el_idx(cell2mat(out.configs_stim_volt.stimEl),'all_els',all_els)
plot_els_from_el_idx(out.stim_in_out.read_els.axon,'marker_face_color','g')
plot_els_from_el_idx(out.stim_in_out.read_els.soma,'marker_face_color','c')
%% load mea data
for i=1:length(out.configs_stim_volt.flist)
    meaData(i) = mysort.mea.CMOSMEA(strrep(out.configs_stim_volt.flist{i},'.ntk','.h5'), 'useFilter', 0, 'name', 'Raw');
    progress_info(i,length(out.configs_stim_volt.flist))
end

%%
stimElIdx = 7291; readoutElIdx = out.stim_in_out.read_els.axon(2);

i = cellfind(out.configs_stim_volt.stimEl,stimElIdx);
fprintf('file # %d.\n',i)
neur_struct.cell_stim_volt.plot.plot_volt_stim_response_traces(out, ...
    [],'file_no', i ,'readout_elidx', readoutElIdx,'mea_data',meaData(i));


%% ---------------->>>>>>>>> plot regional footprint <<<<<<<<<<<<------------------------
% [nrg ah] = open_neurorouter;
h=figure
gui.plot_hidens_els('marker_style', 'kx'), hold on 
neur_struct.regional_scan.plot.plot_footprints(outRegional.footprint,'scale', 60 )
neur_struct.regional_scan.plot.plot_peak2peak_amplitudes(outRegional)
%% create configurations below cell
runName = 'neur_stim_cell_01';

all_els=hidens_get_all_electrodes(2);
fprintf('Select static somatic els\n');
junk = input('Zoom to position and press [enter] to begin:');
figure(h)
somaStaticEls = clickelectrode('color', 'r','num_els',5);

fprintf('Select static axonal els\n');
junk = input('Zoom to position and press [enter] to begin:');
axonStaticEls = clickelectrode('color', 'r','num_els',7);
hold on
staticEls = [somaStaticEls axonStaticEls];
neur_struct.regional_scan.plot.plot_peak2peak_amplitudes(outRegional)
fprintf('Select all els\n');
junk = input('Zoom to position, press [enter], and select all electrodes:');
[scanEls indsLocalInside] = select_els_in_sel_pt_polygon( all_els, 'num_points',20)
fprintf('Done selecting scanning electrodes.\n')

recEls = [];
numElsPerConfig = 30;
configPath = sprintf('../Configs/%s/', runName);
configs.create_stim_configurations(scanEls, staticEls, recEls, ...
    numElsPerConfig, runName, configPath  );
configs_stim_volt = settings;
save(sprintf('%s_configs_stim_volt', runName), 'configs_stim_volt');


sort(staticEls)
somaStaticEls
axonStaticEls
routedEls = neur_struct.cell_stim_volt.check_routing(runName);
out.stim_in_out.read_els.soma = ...
    somaStaticEls(find(ismember(somaStaticEls,routedEls)));
out.stim_in_out.read_els.axon = ...
    axonStaticEls(find(ismember(axonStaticEls,routedEls)));
save(sprintf('%s_configs_stim_volt', runName), 'configs_stim_volt','out');

%% create settings for full stimulation all over neuron
dirName = strcat('../Configs/', runName, '/');
% stimCellName = [runName,'05'];
% get stimulation configuration names
stimInfo = neur_struct.cell_stim_volt.get_stimulation_info_from_el2fi_files(dirName);
clear settings
for iConfig = 1:length(stimInfo.stimConfigNames) % look through electrode configs
    
    settings{iConfig}.sessionName = runName;
    settings{iConfig}.saveRecording = 1;
    settings{iConfig}.recNTKDir = '../proc';
    settings{iConfig}.slotNum = 0;
    settings{iConfig}.delayInterSpikeMsec = 200;
    settings{iConfig}.delayInterAmpMsec = 500;
    settings{iConfig}.hostIP = 'bs-dw17'; %pt black setup: 'bs-hpws11'; retina room: 'bs-dw17'
    settings{iConfig}.doSaveLogFile = 1;
    settings{iConfig}.amps = 200:40:400;
    settings{iConfig}.config = stimInfo.stimConfigNames{iConfig};
    settings{iConfig}.phaseMsec = repmat(0.150,1,3);
    settings{iConfig}.interTrainDelayMsec = 500;
    
    for iStimGp = 1:length(stimInfo.chNoInFile{iConfig})
        settings{iConfig}.stimCh{iStimGp} = stimInfo.chNoInFile{iConfig}(iStimGp);
        settings{iConfig}.dacSel{iStimGp} = [2];
        settings{iConfig}.amps2{iStimGp} = [settings{iConfig}.amps;-settings{iConfig}.amps; zeros(1,length(settings{iConfig}.amps))]';
        settings{iConfig}.numReps{iStimGp} = 7;
        settings{iConfig}.numTrainSpikes{iStimGp} = 1;       
        settings{iConfig}.stimType{iStimGp}='biphasic';
    end
    
end

% runTime = 125*10*0.2*6/60


%% send stimuli
discardAns = input(sprintf('Ok to send stimuli to chip and record to computer %s and slot # %d?',...
    settings{1}.hostIP,settings{iConfig}.slotNum ))

startTime = datestr(now,31);
for iStimConfig = 1:length(stimInfo.stimConfigNames)
    
    configFileName =strrep(settings{iStimConfig}.config,'.el2fi.nrk2','');
    
    if ~exist(sprintf('%s%s.cmdraw.nrk2', dirName, configFileName ))
        convert_config_hex2cmdraw(dirName, configFileName)
    end
    
    % Send config to chip
    send_config_to_chip([ dirName], configFileName);
    send_stimuli_to_chip(settings{iStimConfig},'dir_log_file',runName );
    fprintf('----------------->>>>>>>>>>>>> # %d/%d configs done >>>>>>>>>>>>> ------------',...
        iStimConfig,length(stimInfo.stimConfigNames) )
end

%% put into structure
out = neur_struct.cell_stim_volt.data_analysis.make_out_structure_for_volt_stimulus_response(runName,out);

% print stimulation info
print_stim_settings_data(out.configs_stim_volt, 'stimType', ...                        
    'stimCh', 'flist' );

save(runName,'out')

%% %%%--------------------------------- Do electrode pair stim --------------
%% ---------------->>>>>>>>> stimulus electrode pairs: plot regional footprint <<<<<<<<<<<<------------------------


%%
h=figure
gui.plot_hidens_els('marker_style', 'kx'), hold on 
neur_struct.regional_scan.plot.plot_footprints(outRegional.footprint,'scale', 70 )
neur_struct.regional_scan.plot.plot_peak2peak_amplitudes(outRegional)

%% create configurations below cell
runName = 'stim_cell_01_parallel';
dirName = sprintf('../Configs/%s/', runName);
mkdir(dirName)
% extract electrode numbers

all_els=hidens_get_all_electrodes(2);
fprintf('Select static somatic els\n');
junk = input('Zoom to position and press [enter] to begin:');
figure(h)
somaStaticEls = clickelectrode('color', 'r','num_els',5);

fprintf('Select static axonal els\n');
junk = input('Zoom to position and press [enter] to begin:');
axonStaticEls = clickelectrode('color', 'r','num_els',5);
hold on
staticEls = [somaStaticEls axonStaticEls];

fprintf('Clear selected els\n')
junk = input('Select all els');

selectedEls = [];
% selectedEls = nrg.configList.selectedElectrodes(:,1)-1; % for some reason, one must be subtracted
selectedEls = clickelectrode('color', 'r');
numElPairs = length(selectedEls)/2;
if isint(numElPairs)
    selectedElectrodePairsMat = reshape(selectedEls,2,numElPairs)';
    selectedElectrodePairsMat(end+1:end+numElPairs-1,:) = ...
        reshape(selectedEls(2:end-1),2,numElPairs-1)';
        
else
    fprintf('Must have an even # of electrodes!\n');
end
% cell of groups
all_els=hidens_get_all_electrodes(2);
pairDel = [];
for iPair = 1:size(selectedElectrodePairsMat,1)
   dist = configs.get_distance_between_els(selectedElectrodePairsMat(iPair,:), ...
       all_els) 
    if dist > 50
       pairDel(end+1) = iPair; 
    end
end
% delete pairs that are far away
selectedElectrodePairsMat(pairDel,:) = [];
% selectedElectrodePairsMat(end+1:size(selectedElectrodePairsMat,1)+end,:) = ...
%     selectedElectrodePairsMat(:,2:-1:1);

% first of pairs
selElsFirstPair = selectedElectrodePairsMat(:,1);
for i=1:length(selectedElectrodePairsMat)
    selElPairsCell{i} = selectedElectrodePairsMat(i,:);
end
% 
numElsInGroup = 28;
numPairsInGroup = numElsInGroup/2;
elIdxGpIdx = separate_into_groups_of_indices(1:length(selElsFirstPair), numPairsInGroup);
%%
clear settings
configs_stim_volt = {};
for iConfigs = 1:ceil(numElPairs/numElsInGroup)
    
    % get all els for this config
    elIdxToRouteMat = selectedElectrodePairsMat(elIdxGpIdx{iConfigs},:);
    elIdxToRoute = reshape(elIdxToRouteMat,1,size(elIdxToRouteMat,1)*size(elIdxToRouteMat,2));
    
    % create configuration (el2fi)
    configs_stim_volt{iConfigs} = generate_specific_point_defined_stim_configs(elIdxToRoute, ...
    staticEls, runName, 'no_plot','stim_els', 'scan_els_cost', 0, 'stim_scan_els',...
    'file_name_start_number', iConfigs, 'num_route',numElsInGroup);
    
    configFileName = sprintf('StimEls%d', iConfigs);
    [elidxInFile chNoInFile] = get_el_ch_no_from_el2fi(dirName, configFileName);
    settings{iConfigs}.configName = configFileName;
    settings{iConfigs}.elIdxConfig = elidxInFile;
    settings{iConfigs}.channelNrConfig = chNoInFile;
    
    % remove nonrouted pairs
    routedIdx = find(~sum(~ismember(elIdxToRouteMat, elidxInFile),2)>0);
    settings{iConfigs}.stimEl = selElPairsCell(elIdxGpIdx{iConfigs}(routedIdx'));
    
end


routedEls = neur_struct.cell_stim_volt.check_routing(runName)
out.stim_in_out.read_els.soma = ...
    somaStaticEls(find(ismember(somaStaticEls,routedEls)));
out.stim_in_out.read_els.axon = ...
    axonStaticEls(find(ismember(axonStaticEls,routedEls)));
save(sprintf('%s_configs_stim_volt', runName), 'configs_stim_volt','out');
%% create settings for full stimulation all over neuron
dirName = strcat('../Configs/', runName, '/');
stimCellName = [runName];
% get stimulation configuration names
stimInfo = neur_struct.cell_stim_volt.get_stimulation_info_from_el2fi_files(dirName);

for iConfig = 1:length(stimInfo.stimConfigNames) % look through electrode configs
    
    settings{iConfig}.sessionName = stimCellName;
    settings{iConfig}.saveRecording = 1;
    settings{iConfig}.recNTKDir = '../proc';
    settings{iConfig}.slotNum = 0;
    settings{iConfig}.delayInterSpikeMsec = 200;
    settings{iConfig}.delayInterAmpMsec = 500;
    settings{iConfig}.hostIP = 'bs-dw17'; %pt black setup: 'bs-hpws11'; retina room: 'bs-dw17'; room 3.60: 'bs-hpdt53'
    settings{iConfig}.doSaveLogFile = 1;
    settings{iConfig}.amps = [100:50:800]/2;
    settings{iConfig}.config = stimInfo.stimConfigNames{iConfig};
    settings{iConfig}.phaseMsec = repmat(0.150,1,3);
    settings{iConfig}.interTrainDelayMsec = 500;
    
    for iStimGp = 1:length(stimInfo.chNoInFile{iConfig})
%         settings{iConfig}.stimCh{iStimGp} = stimInfo.chNoInFile{iConfig}(iStimGp);
        settings{iConfig}.dacSel{iStimGp} = [1 2];
        settings{iConfig}.amps1{iStimGp} = [settings{iConfig}.amps;-settings{iConfig}.amps; zeros(1,length(settings{iConfig}.amps))]';
        settings{iConfig}.amps2{iStimGp} = [-settings{iConfig}.amps;settings{iConfig}.amps; zeros(1,length(settings{iConfig}.amps))]';
        
        settings{iConfig}.numReps{iStimGp} = 10;
        settings{iConfig}.numTrainSpikes{iStimGp} = 1;
        settings{iConfig}.stimType{iStimGp}='biphasic';
    end
    
end

%% send stimuli
discardAns = input(sprintf('Ok to send stimuli to chip and record to computer %s and slot # %d?',...
    settings{1}.hostIP,settings{iConfig}.slotNum ))

startTime = datestr(now,31);
for iStimConfig = 1:length(stimInfo.stimConfigNames)
    
    configFileName =strrep(settings{iStimConfig}.config,'.el2fi.nrk2','');
    
    if ~exist(sprintf('%s%s.cmdraw.nrk2', dirName, configFileName ))
        convert_config_hex2cmdraw(dirName, configFileName)
    end
     [elidxInFile chNoInFile] = get_el_ch_no_from_el2fi(dirName, configFileName);
     settings{iStimConfig}.stimCh = {};
    for iCh = 1:length(settings{iStimConfig}.stimEl)
       settings{iStimConfig}.stimCh{iCh} = el2ch(settings{iStimConfig}.stimEl{iCh}, elidxInFile, chNoInFile) ;
    end
    % Send config to chip
    send_config_to_chip([ dirName], configFileName);
    send_stimuli_to_chip(settings{iStimConfig},'dir_log_file',runName );
    fprintf('----------------->>>>>>>>>>>>> # %d done >>>>>>>>>>>>> ------------',iStimConfig )
end

%% put into structure
out = neur_struct.cell_stim_volt.data_analysis.make_out_structure_for_volt_stimulus_response(runName);
save(sprintf('config_%s',  runName), 'out')
% print stimulation info
print_stim_settings_data(out.configs_stim_volt, 'stimType', ...                        
    'stimCh', 'flist' );

%% plot response for test stimulus/stimuli
 fileNo =20; % refers to log file

readOutChNo =21;
neur_struct.cell_stim_volt.plot.plot_volt_stim_response_traces(out, ...
    readOutChNo,'file_no', fileNo);