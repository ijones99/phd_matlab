%% GENERATE LOOKUP AND CONFIG TABLES
% get electrode configuration file data: ELCONFIGINFO
% the ELCONFIGINFO file has x,y coords and electrode numbers
% matlabpool open
% ---------- Settings ----------
% flistName = 'flist_pix_surr_50_90_percent'
% flistName = 'flist_orig_stat_surr'
flistName = 'flist_dyn_surr_each_frame_and_shuffled';
suffixName = strrep(flistName,'flist','');
% cd /home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/30Oct2012/Matlab

flist ={}; eval(flistName);
% noise checkerboard
flistFileNameID = get_flist_file_id(flist{1}, suffixName);
dirName = struct('FFile', [],'St', [],'El', [],'Cl', []) ;
dirName.FFile = strcat('../analysed_data/',   flistFileNameID);
dirName.St = strcat('../analysed_data/',   flistFileNameID,'/03_Neuron_Selection/');
dirName.El = strcat('../analysed_data/',   flistFileNameID,'/01_Pre_Spikesorting/');
dirName.Cl = strcat('../analysed_data/',   flistFileNameID,'/02_Post_Spikesorting/');
elConfigClusterType = 'overlapping';
elConfigInfo = get_el_pos_from_nrk2_file;

% %% get neuron names
% neuronNames = get_neur_names_from_dir(dirName.St, 'st_', selNeuronInds);
% %% get neuron inds from neuron names
% selNeuronInds  =  get_file_inds_from_neur_names(dirName.St, '*.mat', neuronNames)
% %% get el nos
% % elNos = get_el_nos_from_neur_names( neuronNames);
% filePattern = 'el_*';
% selElNos= extract_el_numbers_from_files(  dirName.El, filePattern , flist)
% %%  pre process data
% % [selElNos ] = compare_els_between_dir_elconfiginfo(elConfigInfo,dirName.El , ...
% %    '*.mat', flist);
% selElNos = [4831]
% pre_process_data(suffixName, flistName, 'sel_by_els', selElNos,'kmeans_reps',1 )
%% look for unprocessed electrodes
[elNumbers selNeuronInds] = compare_els_between_dirs(dirName.El, dirName.Cl, '*.mat', '*.mat', flist)
%% SUPERVISED SORTING (MANUAL) - create the cl_ files
pattern = 'el*mat';
% elNumbers = selElNos;
selNeuronInds = 1;%get_file_inds_from_el_numbers(dirName.Cl, pattern, elNumbers);
sort_ums_output(flist, 'add_dir_suffix',suffixName, 'sel_in_dir', selNeuronInds); %'sel_in_dir',selNeuronInds); %, );%
% sort_ums_output(flist, 'add_dir_suffix',suffixName, 'sel_in_dir',3)
%% REVIEW CLUSTERS
review_clusters(flist,'add_dir_suffix', suffixName,'sel_els', 3431 )%'all_in_dir');%)%); %, 'sel_in_dir', 12
%% EXTRACT TIME STAMPS FROM SORTED FILES
% auto: create st_ files & create neuronIndList.mat file with names of all neurons found.
extract_spiketimes_from_cl_files(flist, 'add_dir_suffix',suffixName )
%% SPIKE COMPARISONS
% produces heatmaps
flistFileNameID = get_flist_file_id(flist{1}, suffixName);
tsMatrix = load_spiketrains(flistFileNameID);
binWidthMs =0.5;
[heatMap] = get_heatmap_of_matching_ts(binWidthMs, tsMatrix  );
figure, imagesc(heatMap);

%% NEURON DATA QUALITY SHEETS
% clusterNameCore = {'5149n71', '5152n73', '5255n7', '5357n165', '5456n84', '5658n74', '5865n183', '6071n195'};
neuronNames = get_neur_names_from_dir('../analysed_data/profiles/','*_00*')
for i=1:length(neuronNames)
    plot_quality_datasheet_from_cluster_name(flist, suffixName, neuronNames{i}, 'file_save', 1 )
    close all
end
%% plot waveforms for later identification
% selectedNeurons = {'5444n63' ;'5851n157';   '5548n11'
% };
selNeuronInds = 1:11;

selectedNeurons = extract_neur_names_from_files(  dirName.St, 'st_*', flist, 'sel_inds', selNeuronInds);

plot_selected_neuron_waveforms(dirName.Cl, selectedNeurons)
dirFigsOutput = strrep(dirName.FFile,'analysed_data', 'Figs');
% exportfig(gcf, fullfile(dirFigsOutput,strcat('Selected_Neurons_Waveforms','.ps')) ,'Resolution', 120,'Color', 'cmyk')

%% Plot Rasters
dateValTxt = '13Dec2012_2';
dirNameSTA = strcat(fullfile('../Figs/',   flistFileNameID, '/rasters'));
mkdir(dirNameSTA)
textLabel = {...
    'Orig_500um'; 'Stat_Surr_500um' ...
    }
pattern = '*.mat';
figure, subplot(2,2,1), hold on
selNeuronInds = [7 8]
plot_raster_for_natural_movie_and_aperture(flistFileNameID, flist, dateValTxt, ...
    dirNameSTA, selNeuronInds, textLabel)

%% get inds
elNumbers = {'5444n63' ;'5851n157';   '5548n11'};
selNeuronInds = get_file_inds_from_el_numbers(dirName.St, '*.mat', elNumbers);

%% plot footprints
fileNames = dir(strcat(dirName.St,'*.mat'));
figure, hold on
% textprogressbar('')
selNeuronInds = 1:length(neuronNames);
colorMap = jet;
colorMap = colorMap(10:end,:);
numPlotColors =length(selNeuronInds);
colorIndSpacing = floor(length(colorMap)/numPlotColors);
colorInds = [1:colorIndSpacing:numPlotColors*colorIndSpacing];

iColor = 1;
%  textprogressbar('plotting footprints');
for i=selNeuronInds
    
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
title('Natural Movie and Static Median Surround')
%  textprogressbar('end');
