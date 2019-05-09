%% open chip viewer
nrg = nr.Gui
set(gcf, 'currentAxes',nrg.ChipAxesBackground)
%% -------------- create config to stimulate while scanning region (or use previous values) ----------------
% create configs for scanning area
sortGroupNumber =2;
all_els=hidens_get_all_electrodes(2);
sortingRunName = sprintf('regional_stim_%02d',sortGroupNumber);
scanConfigDir = sprintf('../Configs/%s/', sortingRunName );
mkdir(scanConfigDir)
numStaticEls = 1;
fprintf('Please select %d electrode(s)\n',numStaticEls); 

% get static els near init segment
while length(nrg.configList.selectedElectrodes) < numStaticEls 
    pause(0.25)
end
staticEls = nrg.configList.selectedElectrodes(1:numStaticEls);
fprintf('Done selecting fixed (init segment) electrodes.\n')

m = input('Press key> ');

% get scanning els
[scanEls indsLocalInside] = select_els_in_sel_pt_polygon( all_els )
fprintf('Done selecting scanning electrodes.\n')

pause(0.5)
% get area to scan
config_info = generate_specific_point_defined_stim_configs(scanEls, staticEls,...
    sortingRunName, 'no_plot','stim_els')
save(sprintf('%s_electrode_number_selection.mat', sortingRunName ), 'config_info',...
    'scanEls', ...
    'indsLocalInside', 'staticEls');

%% send configurations to chip while stimulating electrically %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ------------------ SETTINGS ------------------ %

pause(1)
elidxStim = staticEls(1);
% --- constants ---
% ---------------------------------------------- %
fileNameConfig = dir([[ scanConfigDir,'/'], '*hex.nrk2']);
fileNameEl2Fi= dir([[ scanConfigDir,'/'], '*el2fi*']);
for i=1:length(fileNameConfig)
    fileNameConfig(i).name = strrep(fileNameConfig(i).name,'.hex.nrk2','');
end
if scanConfigDir(end) ~= '/';
    scanConfigDir(end+1) = '/';
end
clear settings
settings.sessionName = sortingRunName
settings.saveRecording = 1;
settings.recNTKDir = '../proc';
settings.slotNum = 0;
settings.saveRecording = 1;
settings.delayInterSpikeMsec = 200;
settings.delayInterAmpMsec = 500;
settings.hostIP = 'bs-hpws11';
settings.doSaveLogFile = 1;

for iStimGp = 1:length(fileNameConfig)
    settings.stimCh{iStimGp} = [3];%86;
    settings.dacSel{iStimGp} = [2];
    % rows: values to send seq.; cols: phase
    settings.amps1{iStimGp} = [200 -200 0];
%     settings.amps1{iStimGp}(:,2) = settings.amps1{iStimGp}(:,2)*-1;
    settings.numReps{iStimGp} = 15;
    settings.phaseMsec{iStimGp} = repmat(0.150,1,3);
end

doConvertHex = 0;

clear k
k = stimloop
for iFile=1:length(fileNameConfig)
    % Convert hex to cmdraw.nrk2
    iFile;
    
    if ~exist(sprintf('%s%s.cmdraw.nrk2', scanConfigDir, fileNameConfig(iFile).name)) || doConvertHex
        convert_config_hex2cmdraw(['../Configs/', scanConfigDir], fileNameConfig(iFile).name);
    end
      
    % --- settings----
    settings.stimCh{iFile} = elidx2ch(fullfile(scanConfigDir,fileNameEl2Fi(iFile).name),elidxStim);% 6 74 114 21];
    fprintf('stim channel %d\n', settings.stimCh{iFile});
    
    send_config_to_chip(['../Configs/', scanConfigDir], fileNameConfig(iFile).name)
    pause(0.5);
    send_stimuli_to_chip(settings,'sel_group_no', iFile)

end
 
% log_stimulus(settings);
disp('Done.')
%%
%% Convert to h5
for i=1:length(flist)
    mysort.mea.convertNTK2HDF(flist{i},'prefilter', 1);
    fprintf('progress %3.0f\n', 100*i/length(flist));
end

%%
flist = get_flist_names


pulseType = 'biphasic';
if strcmp(pulseType,'biphasic')
    step = 3;
elseif strcmp(pulseType,'triphasic')
    step = 4;
end
for iFile=1:length(fileNameConfig)
    ntkOut{iFile} = load_field_ntk(flist{iFile}, {'dac2'});
    
        % get stim timepoints
    voltSwitchTime = diff(ntkOut{iFile}.dac2); 
    switchTimePts = find(voltSwitchTime~=0); % indices 
    ...for time point switches (#phases + 1 per pulse: 
    ...e.g. for biphasic pulse, 3 points per pulse. (see step size)
    
    stimPulsePts{iFile} = switchTimePts(1:step:end); % 
    
end
%% load all h5 files (regional scan)
mea1 = {};
for i=1:length(flist)
    h5FileName = strrep(flist{i},'ntk','h5');
    mea1{i} = mysort.mea.CMOSMEA(h5FileName, 'useFilter', 0, 'name', 'Raw');
    fprintf('Loading...%3.0f percent done.\n', i/length(flist)*100)
end
%% open chip viewer
nrg = nr.Gui
set(gcf, 'currentAxes',nrg.ChipAxesBackground)

%% plot the footprint
doPlotNeuroRouter= 1;

if doPlotNeuroRouter
        nrg = nr.Gui
        set(gcf, 'currentAxes',nrg.ChipAxesBackground)
        ah = nrg.ChipAxes;
        
end

%

% for movie
mposx = [];
mposy = [];
mat = [];


for i=4:length(flist)
    try
    spikeTimesSamples =stimPulsePts{iFile};
    h5Data = mea1{i};
    [data] = extract_waveforms_from_h5(h5Data, spikeTimesSamples );
    
    dataOffsetCorr = data.average-repmat(mean(data.average(:,end-30:end),2),1,size(data.average,2));
    
    plot_footprints_simple([data.x data.y], ...
    dataOffsetCorr, ...
    'input_templates','hide_els_plot','format_for_neurorouter',...
    'plot_color','b', 'flip_templates_ud','flip_templates_lr'); 

    mposx = [mposx ; data.x];
    mposy = [mposy ; data.y];
    mat   = [mat ; dataOffsetCorr ];
    
    catch
        fprintf('No spikes for %d.\n', i)
    end
    drawnow
    if ~doPlotNeuroRouter
        axis equal
        
    end
    progress_info(i,length(mea1))
end

