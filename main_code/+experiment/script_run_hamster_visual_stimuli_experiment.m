% SCAN ARRAY FOR ACTIVITY

% send visual stimulus

% plot configs
configDirName = '/home/ijones/Experiments/Configs/Projects/Electrical_Stimulation/18x6_spc1_tile7x14_main_ds_scan/'

iConfigNumber=1:98
plotConfig = input('Plot electrode config [y/n].','s')
if strcmp(plotConfig,'y')
    figure, hold on
    gui.plot_hidens_els, hold on
    plot_electrode_config_by_num(configDirName, iConfigNumber,'plot_rand_color',...
        'label_with_number');
end
%% select configurations
configNos = [24 26];patternLength = length(configNos);
for i = 1:7
    configNos = [configNos configNos(end-1:end)+...
        7*ones(1,patternLength)];
end
fileNameConfig = configs.get_el_config_names_by_number(configDirName, configNos);

junk = input('Please start visual stimulus and press enter when ready >>');
% send configuration during visual stimulus
configs.send_configs_to_chip(configDirName, fileNameConfig)

%% make flist
[sortGroupNumber flist sortingRunName] = flists.make_and_save_flist;

% compute all activity maps
clear activity_map
for i=1:length(flist)
    activity_map{i} = wrapper.patch_scan.extract_activity_map(flist{i});
    progress_info(i,length(flist));
    
end
save(sprintf('activity_map_%02d',sortGroupNumber), 'activity_map');
%% plot activity maps on array
figure
gui.plot_hidens_els('marker_style', 'cx'), hold on
dirNameConfig = '/home/ijones/Experiments/Configs/Projects/Electrical_Stimulation/18x6_spc1_tile7x14_main_ds_scan/';
load(fullfile(dirNameConfig,'configCtrXY'));

for i=1:length(flist)
    hidens_generate_amplitude_map(activity_map{i},'no_border','no_colorbar', ...
        'no_plot_format','do_use_max');
    text(configCtrX(configNos(i)),configCtrY(configNos(i)),num2str(configNos(i)-1));
end
title('Config ID numbers (not file numbers)')
fprintf('Remember: send config to chip!\n');

%% GENERATE LOOKUP AND CONFIG TABLES
[flistFileNameID flist flistName] = wrapper.proc_and_spikesort_save_data( )
runNo = input('Enter run no >> ');
flistName = sprintf('flist_wn_checkerboard_n_%02d',runNo);
flist = {}; eval(flistName);
suffixName = strrep(flistName,'flist', '');
flistFileNameID = get_flist_file_id(flist{1}, suffixName);
dirNameFFile = strcat('../analysed_data/',   flistFileNameID);
dirNameSt = strcat('../analysed_data/',   flistFileNameID,'/03_Neuron_Selection/');
dirNameEl = strcat('../analysed_data/',   flistFileNameID,'/01_Pre_Spikesorting/');
dirNameCl = strcat('../analysed_data/',   flistFileNameID,'/02_Post_Spikesorting/')

sortChoice = input('spikesort? [y/n]','s')
if strcmp(sortChoice,'y')
    fileType = 'mat';
    elNumbers = compare_files_between_dirs(dirNameEl, dirNameCl, fileType, flist)
    selInds = input(sprintf('sel inds of el numbers to sort [1:%d]> ',length(elNumbers)));
    sort_ums_output(flist, 'add_dir_suffix',suffixName, 'sel_els_in_dir', ...
        elNumbers(selInds), 'specify_output_dir', flistFileNameID)%elNumbers([1:10]+10*(segmentNo-1))); %'sel_els_in_dir',...
%     selEls(end));%'all_in_dir')%;% 'all_in_dir')%); %,
end
%% EXTRACT TIME STAMPS FROM SORTED FILES 

% auto: create st_ files & create neuronIndList.mat file with names of all
% ...neurons found.
extract_spiketimes_from_cl_files(flist, 'add_dir_suffix',suffixName )
%% get heatmap
% produces heatmaps

tsMatrix = load_spiketrains(flistFileNameID);
binWidthMs =0.1;
[heatMap] = get_heatmap_of_matching_ts2(binWidthMs, tsMatrix);
figure, imagesc(heatMap);
save(fullfile(dirNameFFile,'heatMap.mat'), 'heatMap')
%% FIND REDUNDANT CLUSTERS
% [sortedRedundantClusterGroupsInds redundantClusterGroupsInds ] = find_redundant_clusters(tsMatrix, heatMap, ...
%     'bin_width', 0.5,'matching_thresh',0.40 ); % 2012-08-12 was threshold of 30% 

% SELECT UNIQUE AND BEST NEURONS
% This function plots all of the neuron spike trains for the unique neurons
fileNo = 1;
[selNeuronInds outputGroups] = find_unique_neurons2(tsMatrix, ...
    heatMap, 'matching_thresh',0.2 )
% look at el numbers
% elNumbers= unique(extract_el_numbers_from_files(  strcat('../analysed_data/',   flistFileNameID,'/03_Neuron_Selection/'), ...
%     'st_*', flist, 'sel_inds',  selNeuronInds  ))%sortedRedundantClusterGroupsInds{1} )

%% get frameno info
close all
framenoName = strcat('frameno_', flistFileNameID,'.mat');
if ~exist(fullfile(dirNameFFile,framenoName))
    frameno = get_framenos(flist, 2e4*60*20);
    save(fullfile(dirNameFFile,framenoName),'frameno');
else
    load(fullfile(dirNameFFile,framenoName)); frameInd = single(frameno);
end

% get file names
fileNames = dir(strcat(dirNameSt,'*.mat'));

load white_noise_frames.mat
edgePix = 12;
white_noise_frames = white_noise_frames(1:edgePix,1:edgePix,:);
dirSTA = strrep(strrep(dirNameSt,'analysed_data', 'Figs'),'03_Neuron_Selection/','');
mkdir(dirSTA)

%% get el pos
profData.flist = flist;
ntk2 = load_ntk2_data(profData.flist,1)
profData.elConfigCtrXY = [mean(ntk2.x) mean(ntk2.y)];

%% plot the STA response with frames
numSquaresOnEdge = [12 12];
iMaxTimeSTACalcTime = [20];
maxTimeSTACalcTime = 15;
trackFileNo = [];
for    iFileNo = 1:length(fileNames)
    maxTimeSTACalcTime = iMaxTimeSTACalcTime;
    load(fullfile(dirNameSt, fileNames(iFileNo).name));
    clusNoLoc(1) = strfind(fileNames(iFileNo).name, 'n')+1;
    clusNoLoc(2)= strfind(fileNames(iFileNo).name, '.mat')-1;
    eval([  'spikeTimes = ',fileNames(iFileNo).name(1:end-4),'.ts*2e4;']);
    spikeTimes(spikeTimes > maxTimeSTACalcTime*2e4*60) = [];
    profData.stSel = round(spikeTimes);
    
    [profData.staFrames profData.staTemporalPlot profData.plotInfo...
        profData.bestSTAInd h] =...
        ifunc.sta.make_sta( profData.stSel, ...
        white_noise_frames(1:numSquaresOnEdge(1),1:numSquaresOnEdge,:), ...
        frameno,'do_print')
    title(sprintf('WN Checkerboard (%s)', ...
        strrep(fileNames(iFileNo).name,'.mat','')),'Interpreter','none');
    plotDir = '../Figs/';
    fileName = sprintf('%s_sta_%s_clus_%s', ...
        get_dir_date, suffixName(2:end), ...
        strrep(strrep(fileNames(iFileNo).name,'.mat',''),'st_',''));
    doSave = input('Save? [y/n]', 's');
    
    if strcmp(doSave,'y')
        save.save_plot_to_file(plotDir, fileName, 'eps');
        save.save_plot_to_file(plotDir, fileName, 'fig');

        trackFileNo(end+1) = iFileNo;
        
    elseif strcmp(doSave,'q')
        return;
    end
    commandwindow
    close(h)
end
save(sprintf('trackFileNo_%s_sta_%s.mat', get_dir_date, suffixName(2:end)),'trackFileNo')
%% plot specific RF
trackFileNo
fileNo = input('file # ');
maxTimeSTACalcTime = iMaxTimeSTACalcTime;
load(fullfile(dirNameSt, fileNames(fileNo).name));
clusNoLoc(1) = strfind(fileNames(fileNo).name, 'n')+1;
clusNoLoc(2)= strfind(fileNames(fileNo).name, '.mat')-1;
profData.clusNo = str2num(fileNames(fileNo).name(clusNoLoc(1):clusNoLoc(2)));

ctrElidxNoLoc(1) = strfind(fileNames(fileNo).name, 'st_')+3;
ctrElidxNoLoc(2)= strfind(fileNames(fileNo).name, 'n')-1;
profData.ctrElidx = str2num(fileNames(fileNo).name(ctrElidxNoLoc(1):ctrElidxNoLoc(2)));

eval([  'spikeTimes = ',fileNames(fileNo).name(1:end-4),'.ts*2e4;']);
spikeTimes(spikeTimes > maxTimeSTACalcTime*2e4*60) = [];
profData.stSel = spikeTimes;

[profData.staFrames profData.staTemporalPlot profData.plotInfo profData.bestSTAInd h] =...
    ifunc.sta.make_sta( profData.stSel, ...
    white_noise_frames(1:numSquaresOnEdge(1),1:numSquaresOnEdge,:), ...
    frameno,'do_print')
title(sprintf('WN Checkerboard (cluster %d)',profData.clusNo));



maxTimeSTACalcTime = iMaxTimeSTACalcTime;
load(fullfile(dirNameSt, fileNames(fileNo).name));
clusNoLoc(1) = strfind(fileNames(fileNo).name, 'n')+1;
clusNoLoc(2)= strfind(fileNames(fileNo).name, '.mat')-1;
profData.clusNo = str2num(fileNames(fileNo).name(clusNoLoc(1):clusNoLoc(2)));
fprintf('Cluster # %d.\n',profData.clusNo )
eval([  'spikeTimes = ',fileNames(fileNo).name(1:end-4),'.ts*2e4;']);
spikeTimes(spikeTimes > maxTimeSTACalcTime*2e4*60) = [];
profData.stSel = spikeTimes;

profData.umToPx = 1.6;
profData.squareSizeUm = 75; 
edgeLengthPx = profData.squareSizeUm*numSquaresOnEdge;
% plot image
figure
gui.plot_hidens_els, hold on;
profData.stimPlotLims{1} = [profData.elConfigCtrXY(1)-edgeLengthPx/2 profData.elConfigCtrXY(1)+edgeLengthPx/2];
profData.stimPlotLims{2} = [profData.elConfigCtrXY(2)-edgeLengthPx/2 profData.elConfigCtrXY(2)+edgeLengthPx/2];
staIm = profData.staFrames(:,:,profData.bestSTAInd);

staImAdj = beamer.beamer2array_mat_adjustment(staIm);
profData.staImAdjRGB = im.mat2rgb(staImAdj);
subimage(profData.stimPlotLims{1}, profData.stimPlotLims{2},profData.staImAdjRGB) 

% plot footprint
% plot_footprints_simple([out.neurons{neurInd}.x' out.neurons{neurInd}.y'], ...
%     out.neurons{neurInd}.template.data', ...
%         'input_templates','hide_els_plot','format_for_neurorouter',...
%         'plot_color','k', 'flip_templates_ud', 'flip_templates_lr','scale', 55, ...
%         'line_width',2);

plotDir = '../Figs/';
fileName = sprintf('%s_checkerboard_rf_%s', get_dir_date, strrep(strrep(fileNames(fileNo).name,'st_',''),'.mat',''));
% plot.plot_peak2peak_amplitudes(out.neurons{neurInd}.template.data', ...
%     out.neurons{neurInd}.x,out.neurons{neurInd}.y);
save.save_plot_to_file(plotDir, fileName, 'eps'); 
save.save_plot_to_file(plotDir, fileName, 'fig');




% Select the center of the RF
all_els=hidens_get_all_electrodes(2);
% configNum = input('Enter config#');
% configIndNum = configNum+1; %because file names start at 0;
arrayCtrXY = [mean(unique(all_els.x)) mean(unique(all_els.y))]; 


junk = input('Ready to select center of receptive field? [press enter]: ')


centerLocation = ginput(1);
profData.rfTrueCtr.x = centerLocation(1);profData.rfTrueCtr.y = ...
    centerLocation(2);
profData.rfRelCtr.x = round(centerLocation(1)-mean(ntk2.x));
profData.rfRelCtr.y = round(mean(ntk2.y)-centerLocation(2));

fprintf('Move rel. to center of config: [%3.0f %3.0f]\n', ...
    profData.rfRelCtr.x,profData.rfRelCtr.y  );
fprintf('Selected xy coord: [%5.0f %5.0f]\n', centerLocation(1), ...
    centerLocation(2))
fprintf('File name: %s.\n', fileNames(fileNo).name);
fprintf('file #: %d.\n',fileNo);
wnCheckBrdRunNo ='';
wnCheckBrdRunNo = input('Enter stim run no to save (if you want to save) >> ');
if ~isempty(wnCheckBrdRunNo)
    wnCheckBrdPosDataFileName = sprintf('wnCheckBrdPosData_%02d.mat', wnCheckBrdRunNo);
    if exist(wnCheckBrdPosDataFileName,'file')
        load( wnCheckBrdPosDataFileName )
    else
        wnCheckBrdPosData = {};
    end
    % select flist
%     flistFileNames = filenames.get_filenames('*ntk','../proc');
[fileIdx flistFileNames] = filenames.select_flist_name();
    wnCheckBrdPosData{end+1}.flist{1} = ['../proc/',flistFileNames(fileIdx).name];
    wnCheckBrdPosData{end}.fileNo = fileIdx;
    wnCheckBrdPosData{end}.fileName = strrep(strrep(flistFileNames(fileIdx).name,'st_',''),'.mat','');
    wnCheckBrdPosData{end}.rfAbsCtr = centerLocation;
    wnCheckBrdPosData{end}.rfRelCtr  = struct.xy2vec(profData.rfRelCtr);
    [wnCheckBrdPosData{end}.elIdxCtr wnCheckBrdPosData{end}.clusNo] = ...
        filenames.parse_cluster_name(wnCheckBrdPosData{end}.fileName);
    wnCheckBrdPosData{end}.runNo = wnCheckBrdRunNo;
    wnCheckBrdPosData{end}.stimType = 'wn_checkerboard'; 
    % save positional data
    save(wnCheckBrdPosDataFileName, 'wnCheckBrdPosData');
    
    h1 = figure; hold on, axis square
    imagesc(profData.staImAdjRGB),pause(0.1);
    neurName = strrep(strrep(fileNames(fileNo).name,'st_',''),'.mat','');
    fileName = sprintf('%s_best_frame_checkerboard_rf_%s', get_dir_date, ...
        strrep(strrep(fileNames(fileNo).name,'st_',''),'.mat',''));
    save.save_plot_to_file(plotDir, fileName, 'fig');
    % close(h1)
    fprintf('File saved.\n');
end

%% save data
out = {};
neuronName = sprintf('run_%02d_%s', runNo, neurName);
neurInd=1;
while profData.clusNo ~= out.neurons{neurInd}.cluster_no
    neurInd=neurInd+1;
end
if profData.clusNo == out.neurons{neurInd}.cluster_no
    stimName = 'wn_checkerboard';
    fieldData = {} ;
    fieldData = {...
        'sta_frames', profData.staFrames};
    profiles.save_to_profiles_file(neuronName, stimName, [], [],...
        'add_struct_fields',out.neurons{neurInd})
    profiles.save_to_profiles_file(neuronName, stimName, [], [],...
        'add_struct_fields',profData);
    for i=1:2:length(fieldData)
        % profiles.save_to_profiles_file(neuronName, selField, selSubField, dataToAdd)
       
        profiles.save_to_profiles_file(neuronName, stimName, ...
            fieldData{i}, fieldData{i+1})
    end
else
    fprintf('Error.\n')
end


%% plot footprints
fileNames = dir(strcat(dirNameSt,'*.mat'));
figure, gui.plot_hidens_els('marker_style', 'cx'), hold on
textprogressbar('')

 colorMap = jet;
 colorMap = colorMap(10:end,:);
 numPlotColors =length(selNeuronInds);
 colorIndSpacing = floor(length(colorMap)/numPlotColors);
 colorInds = [1:colorIndSpacing:numPlotColors*colorIndSpacing];
 
 iColor = 1;
%  textprogressbar('plotting footprints');
for i=selNeuronInds
   
    %     fprintf('File %d\n',i);
   
    % get cluster id
    prefixLoc = strfind(fileNames(i).name,'_');
    clusterID = fileNames(i).name(prefixLoc+1:end-4)
    [elNo clusterNo] = parse_cluster_id(clusterID, 'number');
    
    % load cluster file
    load(fullfile(dirNameCl, strcat('cl_',num2str(elNo),'.mat')));
    
    eval([  'spikes = ',strcat('cl_',num2str(elNo)),';'])
                                              
    plot_footprints(spikes,clusterNo, elConfigInfo, 'plot_type', 'multiple', ...
        'plot_color', colorMap(colorInds(iColor),:));
    
    eval(['clear ',strcat('cl_',num2str(elNo))])
    clear spikes
    iColor = iColor+1;
%     junk = input('press enter> ')
%     textprogressbar(100*iColor/length(colorMap));
end
%  textprogressbar('end');

title('White Noise Checkerboard')
titleexclude(strcat('Footprints from ', suffixName));selectedPatchesExclusive

