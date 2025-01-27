% UMS2000 Spike sorting

ums_2000_marching_square.m
ums_2000_routing_manual.m
/home/ijones/ln_trunk/UMS2000_SpikeSorter/BasicAnalysis/ums_2000_basic_sorting.m





% To extract data from the timestamps
hidens_extract_traces.m % Need ntk2 file and timestamps.


AUTO START AND STOP COMMANDS
hidens_startSaving(2,'bs-hpws03')

hidens_stopSaving(2,'bs-hpws03')



% ------------------- toolbox claim ------------------- %
geomean(3);  %statistics_toolbox
[k,r0] = ac2rc(.1); % signal_toolbox

%% ------------------- NTK2 STRUCTURE -------------------
% ntk2.images.frameno increases by one every time frame is changed.

%% ------------------- DEFINITIONS -------------------
% sr = signal acquisition rate
% fr = firing rate

% ------------------- Useful Commands ------------------- %

squeeze
shiftdims
reshape
horzcat
vertcat
permute

%% ------------------- FOLDERS -------------------
cd /home/ijones/Matlab/Spikesorting/MatlabFiles
cd /home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska
cd /home/ijones/bel.svn/cmosmea_external/matlab/
cd /home/ijones/Matlab/Spikesorting/Beginning_Spike_Sorting

% ----------------- Klustakwik ---------------- %
% Method used: Classification Expectation Maximization (CEM)


%% ------------------- KEY FUNCTIONS FOR NEURONS ------------------- 
%neo
%ICA
nnn_m2=hidens_neuro_processNEO(flist{1}, 'ica','nr_ica_to_use',8,'maxloops',3,'maxtime',20,'pretime',6,'posttime',28,'icathr',7,'keepall','interactive', 'chunk',400000);

plot_neurons(nnn_m2.neurons, 'separate_subplots','dotraces_gray','do_propagation')
plot_neurons(nnn_m2.neurons, 'separate_subplots','do_propagation')
plot_neurons(nnn_m2.neurons, 'separate_subplots','do_propagation','notext','lim2active')

%projection test for 2 neurons
projection_test(cluster01{1}, cluster02{2}) 

% plot timestamps
plot_ts(sorted_nnn)

%template with all traces overlayed
plot_neurons(sorted_nnn, 'dotraces_gray')

% for multiple neurons
plot_neurons(sorted_nnn, 'separate_subplots')

%interspike interval
plot_isi(sorted_nnn)

%to plot templates
template_plotter(sorted_nnn)

%plot multiple neurons
plot_neurons(sorted_nnn)

%neo version 
hidens_neuroprocessNEO
nnn = hidens_neuro_processNEO(flist{1}, 'ica','nr_ica_to_use',8,'maxloops',3,'maxtime',20,'pretime',6,'posttime',28,'icathr',7,'keepall','chunk',400000);

%What does this do?
plot_neuron_loc

% plots amp, etc.
plot_neurons_features

% plot recording block locations
plot_recording_blocks(flist,'exp', 'dontsave')

% plot event map
hidens_generate_event_map %see example in file

% peak to peak histogram
plot_pktpk



./OptimalFiltering/filter_template_plot.m
./OptimalFiltering/plot_filter_answers_angepasst.m
./OptimalFiltering/plot_filter_answers.m
./OptimalFiltering/filter_template_plot_angepasst.m
./OptimalFiltering/plot_linear_filters.m
./plot_electrode_map.m
./RetinaFunctions/plot_RGCs_bar_response.m
./RetinaFunctions/plot_RGCs_repetitions.m
./RetinaFunctions/plot_RGCs_marching_response.m
./RetinaFunctions/plot_dots_gratings.m
./RetinaFunctions/plot_bar_response.m
./RetinaFunctions/plot_ST_MAP.m
./RetinaFunctions/plot_pca.m
./RetinaFunctions/plot_marching_response.m
./RetinaFunctions/plot_natural_scene.m
./RetinaFunctions/plot_rp_psth_footprint.m
./RetinaFunctions/plot_centers_rgcs.m
./RetinaFunctions/polar_plot.m
./SpikeSorter/plot_neuron_loc.m
./SpikeSorter/plot_ts.m
./SpikeSorter/plot_neuron_pdf.m
./SpikeSorter/template_plotter.m
./SpikeSorter/cluster_plotter_for_raw.m
./SpikeSorter/easy_cluster_plotter.m
./SpikeSorter/merging_plotterNEW.m
./SpikeSorter/merging_plotter.m
./SpikeSorter/plot_overlaping_templates.m
./SpikeSorter/get_plot_param.m
%interspike interval
./SpikeSorter/plot_neuron_events.m
./SpikeSorter/cluster_plotter2.m
./SpikeSorter/cluster_plotter3.m
./SpikeSorter/cluster_plotter.m
./SpikeSorter/plot_neuron_sequence.m
./NEO_SpikeSorter/plot_coeffs_vs_time.m
./NEO_SpikeSorter/plot_ch_based_sigs.m
./neuron/neurosim_plot_all.m
./plot_pktpk.m
./get_subplot_params.m
./plot_recording_blocks.m
./misc/plot_template_2d_del2_temporal.m
./misc/plot_raw_and_footprints.m
./misc/auto_memsplotter.m
./misc/hidens_plot_signalinsets.m
./misc/plot_neuron.m
./misc/plot_template_2d_temporal.m
./signalplotter.m
./plot_isi_glob_ts.m
./UNUSED/rasterplot.m
./UNUSED/plot_isscc.m
./conductivity/plot_distance_vs_amp.m
./conductivity/plot_signal_amplitude.m
./conductivity/ntk2_plot_dots.m
./conductivity/plot_line.m
./plot_values_on_els.m
./ian_functions/plot_white_noise.m
./Testbench/plot_ts_together.m
./Testbench/old_David/gntk_plot_traces.m
./Testbench/old_David/signal_ts_plotter.m
./Testbench/testbench_plots.m
./Testbench/presentation_plots.m
./Testbench/neuronplot.m
./Testbench/gntk_plot.m
./Testbench/plot_ts_only.m
./Testbench/plot_ts_compare.m
./Testbench/plot_ts.m
./ianjones/Matlab/plot_RGCs_bar_response.m
./tools/ICA/FastICA_25/icaplot.m

temp_neur = 
                 ts: [1x2345 double]
             ts_pos: [1x2345 double]
              fname: {[1x132 char]}
              finfo: {[1x1 struct]}
            ts_fidx: [1x2345 double]
             el_idx: [5786 5991 5888 5889 5990]
                  x: [1.4553e+03 1.4715e+03 1.4553e+03 1.4715e+03 1.4553e+03]
                  y: [1.1559e+03 1.1853e+03 1.1755e+03 1.1657e+03 1.1951e+03]
        event_param: [1x1 struct]
              trace: {[1x1 struct]  [1x1 struct]  [1x1 struct]  [1x1 struct]  [1x1 struct]}
           template: [1x1 struct]
         light_info: {1x8 cell}
          ELECTRODE: 5786
          tr_per_ts: [2345x35 double]
    template_per_ts: [1x35 double]






















