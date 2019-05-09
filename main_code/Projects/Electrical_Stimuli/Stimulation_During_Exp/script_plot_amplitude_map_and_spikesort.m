chunkSize = 2e4*60*4;
ntk=initialize_ntkstruct(flist{2},'hpf', 500, 'lpf', 3000);
[ntk2 ntk]=ntk_load(ntk, chunkSize, 'images_v1', 'digibits');

thr_f=4;
pretime=16;
posttime=16;
allevents=simple_event_cut(ntk2, thr_f, pretime, posttime);
event_data2=convert_events(allevents,ntk2)
%%
nrg = nr.Gui
set(gcf, 'currentAxes',nrg.ChipAxesBackground)
hidens_generate_amplitude_map(event_data2,'no_border','no_colorbar', ...
'no_plot_format');
numStaticEls = 8;  
while length(nrg.configList.selectedElectrodes) < numStaticEls 
    pause(0.25)
end
fprintf('Done selecting electrodes.\n')
staticEls = nrg.configList.selectedElectrodes;

%% spikesort
[spikes mea1 dataChunkParts concatData] = load_and_spikesort_selected_els(flist,...
 staticEls)  % 'force_file_conversion'
%% get spike times for each config
spikeTimes = [spikes.assigns' round(2e4*spikes.spiketimes')];
selSpikeTimes = {};
for i=1:length(mea1)
    selSpikeTimeInds = extract_indices_within_range(spikeTimes(:,2), dataChunkParts(i), ...
        dataChunkParts(i+1));
    selSpikeTimes{i} = spikeTimes(selSpikeTimeInds,:);
    selSpikeTimes{i}(:,2) = selSpikeTimes{i}(:,2)-dataChunkParts(i);
end

%% plot the footprint
doPlotNeuroRouter= 1;
umsClusNo = 1
[nrg ah ] = plot_footprint_from_mea1_data(mea1, umsClusNo, ...
    selSpikeTimes, doPlotNeuroRouter)


