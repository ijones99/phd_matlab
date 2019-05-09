clear flistName
expDirNames = get_dir_date
acqFreq = 2e4;
ifunc.file.convert_ntk2_files_to_h5(expDirNames);
%%
%stimulus name
[flistName stimName]=ifunc.name.get_standard_stimulus_names

for iStim = [ 3 4 5 7]
    % set up directories
    [dirName suffixName flist flistFileNameID streamName tName]= ...
        ifunc.data_proc.set_dirs_for_init_processing(flistName{iStim},stimName{iStim});
    % Prepare H5 File Access
    h5File = strrep(strrep(flist,'../proc/',''),'ntk','h5');
    h5File = h5File{1};
    dateVal = get_dir_date
    hdmea = ifunc.h5.prepare_h5_file_access(dateVal, h5File);
    [selElsIdx elsToExcludeIdx] = ifunc.el_config.get_sel_el_ids(hdmea);
    mkdir(dirName.gp)
    frameno = get_framenos(flist, acqFreq*60*60);
    save(fullfile(dirName.gp,strcat(['frameno_', flistFileNameID,'.mat'])), ...
        'frameno');
    % save shifted version of frameno
    shift_and_save_frameno_info(flistFileNameID);
    % extract spike times
    extract_spiketimes_from_auto_cluster_files( flistFileNameID,...
        dirName.auto_sorter_gps)
    % >> Calculate STA info
    neurNames = extract_neur_names_from_files(dirName.st,'*_*.mat');
    % do init processing
    %
    neurIdx = 1:length(neurNames);
    ifunc.auto_run.initial_neuron_processing(flistName{iStim},stimName{iStim}, [], [], ...
        get_dir_date,'neurIdx', neurIdx)
end

%% Plot STAs only
clear flistName
acqFreq = 2e4;
% WHITE NOISE %stimulus name
flistName{1} = 'flist_noise_movie';stimName{1} = 'Noise_Movie';
% set up directories
[dirName suffixName flist flistFileNameID streamName tName]= ...
    ifunc.data_proc.set_dirs_for_init_processing(flistName{1},stimName{1});
% Prepare H5 File Access
h5File = strrep(strrep(flist,'../proc/',''),'ntk','h5');
h5File = h5File{1};
dateVal = get_dir_date
hdmea = ifunc.h5.prepare_h5_file_access(dateVal, h5File);
[selElsIdx elsToExcludeIdx] = ifunc.el_config.get_sel_el_ids(hdmea);


dirName.prof_wn = '../analysed_data/profiles/Noise_Movie';
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
    data = load_profiles_file(currNeuronName,'use_sep_dir','Noise_Movie');
    if isfield(data.Noise_Movie,'sta_temporal_plot')
    [junk indSTAFrMin] = min(data.Noise_Movie.sta_temporal_plot.staIms); indSTAFrMin = indSTAFrMin(1);
    [junk indSTAFrMax] = max(data.Noise_Movie.sta_temporal_plot.staIms); indSTAFrMax = indSTAFrMax(1);
    
    selIm = data.Noise_Movie.sta(:,:,indSTAFrMin); selIm = (imrotate(flipud(selIm),-90));
    subplot(subplotDims(1),subplotDims(2),iSubplot)
    imagesc(selIm); axis square, axis off, hold on
    circle([data.Noise_Movie.plot_info.imWidth/2+1.5 data.Noise_Movie.plot_info.imWidth/2+1.5],...
        (data.Noise_Movie.plot_info.imWidth*...
        data.Noise_Movie.plot_info.apertureDiam/data.Noise_Movie.plot_info.stimWidth)/2,...
        data.Noise_Movie.plot_info.imWidth,'k--',2);
    title(strcat(currNeuronName,'(',num2str(iNeur),')'));
    
    iSubplot = iSubplot+1;
    selIm = data.Noise_Movie.sta(:,:,indSTAFrMax); selIm = (imrotate(flipud(selIm),-90));
    subplot(subplotDims(1),subplotDims(2),iSubplot)
    imagesc(selIm); axis square, axis off, hold on
    circle([data.Noise_Movie.plot_info.imWidth/2+1.5 data.Noise_Movie.plot_info.imWidth/2+1.5],...
        (data.Noise_Movie.plot_info.imWidth*...
        data.Noise_Movie.plot_info.apertureDiam/data.Noise_Movie.plot_info.stimWidth)/2,...
        data.Noise_Movie.plot_info.imWidth,'k--',2);
    title(strcat(currNeuronName,'(',num2str(iNeur),')'));
    if iSubplot/(subplotDims(1)*subplotDims(2)) == round(iSubplot/(subplotDims(1)*subplotDims(2)))
        h=figure('Position',[1 1 scrSize(3) scrSize(4)]);
        set(gcf, 'color', 'white')
        hold on
        iSubplot = 0;
        dirName.sta = '../Figs/Noise_Movie/STA';
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
