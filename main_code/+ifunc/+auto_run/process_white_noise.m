function process_white_noise(flistName, stimName, dateVal)

%%
flist ={}; eval(flistName);
suffixName = strrep(flistName ,'flist','');

[ suffixName flist flistFileNameID dirName.gp  dirName.st ...
    dirName.el dirName.cl ] = setup_for_ntk_data_loading(flistName, suffixName);


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
% extract_spiketimes_from_auto_cluster_files( flistFileNameID, dirName.felix_grouping)
%>> Calculate STA info

neurNames = get_neur_names_from_dir(dirName.st, 'st_*');
% selNeurNames = neurNames{1}; clear neurNames; neurNames = selNeurNames;
[framenoInfo] = get_frameno_info(dirName.gp );
frameno = get_framenos(flist);
ifunc.sta.calc_and_save_sta(dirName, neurNames , flistFileNameID, hdmea, frameno, ...
    'save_footprint',1,'use_sep_dir', 'White_Noise');


%% plot STA key figures (modified)
selNeuronInds = 1:length(neurNames);
        % plot waveforms
        allEls = 1:size(hdmea,2);
        
        notIncludedEls = [14 116 80 82 11 10 85 8 7 64];
        allElsToPlot = 1:size(hdmea,2);
        allElsToPlot(notIncludedEls) = [];

for i=1:length(neurNames)
    doPrint = 0;
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

for iNeur = 5%:length(neurNames)%length(selNeuronInds)
    tic
    
    if exist('data')
        clear data
    end
    % neuron name
    currNeuronName = neurNames{selNeuronInds(iNeur)};
    % set up fig
    figure('Position',[1 1 scrsz(3)/2 scrsz(4)])
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
    
%     numSpikes = size(data.White_Noise.footprint.waveform,1);
%     currElNo = str2num(currNeuronName(1:4));
%     indMainEl = find(data.White_Noise.footprint.el_idx(11:118) == currElNo);
    
    clear ppAmps elCoordsX elCoordsY
    % plot footprints
    %     [ppAmps elCoordsX elCoordsY] = plot_footprints_all_els(  elConfigInfo, ...
    %         data.White_Noise.footprint.averaged, ...
    %                'exclude_els', ...
    %         [1596 2001 2304 2505 2911  3214 3415 3820 4123 4324],'line_width', 1, ...
    %         'scale', 3.5, 'plot_sel_els_red', ...
    %         data.White_Noise.footprint.el_idx(data.White_Noise.inds_for_sorting_els ));
    % %
    
    % AxesHandle =subplot(2,2,2)
    mysort.plot.waveforms2D_2(data.White_Noise.footprint_median, hdmea.MultiElectrode.electrodePositions,...
        'plotMedian', 1,...
        'maxWaveforms', 5000, ...
        'plotElNumbers', allEls, ...%         'plotHorizontal', idxMaxAmp, ...
        'plotSelIdx', allElsToPlot,'AxesHandle',AxesHandle, ...
        'fontSize', 7)
   
    
    %     ppAmpMainEl = ppAmps(indMainEl);
    %     hold on
    %     plot(data.White_Noise.footprint.center_of_footprint_xy(1), ...
    %         data.White_Noise.footprint.center_of_footprint_xy(2),'r*','linewidth', 8);
    %     axis square
    
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
        exportfig(gcf, fullfile(dirName.figs, 'STA', strcat('sta_key_figs_',currNeuronName)) ,'Resolution', 120,'Color', 'cmyk')
    end
    
    
    fprintf('Error with %s\n', currNeuronName)
    
    %     close all
    toc
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


