clear flistName
expDirNames = {...
    '10Apr2013'...
    };
ifunc.file.convert_ntk2_files_to_h5(expDirNames);
acqFreq = 2e4;
% WHITE NOISE
%stimulus name
flistName{1} = 'flist_white_noise_checkerboard';stimName{1} = 'White_Noise';
% set up directories
[dirName suffixName flist flistFileNameID streamName tName]= ...
    ifunc.data_proc.set_dirs_for_init_processing(flistName{1},stimName{1});
% Prepare H5 File Access
h5File = strrep(strrep(flist,'../proc/',''),'ntk','h5');
h5File = h5File{1};
dateVal = get_dir_date
hdmea = ifunc.h5.prepare_h5_file_access(dateVal, h5File);
[selElsIdx elsToExcludeIdx] = ifunc.el_config.get_sel_el_ids(hdmea);
mkdir(dirName.gp)
% frameno = get_framenos(flist, acqFreq*60*60);
% save(fullfile(dirName.gp,strcat(['frameno_', flistFileNameID,'.mat'])), ...
%     'frameno');
% save shifted version of frameno
% shift_and_save_frameno_info(flistFileNameID); 
% extract spike times
extract_spiketimes_from_auto_cluster_files( flistFileNameID,...
    dirName.auto_sorter_gps)
% >> Calculate STA info
neurNames = extract_neur_names_from_files(dirName.st,'*_00*.mat');
% do init processing
%
neurIdx = 1:length(neurNames);
ifunc.auto_run.initial_neuron_processing(flistName{1},stimName{1}, [], [], ...
    get_dir_date,'neurIdx', neurIdx)

%% FLASHING DOTS
%stimulus nam
acqFreq = 2e4;
% flistName{2} = 'flist_flashing_dots';stimName{2} = 'Flashing_Dots';
flistName{2} = 'flist_flashing_spots';stimName{2} = 'Flashing_Dots';
% set up directories
[dirName suffixName flist flistFileNameID streamName tName]= ...
    ifunc.data_proc.set_dirs_for_init_processing(flistName{2},stimName{2});
% Prepare H5 File Access
h5File = strrep(strrep(flist,'../proc/',''),'ntk','h5');
h5File = h5File{1};
dateVal = get_dir_date
hdmea = ifunc.h5.prepare_h5_file_access(dateVal, h5File);
mkdir(dirName.gp)
if ~exist(fullfile(dirName.gp,strcat(['frameno_', flistFileNameID,'.mat'])))
    frameno = get_framenos(flist, acqFreq*60*60);
    save(fullfile(dirName.gp,strcat(['frameno_', flistFileNameID,'.mat'])), 'frameno');
    % save shifted version of frameno
    shift_and_save_frameno_info(flistFileNameID);
end
% extract spike times
extract_spiketimes_from_auto_cluster_files( flistFileNameID, dirName.auto_sorter_gps)
%>> Calculate STA info
neurNames = extract_neur_names_from_files(dirName.st,'*_00*.mat');
[framenoInfo] = get_frameno_info(flistFileNameID );
load ../../21Aug2012/Matlab/StimCode/StimParams_SpotsIncrSize.mat
ifunc.auto_run.initial_neuron_processing(flistName{2},stimName{2},...
    Settings, StimMats)


%% MOVING BARS
%stimulus name
acqFreq = 2e4;
flistName{3} = 'flist_moving_bars';stimName{3} = 'Moving_Bars';
% set up directories
[dirName suffixName flist flistFileNameID streamName tName]= ...
    ifunc.data_proc.set_dirs_for_init_processing(flistName{3},stimName{3});
% Prepare H5 File Access
h5File = strrep(strrep(flist,'../proc/',''),'ntk','h5');
h5File = h5File{1};
dateVal = get_dir_date
hdmea = ifunc.h5.prepare_h5_file_access(dateVal, h5File);
mkdir(dirName.gp)
frameno = get_framenos(flist, acqFreq*60*60);
save(fullfile(dirName.gp,strcat(['frameno_', flistFileNameID,'.mat'])), 'frameno');
% save shifted version of frameno
shift_and_save_frameno_info(flistFileNameID);
% extract spike times
extract_spiketimes_from_auto_cluster_files( flistFileNameID, dirName.auto_sorter_gps)
%>> Calculate STA info
neurNames = extract_neur_names_from_files(dirName.st,'*_00*.mat');
[framenoInfo] = get_frameno_info(flistFileNameID );

load ../../21Aug2012/Matlab/StimCode/StimParams_Bars.mat
ifunc.auto_run.initial_neuron_processing(flistName{3},stimName{3},...
    Settings, [])

%% plot STA key figures (modified)
dirName.prof_wn = '../analysed_data/profiles/White_Noise';
neurNames{1} = extract_neur_names_from_files(dirName.prof_wn ,'*_*.mat');
selNeuronInds = 1:length(neurNames{1});
% plot waveforms
allEls = 1:size(hdmea,2);
[selElsIdx elsToExcludeIdx] = ifunc.el_config.get_sel_el_ids(hdmea);
allElsToPlot = 1:size(hdmea,2);
allElsToPlot = selElsIdx ;

for i=1

doPrint = 1;
setSpacing = 0.013;
setPadding = 0.013;
setMargin = 0.1;

rowsPerWindow= 4;
numCols = 4;
numWindows = ceil(length(length(neurNames{1}))/rowsPerWindow);
% winInds =   repmat([1:numWindows],rowsPerWindow,1);
% winInds = reshape(winInds,1,numel(winInds)); % indices for windowws
rowInds = repmat([1:rowsPerWindow],1,numWindows);
scrsz = get(0,'ScreenSize');% [left bottom width height]
dirCurr = pwd;
dateValLoc = strfind(dirCurr,'/');
dataVal = dirCurr(dateValLoc(end-1)+1:dateValLoc(end)-1);
numFiles = length(neurNames{1});
figCounter = 0;
structName = {};
numNeurs = length(neurNames{1});
end
errorInds = [];
for iNeur = 1:length(neurNames{1})%length(selNeuronInds)
    tic
    try
    if exist('data')
        clear data
    end
    % neuron name
    currNeuronName = neurNames{1}{selNeuronInds(iNeur)};
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
%     catch
%        errorInds(end+1) = iNeur; 
%     end
    close all
    end
    end
%% Plot STAs only
clear flistName
acqFreq = 2e4;
% WHITE NOISE %stimulus name
flistName{1} = 'flist_white_noise_checkerboard';stimName{1} = 'White_Noise';
% set up directories
[dirName suffixName flist flistFileNameID streamName tName]= ...
    ifunc.data_proc.set_dirs_for_init_processing(flistName{1},stimName{1});
% Prepare H5 File Access
h5File = strrep(strrep(flist,'../proc/',''),'ntk','h5');
h5File = h5File{1};
dateVal = get_dir_date
hdmea = ifunc.h5.prepare_h5_file_access(dateVal, h5File);
[selElsIdx elsToExcludeIdx] = ifunc.el_config.get_sel_el_ids(hdmea);


dirName.prof_wn = '../analysed_data/profiles/White_Noise';
neurNames{1} = extract_neur_names_from_files(dirName.prof_wn ,'*_*.mat');
selNeuronInds = 1:length(neurNames{1});
scrSize = get(0,'ScreenSize');
numNeurs = length(neurNames{1});

iSubplot = 1;
h=figure('Position',[1 1 scrSize(3) scrSize(4)]);
set(gcf, 'color', 'white')
hold on
subplotDims = [4,8];
iFig = 1;
for iNeur = 1:length(neurNames{1})%length(selNeuronInds)

    if exist('data')
        clear data
    end
    % neuron name
    currNeuronName = neurNames{1}{selNeuronInds(iNeur)};
    % set up fig

    % load profile data
    data = load_profiles_file(currNeuronName,'use_sep_dir','White_Noise');
    if isfield(data.White_Noise,'sta_temporal_plot')
    [junk indSTAFrMin] = min(data.White_Noise.sta_temporal_plot.staIms); indSTAFrMin = indSTAFrMin(1);
    [junk indSTAFrMax] = max(data.White_Noise.sta_temporal_plot.staIms); indSTAFrMax = indSTAFrMax(1);
    
    selIm = data.White_Noise.sta(:,:,indSTAFrMin); selIm = (imrotate(flipud(selIm),-90));
    subplot(subplotDims(1),subplotDims(2),iSubplot)
    imagesc(selIm); axis square, axis off, hold on
    circle([data.White_Noise.plot_info.imWidth/2+1.5 data.White_Noise.plot_info.imWidth/2+1.5],...
        (data.White_Noise.plot_info.imWidth*...
        data.White_Noise.plot_info.apertureDiam/data.White_Noise.plot_info.stimWidth)/2,...
        data.White_Noise.plot_info.imWidth,'k--',2);
    title(strcat(currNeuronName,'(',num2str(iNeur),')'));
    
    iSubplot = iSubplot+1;
    selIm = data.White_Noise.sta(:,:,indSTAFrMax); selIm = (imrotate(flipud(selIm),-90));
    subplot(subplotDims(1),subplotDims(2),iSubplot)
    imagesc(selIm); axis square, axis off, hold on
    circle([data.White_Noise.plot_info.imWidth/2+1.5 data.White_Noise.plot_info.imWidth/2+1.5],...
        (data.White_Noise.plot_info.imWidth*...
        data.White_Noise.plot_info.apertureDiam/data.White_Noise.plot_info.stimWidth)/2,...
        data.White_Noise.plot_info.imWidth,'k--',2);
    title(strcat(currNeuronName,'(',num2str(iNeur),')'));
    if iSubplot/(subplotDims(1)*subplotDims(2)) == round(iSubplot/(subplotDims(1)*subplotDims(2)))
        h=figure('Position',[1 1 scrSize(3) scrSize(4)]);
        set(gcf, 'color', 'white')
        hold on
        iSubplot = 0;
        dirName.sta = '../Figs/White_Noise/STA';
        if ~exist(dirName.sta,'dir'),mkdir(dirName.sta),end
        saveas(h,fullfile(dirName.sta,strcat('sta_group_',num2str(iFig),'.fig')),'fig')
        saveas(h,fullfile(dirName.sta,strcat('sta_group_',num2str(iFig),'.eps')),'eps')
        iFig = iFig +1;
    end
    iSubplot = iSubplot+1;
    else
       fprintf('''%s''; ...\n', currNeuronName) 
    end
end
%% Do footprint median comparisons
plot_electrode_config('plot_el_ind',1)
elsToExcludeIdx = [1 2 111 114 112 113];
acqFreq = 2e4;
% WHITE NOISE
%stimulus name
flistName{1} = 'flist_white_noise_checkerboard';stimName{1} = 'White_Noise';
% set up directories
[dirName suffixName flist flistFileNameID streamName tName]= ...
    ifunc.data_proc.set_dirs_for_init_processing(flistName{1},stimName{1});

% Prepare H5 File Access
h5File = strrep(strrep(flist,'../proc/',''),'ntk','h5');
h5File = h5File{1};
dateVal = get_dir_date
hdmea = ifunc.h5.prepare_h5_file_access(dateVal, h5File);
% [selElsIdx elsToExcludeIdx] = ifunc.el_config.get_sel_el_ids(hdmea);
neurNames = {};
stimNames = {'White_Noise', 'Noise_Movie'};
for i=1:length(stimNames)
    dirNameProf{i} = strcat(fullfile(dirName.prof,stimNames{i}),'/'); mkdir(dirNameProf{i});
    dirNameFPMatch{i} = fullfile('../Figs/', stimNames{i},'Footprint_Matching/'); mkdir(dirNameFPMatch{i});
    neurNames{i} = extract_neur_names_from_files(dirNameProf{i},'*_*.mat');

end

comparisonSets = [1 2]%[1 2; 1 3; 1 4; 1 5];
for i=1:2
    [listMatches reverseMatExpNorm outputMat medianFootprints neurNames1]  = ...
        ifunc.footprints.compute_footprint_similarity_for_two_groups(neurNames(comparisonSets(i,:)), ...
        stimNames(comparisonSets(i,:)));
    
    dirName.matching_footprint_plots = strcat('../analysed_data/Footprint_Matching/');mkdir(dirName.matching_footprint_plots)
    
    save(fullfile(dirName.matching_footprint_plots,strcat('fp_matching_',...
        stimNames{comparisonSets(i,1)},'_vs_', stimNames{comparisonSets(i,2)},'.mat')) , ...
        'listMatches', 'reverseMatExpNorm', 'outputMat', 'medianFootprints', 'neurNames');
    
    % plot matching footprints
    ifunc.plot.footprints.plot_footprint_median_comparisons(neurNames(comparisonSets(i,:)),...
        stimNames(comparisonSets(i,:)), medianFootprints, listMatches, ...
        hdmea.MultiElectrode.electrodePositions, ...
        'savePlot', dirNameFPMatch{i+1},'excludeEls',elsToExcludeIdx,'totalNumEls',length(hdmea.MultiElectrode.electrodePositions) );
    
end
%% Put matches together
% Paste values from spreadsheet: col 1: inds for white noise
%                               col 2: selected footprint that matches
%                               (1 or 2 or3 or 4)
%                               col 3: same as 2, but for next stimuli
% 
% selMatchesMat 
% selNeurNamesQDS
clear indsQDS
% get inds
indsQDS = selMatchesMat(:,1);
neurNamesQDS = extract_neur_names_from_files(dirName.qds,'*.fig');
selNeurNames = neurNamesQDS(indsQDS);
neurNamesProfWn = extract_neur_names_from_files(dirName.prof_wn,'*_*.mat');
indsProfWn = find(ismember(neurNamesProfWn, selNeurNames));
comparisonSets = [1 2; 1 3];
selMatchesMat(:,1) = indsProfWn;

neurNameMat = cell(size(selMatchesMat,1),size(comparisonSets,1)+1);
neurNameMat(:,1) = neurNames{1}(selMatchesMat(:,1)); % neuron names for white noise

for i=1:2
    dirName.matching_footprint_plots = strcat('../analysed_data/Footprint_Matching/');
    load(fullfile(dirName.matching_footprint_plots,strcat('fp_matching_',...
        stimNames{comparisonSets(i,1)},'_vs_', stimNames{comparisonSets(i,2)},'.mat')));
    
    neurNameMat(:,i+1) = ifunc.neurname.extract_selected_neur_name_matrix(neurNames(comparisonSets(i,:)),...
    selMatchesMat(:,1), listMatches, selMatchesMat(:,i+1))
    
end
save('neurNameMat.mat', 'neurNameMat'); save('selMatchesMat.mat', 'selMatchesMat');
%% process selected neurons in movies
flistNamesMovies = {...
%     'flist_movie_original', ...
%     'flist_movie_static_surr_median'...
    'flist_natural_movie_dyn_med_surr',...
    'flist_natural_movie_dyn_med_surr_shuff',...
    'flist_natural_movie_pix_10p',...
    'flist_natural_movie_pix_50p',...
    'flist_natural_movie_pix_90p',...
    };
stimNamesMovies = {...
%     'Movie_Original', ...
%      'Movie_Static_Surr_Median',...
    'Movie_Dynamic_Surr_Median_Each_Frame',...
    'Movie_Dynamic_Surr_Median_Each_Frame_Shuffled',...
    'Movie_Pix_Surr_10_Percent',...
    'Movie_Pix_Surr_50_Percent',...
    'Movie_Pix_Surr_90_Percent',...
    };
dirList = ifunc.dir.create_dir_list;
dirListMovies = dirList.belsvn(7);
ifunc.proc.initial_neuron_processing_movies(stimNamesMovies, dirListMovies, flistNamesMovies,1 )

%% get firing rate for all neurons
% 29.9640 movie time

flistNamesMovies = {...
   'flist_movie_original' ...
}
    %     'flist_movie_static_surr_median'... 
%     };

%     'flist_movie_dynamic_surr_median_each_frame',...
%     'flist_movie_dynamic_surr_median_each_frame_shuffled',...
%     'flist_movie_pix_surr_50_percent',...
%     'flist_movie_pix_surr_90_percent'};
stimNamesMovies = {...
    'Movie_Original' ...
};
    %     'Movie_Static_Surr_Median'...
%     };

%     'Movie_Static_Surr_Median',...
%     'Movie_Dynamic_Surr_Median_Each_Frame',...
%     'Movie_Dynamic_Surr_Median_Each_Frame_Shuffled',...
%     'Movie_Pix_Surr_50_Percent',...
%     'Movie_Pix_Surr_90_Percent'};
dirList = ifunc.dir.create_dir_list;
dirListMovies = dirList.belsvn(1:end);
load motionVector
distMoved = sqrt(motionVector(:,1).^2+ sqrt(motionVector(:,2).^2));
[firingRatesOut_Orig calcCorr]= ifunc.analysis.get_firing_rate_multiple_neurons(stimNamesMovies, ...
    dirListMovies, flistNamesMovies,[4], distMoved)
%% combine all profiles
ifunc.profiles.combine_neur_profiles(neurNameMat, stimNames, 'All_Stim')