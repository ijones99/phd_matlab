% script analysis white noise
clear flist
profData = {}
dirNameConfig = '/home/ijones/Experiments/Configs/Projects/Electrical_Stimulation/18x6_spc1_tile7x14_main_ds_scan/';
load(fullfile(dirNameConfig,'configCtrXY'))
% make flist
[sortGroupNumber flist] = flists.make_and_save_flist('wn_checkerboard');
profData.flist = flist;
profData.expDate = get_dir_date;
% load data and cut events to create activity map 
[ntk2 activity_map] = plot.load_and_cut_events_for_activity_map(profData.flist,...
    'load_time_sec', 45)
%% Select the spikesorting electrodes on the activity map at high-activity location
profData.staticEls = els.select_electrodes_on_activity_map(activity_map) 
%% spikesort selected electrodes
profData.sortingRunName = sprintf('flist_checkerboard_n_%02d',sortGroupNumber);disp(profData.sortingRunName)
gpNum = input('Enter sorting gp number: >>');
sortingName = sprintf('%s_gp_%d',strrep( profData.sortingRunName,'flist_',''),gpNum);
save.save_plot_to_file('../Figs/', ['sorting_el_select_', sortingName],'eps');
save.save_plot_to_file('../Figs/', ['sorting_el_select_', sortingName],'fig');
[spikes meaData dataChunkParts concatData] = load_and_spikesort_selected_els(profData.flist,...
        profData.staticEls);  % 'force_file_conversion','no_spikesorting'
% meaData = load_h5_data(profData.flist);
%% get spike times for each config
ts = spiketrains.get_spiketimes_from_meadata(spikes, meaData, dataChunkParts)
%% put into neuron structure format
[out profData.fileName] = neur_struct.create_out_struct(meaData, spikes,ts, profData.flist)

out.ts = ts;
save(sprintf('%s.mat', out.file_name),'out');

%% get el pos
ntk2 = load_ntk2_data(profData.flist,1)
profData.elConfigCtrXY = [mean(ntk2.x) mean(ntk2.y)];
profDirName = '../analysed_data/'; profFileName = sprintf('prof_data_%s', profData.fileName);
save(fullfile(profDirName, profFileName ), 'profData');
%% load frames
load /local0/scratch/ijones/stimuli_frames/white_noise_frames.mat
%% plot the STA response with frames
numSquaresOnEdge = [12 12];
while 1==1
    unique(spikes.assigns)
    profData.clusNo = input('clus # ');
    spikeTimeIds = find( out.spikes.assigns==profData.clusNo);
    profData.stSel = out.spikes.spiketimes(spikeTimeIds);
    
    [profData.staFrames profData.staTemporalPlot profData.plotInfo profData.bestSTAInd] =...
        ifunc.sta.make_sta( profData.stSel*2e4, ...
        white_noise_frames(1:numSquaresOnEdge(1),1:numSquaresOnEdge,:), ...
        out.images.frameno,'do_print')
    title(sprintf('WN Checkerboard (cluster %d)',profData.clusNo));
    plotDir = '../Figs/';
    fileName = sprintf('%s_sta_%s_clus_%d', ...
        get_dir_date, out.file_name, profData.clusNo);
    doSave = input('Save? [y/n]', 's');
    if strcmp(doSave,'y')
        save.save_plot_to_file(plotDir, fileName, 'eps');
        save.save_plot_to_file(plotDir, fileName, 'fig');
    elseif strcmp(doSave,'q')
        return;
    end
    commandwindow
end
%% plot RF on array
profData.clusNo = input('clus # ');
fprintf('Cluster # %d.\n',profData.clusNo )
neurInd = find( unique(spikes.assigns)==profData.clusNo);
spikeTimeIds = find( out.spikes.assigns==profData.clusNo);
profData.stSel = out.spikes.spiketimes(spikeTimeIds);

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
plot_footprints_simple([out.neurons{neurInd}.x' out.neurons{neurInd}.y'], ...
    out.neurons{neurInd}.template.data', ...
        'input_templates','hide_els_plot','format_for_neurorouter',...
        'plot_color','k', 'flip_templates_ud', 'flip_templates_lr','scale', 55, ...
        'line_width',2);

plotDir = '../Figs/';
fileName = sprintf('%s_checkerboard_rf_%s_clus_%d', get_dir_date, out.file_name, profData.clusNo);
plot.plot_peak2peak_amplitudes(out.neurons{neurInd}.template.data', ...
    out.neurons{neurInd}.x,out.neurons{neurInd}.y);
save.save_plot_to_file(plotDir, fileName, 'eps');
save.save_plot_to_file(plotDir, fileName, 'fig');

%% Select the center of the RF
all_els=hidens_get_all_electrodes(2);
% configNum = input('Enter config#');
% configIndNum = configNum+1; %because file names start at 0;
arrayCtrXY = [mean(unique(all_els.x)) mean(unique(all_els.y))]; 
fprintf('Select center of receptive field\n')
centerLocation = ginput(1);
profData.rfTrueCtr.x = centerLocation(1);profData.rfTrueCtr.y = ...
    centerLocation(2);
profData.rfRelCtr.x = round(centerLocation(1)-mean(ntk2.x));
profData.rfRelCtr.y = round(mean(ntk2.y)-centerLocation(2));

fprintf('Move rel. to center of config: [%3.0f %3.0f]\n', ...
    profData.rfRelCtr.x,profData.rfRelCtr.y  );
fprintf('Selected xy coord: [%5.0f %5.0f]\n', centerLocation(1), ...
    centerLocation(2))

%% save data
neuronName = sprintf('%s_clus_%d', ...
    out.file_name, profData.clusNo);
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
