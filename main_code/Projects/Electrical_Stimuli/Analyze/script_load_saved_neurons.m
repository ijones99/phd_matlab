%% load files of the saved neurons
cellSearchScanName = input('Enter cellSearchScanName>> ','s');

load_mat_files_to_workspace(cellSearchScanName,'add_asterisk')

% load all h5 files (regional scan)
if exist('flist')
    mea1 = load_h5_data(flist)
else
    fprintf('Please load flist.\n')
end

% get spike times for each config
spikeTimes = [out.spikes.assigns' round(2e4*out.spikes.spiketimes')];
selSpikeTimes = {};
for i=1:length(mea1)
    selSpikeTimeInds = extract_indices_within_range(spikeTimes(:,2), ...
        dataChunkParts(i), dataChunkParts(i+1));
    selSpikeTimes{i} = spikeTimes(selSpikeTimeInds,:);
    selSpikeTimes{i}(:,2) = selSpikeTimes{i}(:,2)-dataChunkParts(i);
end

unique(selSpikeTimes{1}(:,1))';
%% load footprint info of cells
umsClusNo  = input('Enter cluster number>> ');
[mposx mposy mat footprintWaveforms footprintInfo] = ...
    construct_footprint_from_mea1_data(mea1, umsClusNo, ...
    selSpikeTimes);

%% create configurations below cell
sortingRunName = 'neur_stim_cell_volt_01'
staticEls = [];
all_els=hidens_get_all_electrodes(2);
[scanEls indsLocalInside] = select_els_in_sel_pt_polygon( all_els, 'num_points',15 )
fprintf('Done selecting scanning electrodes.\n')

pause(0.5)
% get area to scan
configs_stim_light = generate_specific_point_defined_stim_configs(scanEls, ...
    staticEls, sortingRunName, 'no_plot','stim_els')


