%% Initial setup to run analysis
acqFreq = 2e4;
flistName = 'flist_white_noise_checkerboard';
dirName.figs = '../Figs/';
dirName.sta = strcat('../analysed_data/responses/sta/'); mkdir(dirName.sta);
suffixName = strrep(flistName ,'flist','');
[ suffixName flist flistFileNameID dirName.gp  dirName.st ...
    dirName.el dirName.cl ] = setup_for_ntk_data_loading(flistName, suffixName);
tName = strrep(flistFileNameID,suffixName,'');
elConfigClusterType = 'overlapping'; elConfigInfo = get_el_pos_from_nrk2_file;
elConfigInfo = add_ntk2_el_list_order_to_elconfiginfo(flist, elConfigInfo);
save('elConfigInfo.mat', 'elConfigInfo');
stimNames = {'White_Noise', 'Orig_Movie', 'Static_Median_Surround', ...
    'Dynamic_Median_Surround',  'Dynamic_Median_Surround_Shuffled', ...
    'Pixelated_Surround_10_Percent', 'Pixelated_Surround_50_Percent', ...
    'Pixelated_Surround_90_Percent', 'Dots_of_Different_Sizes',...
    'Moving_Bars'};


dirName.base_net = strcat('/net/bs-filesvr01/export/group/hierlemann/recordings/', ...
    'HiDens/SpikeSorting/Roska/',get_dir_date,'/');
streamName = dir(fullfile(dirName.base_net, strcat('*',tName,'*stream')));   
dirName.auto_sorter_gps = fullfile(dirName.base_net,streamName(1).name,'sortings/')
dirName.prof = '../analysed_data/profiles';
dirName.prof_wn = strcat(dirName.prof,'/White_Noise/');
dirName.qds = strcat(dirName.figs, 'White_Noise/quality_datasheets/');mkdir(dirName.qds)
%%
% Prepare H5 File Access
h5File = strrep(strrep(flist,'../proc/',''),'ntk','h5');
h5File = h5File{1};
dateVal = get_dir_date
hdmea = ifunc.h5.prepare_h5_file_access(dateVal, h5File);

%% create frameno file
% to do later: function create frameno file
shift_and_save_frameno_info(flistFileNameID);
% extract spike times
extract_spiketimes_from_auto_cluster_files( flistFileNameID, dirName.auto_sorter_gps)
%>> Calculate STA info
neurNames = extract_neur_names_from_files(dirName.st,'*_00*.mat');
[framenoInfo] = get_frameno_info(flistFileNameID );
% ifunc.sta.calc_and_save_sta(dirName, neurNames , flistFileNameID, hdmea, frameno, ...
%     'save_footprint',1,'use_sep_dir', 'White_Noise');

%% do init processing
ifunc.auto_run.initial_neuron_processing('flist_white_noise_050','White_Noise', [], [])

%% get list of footprint matches
dirName.profiles{1} = '../analysed_data/profiles/White_Noise/';
% load(fullfile(dirName.profiles{1},'neurNames')); 

neurNamesList{1} = neurNames;
dirName.profiles{2} = dirName.profiles{1} ; neurNamesList{2} = neurNamesList{1};
stimNames = {'white_noise_checkerboard', 'white_noise_checkerboard'}
[listMatches reverseMatExpNorm outputMat medianFootprints neurNames]  = ...
    ifunc.footprints.compute_footprint_similarity_for_two_groups(neurNamesList, stimNames)
%% plot STA key figures (modified)
neurNames = extract_neur_names_from_files(dirName.prof_wn ,'*_00*.mat');
selNeuronInds = 1:length(neurNames);
% plot waveforms
allEls = 1:size(hdmea,2);
for i=1
load notIncludedEls 
allElsToPlot = 1:size(hdmea,2);
allElsToPlot(notIncludedEls) = [];

doPrint = 1;
setSpacing = 0.013;
setPadding = 0.013;
setMargin = 0.1;

rowsPerWindow= 4;
numCols = 4;
numWindows = ceil(length(length(neurNames))/rowsPerWindow);
% winInds =   repmat([1:numWindows],rowsPerWindow,1);
% winInds = reshape(winInds,1,numel(winInds)); % indices for windowws
rowInds = repmat([1:rowsPerWindow],1,numWindows);
scrsz = get(0,'ScreenSize');% [left bottom width height]
dirCurr = pwd;
dateValLoc = strfind(dirCurr,'/');
dataVal = dirCurr(dateValLoc(end-1)+1:dateValLoc(end)-1);
numFiles = length(neurNames);
figCounter = 0;
structName = {};
numNeurs = length(neurNames);
end
errorInds = [];
for iNeur = 1:length(neurNames)%length(selNeuronInds)
    tic
    try
    if exist('data')
        clear data
    end
    % neuron name
    currNeuronName = neurNames{selNeuronInds(iNeur)};
    % set up fig
    h=figure('Position',[1 1 scrsz(3)/2 scrsz(4)]);
    set(gcf, 'color', 'white')
    % load profile data
    data = load_profiles_file(currNeuronName,'use_sep_dir','White_Noise')
    
    currSubplot = 1;
    subaxis(3,3,currSubplot, 'Holdaxis',0, ...
        'SpacingVertical',0.01,'SpacingHorizontal',0.01, ...
        'PaddingLeft',0.01,'PaddingRight',0.01,'PaddingTop',0.01,'PaddingBottom',0.01, ...
        'MarginLeft',0.12,'MarginRight',0.12,'MarginTop',.12,'MarginBottom',.12, ...
        'rows',[],'cols',[]);
    
    set(gca,'yDir','reverse');
    try % plot the sta data
        plot((data.White_Noise.sta_temporal_plot.x_axis/acqFreq)*1e3, data.White_Noise.sta_temporal_plot.staIms, ...
            'LineWidth',2,'Color','k');  axis off
        axis on
        xlabel('Time Preceeding and Following Spike (msec)')
        ylabel('Brightness')
    end
    % get min and max indices for sta frames
    [junk indSTAFrMin] = min(data.White_Noise.sta_temporal_plot.staIms); indSTAFrMin = indSTAFrMin(1);
    [junk indSTAFrMax] = max(data.White_Noise.sta_temporal_plot.staIms); indSTAFrMax = indSTAFrMax(1);
    % title
    title(strcat([strrep(dataVal,'_','-'), ' | ', currNeuronName], '(', num2str(selNeuronInds(iNeur)),')'), 'FontSize',15)
    spikes = ifunc.file.load_field_of_file(dirName.auto_sorter_gps, currNeuronName(2:4), 'spikes', ...
        'suffix', 'Export4UMS2000');
    
    % plot waveforms
    currSubplot = currSubplot+1;
    spikeTimes = data.White_Noise.spiketimes;
    subaxis(3,3,currSubplot , 'Holdaxis',0, ...
        'SpacingVertical',0.01,'SpacingHorizontal',0.01, ...
        'PaddingLeft',0.01,'PaddingRight',0.01,'PaddingTop',0.01,'PaddingBottom',0.01, ...
        'MarginLeft',0.12,'MarginRight',0.12,'MarginTop',.12,'MarginBottom',.12, ...
        'rows',[],'cols',[]);
    
    
    clusterNum = get_cluster_num(currNeuronName);
    plot_waveforms(spikes,clusterNum);
    
    %put here
    currSubplot = currSubplot+1;
    
    spikeTimes = data.White_Noise.spiketimes;
    AxesHandle = subaxis(3,3,currSubplot , 'Holdaxis',0, ...
        'SpacingVertical',0.01,'SpacingHorizontal',0.01, ...
        'PaddingLeft',0.01,'PaddingRight',0.01,'PaddingTop',0.01,'PaddingBottom',0.01, ...
        'MarginLeft',0.12,'MarginRight',0.12,'MarginTop',.12,'MarginBottom',.12, ...
        'rows',[],'cols',[]);
    
    clear ppAmps elCoordsX elCoordsY

    mysort.plot.waveforms2D_2(data.White_Noise.footprint_median, hdmea.MultiElectrode.electrodePositions,...
        'plotMedian', 1,...
        'maxWaveforms', 5000, ...
        'plotElNumbers', allEls, ...%         'plotHorizontal', idxMaxAmp, ...
        'plotSelIdx', allElsToPlot,'AxesHandle',AxesHandle, ...
        'fontSize', 7)
   
  
    currSubplot = currSubplot+1;
    subaxis(3,3,currSubplot , 'Holdaxis',0, ...
        'SpacingVertical',0.01,'SpacingHorizontal',0.01, ...
        'PaddingLeft',0.01,'PaddingRight',0.01,'PaddingTop',0.01,'PaddingBottom',0.01, ...
        'MarginLeft',0.12,'MarginRight',0.12,'MarginTop',.12,'MarginBottom',.12, ...
        'rows',[],'cols',[]);
    selIm = data.White_Noise.sta(:,:,indSTAFrMin); selIm = (imrotate(flipud(selIm),-90));
    imagesc(selIm); axis square, axis off, hold on
    circle([data.White_Noise.plot_info.imWidth/2 data.White_Noise.plot_info.imWidth/2],(data.White_Noise.plot_info.imWidth*data.White_Noise.plot_info.apertureDiam/data.White_Noise.plot_info.stimWidth)/2, ...
        data.White_Noise.plot_info.imWidth,'k--',2);
    
    currSubplot = currSubplot+1;
    selIm = data.White_Noise.sta(:,:,indSTAFrMax); selIm = (imrotate(flipud(selIm),-90));
    subaxis(3,3,currSubplot , 'Holdaxis',0, ...
        'SpacingVertical',0.01,'SpacingHorizontal',0.01, ...
        'PaddingLeft',0.01,'PaddingRight',0.01,'PaddingTop',0.01,'PaddingBottom',0.01, ...
        'MarginLeft',0.12,'MarginRight',0.12,'MarginTop',.12,'MarginBottom',.12, ...
        'rows',[],'cols',[]);
    imagesc(selIm); axis square, axis off, hold on
    circle([data.White_Noise.plot_info.imWidth/2 data.White_Noise.plot_info.imWidth/2],(data.White_Noise.plot_info.imWidth*data.White_Noise.plot_info.apertureDiam/data.White_Noise.plot_info.stimWidth)/2,data.White_Noise.plot_info.imWidth,'k--',2);
    
    
    
    
    % plot residuals
    currSubplot = currSubplot+1;
    spikeTimes = data.White_Noise.spiketimes;
    subaxis(3,3,currSubplot , 'Holdaxis',0, ...
        'SpacingVertical',0.01,'SpacingHorizontal',0.01, ...
        'PaddingLeft',0.01,'PaddingRight',0.01,'PaddingTop',0.01,'PaddingBottom',0.01, ...
        'MarginLeft',0.12,'MarginRight',0.12,'MarginTop',.12,'MarginBottom',.12, ...
        'rows',[],'cols',[]);
    
    
    
    plot_residuals(spikes,clusterNum);
    
    % plot plot_detection_criterion
    currSubplot = currSubplot+1;
    
    subaxis(3,3,currSubplot , 'Holdaxis',0, ...
        'SpacingVertical',0.01,'SpacingHorizontal',0.01, ...
        'PaddingLeft',0.01,'PaddingRight',0.01,'PaddingTop',0.01,'PaddingBottom',0.01, ...
        'MarginLeft',0.12,'MarginRight',0.12,'MarginTop',.12,'MarginBottom',.12, ...
        'rows',[],'cols',[]);
    
    plot_isi(spikes,clusterNum);
    
    % plot plot_detection_criterion
    currSubplot = currSubplot+1;
    subaxis(3,3,currSubplot , 'Holdaxis',0, ...
        'SpacingVertical',0.01,'SpacingHorizontal',0.01, ...
        'PaddingLeft',0.01,'PaddingRight',0.01,'PaddingTop',0.04,'PaddingBottom',0.01, ...
        'MarginLeft',0.12,'MarginRight',0.12,'MarginTop',.12,'MarginBottom',.12, ...
        'rows',[],'cols',[]);
    plot_detection_criterion(spikes,clusterNum);
    
    % plot plot_stability
    currSubplot = currSubplot+1;
    subaxis(3,3,currSubplot , 'Holdaxis',0, ...
        'SpacingVertical',0.01,'SpacingHorizontal',0.01, ...
        'PaddingLeft',0.01,'PaddingRight',0.01,'PaddingTop',0.04,'PaddingBottom',0.01, ...
        'MarginLeft',0.12,'MarginRight',0.12,'MarginTop',.12,'MarginBottom',.12, ...
        'rows',[],'cols',[]);
    plot_stability(spikes,clusterNum);
    dirName.staFigs = fullfile(dirName.figs, 'STA'); mkdir(dirName.staFigs )
    if doPrint
        
        exportfig(h, fullfile(dirName.qds, strcat('qds_',currNeuronName)) ,'Resolution', 120,'Color', 'cmyk')
        saveas(h, fullfile(dirName.qds, strcat('qds_',currNeuronName)),'fig');
    end
    
    
    fprintf('Error with %s\n', currNeuronName)
    
    %     close all
    toc
    catch
       errorInds(end+1) = iNeur; 
    end
    close all
    
    end

% save(fullfile(dataDir,'waveformFootprintData.mat'), 'waveformFootprintData')

%% sort filenames and add index prefix
dirName.sta_figs = '~/temp/run_felix4/'; %'../Figs/STA/';
% neurNames = neurNamesIan;
neurNames = extract_neur_names_from_files(dirName.sta_figs , '*.eps',...
    'remove_string', '.eps')
add_number_prefixes_to_filenames(dirName.sta_figs, neurNames, fileInds )
%
%% compare difference of footprints
for i=1:length(neurNames)
    data = load_profiles_file(neurNames{i});
    waveformFootprintData{i} = data.White_Noise.footprint.averaged;
end
outputMat = compare_waveforms(waveformFootprintData);
outputMat = outputMat/max(max(outputMat));
figure, imagesc(outputMat);
outputMat2 = outputMat;
outputMat2(find(outputMat2==0))=1;
for i=1:length(outputMat2)
    outputMat2(i,i) = 0;
end

%% Find similar groups
[matchingGps uniqueClusters] = find_similar_groups(outputMat2, '<', 0.1);
fName = 'Possible_Duplicates_Footprint_Comparison.txt';         %# A file name
fid = fopen(fullfile('',fName),'w'); %# Open the file
fprintf(fid, 'Possible duplicates footprint comparison - Date: %s\n\n', dataVal);
for i=1:length(matchingGps)
    for j=1:length(matchingGps{i})
        fprintf(fid, '%s (%d), ', neurNames{matchingGps{i}(j)}, matchingGps{i}(j));
        fprintf('%s (%d), ', neurNames{matchingGps{i}(j)}, matchingGps{i}(j));
    end
    fprintf(fid, '\n');
    fprintf('\n');
end
fclose(fid);
open(fullfile('',fName))

%% compare center of mass
distMat = compare_centers_of_mass(ctrMassX, ctrMassY);
threshOperator = '<';
selThreshold = 3;
matchingGps = find_similar_groups(distMat, threshOperator, selThreshold);
fName = 'Possible_Duplicates_Center_Mass_Method.txt';         %# A file name
fid = fopen(fullfile(dataDir,fName),'w'); %# Open the file
fprintf(fid, 'Possible duplicates center of mass comparison - Date: %s\n\n', dataVal);
for i=1:length(matchingGps)
    for j=1:length(matchingGps{i})
        fprintf(fid, '%s (%d), ', structName{matchingGps{i}(j)}, matchingGps{i}(j));
        fprintf('%s (%d), ', structName{matchingGps{i}(j)}, matchingGps{i}(j));
    end
    fprintf(fid, '\n');
    fprintf('\n');
end
fclose(fid);
open(fullfile(dataDir,fName))


