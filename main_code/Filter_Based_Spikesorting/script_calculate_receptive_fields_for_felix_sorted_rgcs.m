% script to calculate receptive fields for felix-sorted (filter-based)
% spikes


%% GENERATE LOOKUP AND CONFIG TABLES
% get electrode configuration file data: ELCONFIGINFO
% the ELCONFIGINFO file has x,y coords and electrode numbers
% ---------- Settings ----------
numEls = 7;
% suffixName = '_orig_stat_surr';
flistName = 'flist_white_noise_050';
suffixName = strrep(flistName ,'flist','');
[ suffixName flist flistFileNameID dirNameFFile  dirName.St ...
    dirName.El dirName.Cl ] = setup_for_ntk_data_loading_fe(flistName, suffixName,get_dir_date)
elConfigClusterType = 'overlapping'; elConfigInfo = get_el_pos_from_nrk2_file;

%% look for unprocessed electrodes
[elNumbers ] = compare_els_between_dir_elconfiginfo(elConfigInfo,dirName.El , ...
    '*.mat', flist);
selElNumbers = elNumbers;
pre_process_data(suffixName, flistName, 'config_type','overlapping', 'sel_by_els',selElNumbers);
%% SUPERVISED SORTING (MANUAL) - create the cl_ files
% [elNumbers ] = compare_els_between_dir_elconfiginfo(elConfigInfo,dirName.El , ...
%    '*.mat', flist);
fileType = 'mat';
elNumbers = compare_files_between_dirs(dirName.El, dirName.Cl, fileType, flist)
sort_ums_output(flist, 'add_dir_suffix',suffixName, 'sel_els_in_dir', elNumbers(57:84))%elNumbers([1:10]+10*(segmentNo-1))); %'sel_els_in_dir', selEls(end));%'all_in_dir')%;% 'all_in_dir')%); %,
%% REVIEW CLUSTERS
selEls = 6275;
review_clusters(flist,'add_dir_suffix', suffixName,'sel_els', selEls);%'all_in_dir'); %'sel_els', 5772, 'sel_in_dir', 12

%% EXTRACT TIME STAMPS FROM SORTED FILES
% auto: create st_ files & create neuronIndList.mat file with names of all
% ...neurons found.
extract_spiketimes_from_cl_files(flist, 'add_dir_suffix',suffixName )

%% get heatmap
% produces heatmaps
tsMatrix = load_spiketrains(flistFileNameID);
binWidthMs =0.1;
loadHeatmap = 1
if exist(fullfile(dirNameFFile,'heatMap.mat'))
    load(fullfile(dirNameFFile,'heatMap.mat'))
else
    [heatMap] = get_heatmap_of_matching_ts2(binWidthMs, tsMatrix  );
    save(fullfile(dirNameFFile,'heatMap.mat'), 'heatMap')
end
figure, imagesc(heatMap);

%% FIND REDUNDANT CLUSTERS
% [sortedRedundantClusterGroupsInds redundantClusterGroupsInds ] = find_redundant_clusters(tsMatrix, heatMap, ...
%     'bin_width', 0.5,'matching_thresh',0.40 ); % 2012-08-12 was threshold of 30%

fileNo = 1;
[selNeuronInds outputGroups] = find_unique_neurons2(tsMatrix, ...
    heatMap, 'matching_thresh',0.2 )

%% plot waveforms for later identification
neuronNames = get_neur_names_from_dir(dirName.St, 'st_');
plot_selected_neuron_waveforms(dirName.Cl, neuronNames)
dirFigsOutput = strrep(dirNameFFile,'analysed_data', 'Figs');
figure(6)
exportfig(gcf, fullfile(dirFigsOutput,strcat('Selected_Neurons_Waveforms','.ps')) ,'Resolution', 120,'Color', 'cmyk')
figure(2)
exportfig(gcf, fullfile(dirFigsOutput,strcat('Selected_Neurons_Waveforms2','.ps')) ,'Resolution', 120,'Color', 'cmyk')

%% NEURON DATA QUALITY SHEETS
clusterNameCore = '6376n3';
plot_quality_datasheet_from_cluster_name(flist, suffixName, clusterNameCore, 'file_save', 1 )

%% get inds
elNumbers = {  '5548n11'};
selNeuronInds = get_file_inds_from_el_numbers(dirName.St, '*.mat', elNumbers);
%% convert felix's sorting to my format

acqRate = 2e4;
neurons = {};
for i=1:length(rgcs)
    % get neuron Labels
    neuronLabels = sort(unique(rgcs{i}.spikes.labels(:,1)))';
    % remove labels that aren't 2 (green)
    neuronLabels(find(rgcs{i}.spikes.labels(:,2)~=2)) = [];
        
    for j=1:length(neuronLabels)
        
        % get spike indices
        indsSpikesCurrNeur = find(rgcs{i}.spikes.assigns==neuronLabels(j));
        
        neurons{end+1}.spiketimes = rgcs{i}.spikes.spiketimes(indsSpikesCurrNeur);
        neurons{end}.sortgroup = i;
        neurons{end}.label = j;
        
    end
end

%% Calculate STA info
close all
% set dirs
cd /home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/13Dec2012_2/Matlab
dataDir = strcat('../analysed_data/', flistFileNameID,'/STA_Data_felix_filter/');
figDir = strcat('../analysed_data/', flistFileNameID,'/STA_Data_felix_filter/');
%mkdirs
mkdir(dataDir), mkdir(figDir)
% load framenos
load(fullfile(dirNameFFile,strcat('frameno_', flistFileNameID,'.mat'))); frameInd = single(frameno);
% load frame images
load StimCode/white_noise_frames.mat

for j=1:length(neurons)
    
                try
            neuronName = strcat('neur_',num2str(j));
            staOut = white_noise_reverse_correlation_simple_3( round(neurons{j}.spiketimes*2e4), white_noise_frames, ...
                frameInd, ...
                'neuron_name', neuronName, 'flist_name', flistFileNameID, ...
                'data_dir', dataDir, 'output_dir', figDir); %
            
                end
           
end
% textprogressbar(' done');
% load ntk data
flist = {};
eval(flistName)
%% initialize and load

timeToLoadMins = 4;
 ntk=initialize_ntkstruct(flist{1},'hpf', 500, 'lpf', 3000);
[ntk2 ntk]=ntk_load(ntk, timeToLoadMins*60*2e4, 'images_v1');

%% plot STA key figures
acqRate = 2e4;
doPrint = 1;
setSpacing = 0.013;
setPadding = 0.013;
setMargin = 0.1;
% dir info
dataDir = strcat('../analysed_data/', flistFileNameID,'/STA_Data_felix_filter/');
figsDir = strcat('../analysed_data/', flistFileNameID,'/STA_Data_felix_filter/'); mkdir(figsDir);
fileNamesTemporalPlot = dir(fullfile(dataDir, 'staTemporal*.mat'));
fileNamesStaFrames = dir(fullfile(dataDir, '*staFrames*.mat'));
rowsPerWindow= 4;
numCols = 4;
numWindows = ceil(length(neurons)/rowsPerWindow);
% winInds =   repmat([1:numWindows],rowsPerWindow,1);
% winInds = reshape(winInds,1,numel(winInds)); % indices for windowws
rowInds = repmat([1:rowsPerWindow],1,numWindows);
scrsz = get(0,'ScreenSize');% [left bottom width height]
load(fullfile(dataDir, 'plotInfo.mat'));
dirCurr = pwd;
dateValLoc = strfind(dirCurr,'/');
dataVal = dirCurr(dateValLoc(end-1)+1:dateValLoc(end)-1);
numFiles = length(fileNamesTemporalPlot);
figCounter = 0;
structName = {};
maxAmpEls = zeros(1,numFiles);
fileNames = dir(strcat(dirName.St,'*.mat'));

% get all the els that have the max amplitudes for each neur
for iFile = 1:numFiles
    currNeur = load_profiles_file(fileNames(iFile).name);
    maxAmpEls(iFile) = currNeur.White_Noise.el_max_amp;
end

% sort them
[Y indSortMaxAmpEl ] = sort(maxAmpEls, 'ascend');

% rearrange the file names
for i=1:numFiles
    
    fileName{i} = fileNamesTemporalPlot(indSortMaxAmpEl(i)).name;
end

for iFile = 1:numFiles
    
    
    if  rowInds(iFile)==1
        figure('Position',[1 1 scrsz(3)/2 scrsz(4)])
        set(gcf, 'color', 'white')
    end
    load(fullfile(dataDir, fileName{iFile}));
    structName{iFile} = strrep(strrep(fileName{iFile},'staTemporalPlot_',''),'.mat','');
    
    rowNum = 1;
    subaxis(rowsPerWindow,numCols,(rowInds(iFile)-1)*4+rowNum , 'Holdaxis',0, ...
        'SpacingVertical',0.01,'SpacingHorizontal',0.01, ...
        'PaddingLeft',0.01,'PaddingRight',0.01,'PaddingTop',0.01,'PaddingBottom',0.01, ...
        'MarginLeft',0.12,'MarginRight',0.12,'MarginTop',.12,'MarginBottom',.12, ...
        'rows',[],'cols',[]);
  
    set(gca,'yDir','reverse');
    try
        plot(staTemporalPlot.x_axis, staTemporalPlot.STA,'LineWidth',2,'Color','k');  axis off
    end
    [junk indSTAFrMin] = min(staTemporalPlot.STA); indSTAFrMin = indSTAFrMin(1);
    [junk indSTAFrMax] = max(staTemporalPlot.STA); indSTAFrMax = indSTAFrMax(1);
    
    title(strcat([strrep(dataVal,'_','-'), ' | ', strrep(structName{iFile},'_','-')], '(', num2str(iFile),')'), 'FontSize',15)
    load(fullfile(figsDir, fileNamesStaFrames(iFile).name));
    rowNum = 2;
    %     subplot(rowsPerWindow,numCols,(rowInds(iFile)-1)*4+rowNum )
     subaxis(rowsPerWindow,numCols,(rowInds(iFile)-1)*4+rowNum , 'Holdaxis',0, ...
        'SpacingVertical',0.01,'SpacingHorizontal',0.01, ...
        'PaddingLeft',0.01,'PaddingRight',0.01,'PaddingTop',0.01,'PaddingBottom',0.01, ...
        'MarginLeft',0.12,'MarginRight',0.12,'MarginTop',.12,'MarginBottom',.12, ...
        'rows',[],'cols',[]);
    selIm = staFrames(:,:,indSTAFrMin); selIm = (imrotate(flipud(selIm),-90));
    imagesc(selIm); axis square, axis off, hold on
    circle([plotInfo.imWidth/2 plotInfo.imWidth/2],(plotInfo.imWidth*plotInfo.apertureDiam/plotInfo.stimWidth)/2,plotInfo.imWidth,'k--',2);
    
    rowNum = 3;
    selIm = staFrames(:,:,indSTAFrMax); selIm = (imrotate(flipud(selIm),-90));
    %     subplot(rowsPerWindow,numCols,(rowInds(iFile)-1)*4+rowNum ),
     subaxis(rowsPerWindow,numCols,(rowInds(iFile)-1)*4+rowNum , 'Holdaxis',0, ...
        'SpacingVertical',0.01,'SpacingHorizontal',0.01, ...
        'PaddingLeft',0.01,'PaddingRight',0.01,'PaddingTop',0.01,'PaddingBottom',0.01, ...
        'MarginLeft',0.12,'MarginRight',0.12,'MarginTop',.12,'MarginBottom',.12, ...
        'rows',[],'cols',[]);
    imagesc(selIm); axis square, axis off, hold on
    circle([plotInfo.imWidth/2 plotInfo.imWidth/2],(plotInfo.imWidth*plotInfo.apertureDiam/plotInfo.stimWidth)/2,plotInfo.imWidth,'k--',2);
    
    rowNum = 4;
    stFileName = strrep(fileName{iFile},'staTemporalPlot', 'st');
%     load(fullfile(dirName.St, stFileName));
    spikeTimes = neurons{iFile}.spiketimes;
    %     subplot(rowsPerWindow,numCols,(rowInds(iFile)-1)*4+rowNum )
     subaxis(rowsPerWindow,numCols,(rowInds(iFile)-1)*4+rowNum , 'Holdaxis',0, ...
        'SpacingVertical',0.01,'SpacingHorizontal',0.01, ...
        'PaddingLeft',0.01,'PaddingRight',0.01,'PaddingTop',0.01,'PaddingBottom',0.01, ...
        'MarginLeft',0.12,'MarginRight',0.12,'MarginTop',.12,'MarginBottom',.12, ...
        'rows',[],'cols',[]);
    try
        data = extract_waveforms_from_ntk2(ntk2, spikeTimes );
        
        numSpikes = size(data.waveform,1);
        %     currElNo = str2num(structName{iFile}(1:4));
        %     indMainEl = find(data.el_idx(11:118) == currElNo);
        
        waveformFootprintData{iFile} = mean(data.waveform,1);
        clear ppAmps elCoordsX elCoordsY
        [ppAmps elCoordsX elCoordsY] = plot_footprints_all_els(  elConfigInfo, data, 'sel_ch_inds',[11:118],'line_width', 1, 'scale', 3.5 );
        %     ppAmpMainEl = ppAmps(indMainEl);
        hold on
        indsSigEls = find(ppAmps>max(ppAmps)*0.5);
        ctrMassX(iFile) = sum(ppAmps(indsSigEls).*elCoordsX(indsSigEls))/sum(ppAmps(indsSigEls));
        ctrMassY(iFile) = sum(ppAmps(indsSigEls).*elCoordsY(indsSigEls))/sum(ppAmps(indsSigEls));
        plot(ctrMassX(iFile), ctrMassY(iFile),'r+','linewidth', 3);
        %     title(strcat(['(', num2str(iFile),') Amp=', num2str(ppAmpMainEl),' n=',num2str(numSpikes)]), 'FontSize',15)
        clear data
    end
    if  rowInds(iFile)==rowsPerWindow
        figCounter = figCounter+1;
        if doPrint
            exportfig(gcf, fullfile(figsDir, strcat('sta_key_figs_',num2str(figCounter))) ,'Resolution', 120,'Color', 'cmyk')
        end
    end
end

%% compare difference of footprints
outputMat = compare_waveforms(waveformFootprintData);
outputMat = outputMat/max(max(outputMat));
figure, imagesc(outputMat);
outputMat2 = outputMat;
outputMat2(find(outputMat2==0))=1;
for i=1:length(outputMat2)
    outputMat2(i,i) = 0;
end
matchingGps = find_similar_groups(outputMat2, '<', 0.10);

%% compare center of mass
distMat = compare_centers_of_mass(ctrMassX, ctrMassY);
threshOperator = '<';
selThreshold = 3;
matchingGps = find_similar_groups(distMat, selThreshold, threshOperator);
fName = 'Possible_Duplicates.txt';         %# A file name
fid = fopen(fullfile(dataDir,fName),'w'); %# Open the file
fprintf(fid, 'Date: %s\n\n', dataVal);
for i=1:length(matchingGps)
    for j=1:length(matchingGps{i})
        fprintf(fid, '%s (%d), ', structName{matchingGps{i}(j)}, matchingGps{i}(j));
        fprintf('%s (%d), ', structName{matchingGps{i}(j)}, matchingGps{i}(j));
    end
    fprintf(fid, '\n');
    fprintf('\n');
end
fclose(fid);

%% plot footprints
fileNames = dir(strcat(dirName.St,'*.mat'));
figure, hold on
textprogressbar('')

colorMap = jet;
colorMap = colorMap(10:end,:);
numPlotColors =length(selNeuronInds);
colorIndSpacing = ceil(length(colorMap)/numPlotColors);
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
    load(fullfile(dirName.Cl, strcat('cl_',num2str(elNo),'.mat')));
    
    eval([  'spikes = ',strcat('cl_',num2str(elNo)),';'])
    
    
    
    plot_footprints(spikes,clusterNo, elConfigInfo, 'plot_type', 'multiple', ...
        'plot_color', colorMap(colorInds(iColor),:));
    
    eval(['clear ',strcat('cl_',num2str(elNo))])
    clear spikes
    iColor = iColor+1;
    %     textprogressbar(100*iColor/length(colorMap));
end
%  textprogressbar('end');

title('White Noise Checkerboard')
titleexclude(strcat('Footprints from ', suffixName));selectedPatchesExclusive

