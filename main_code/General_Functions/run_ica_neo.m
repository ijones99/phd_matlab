% reconstruct the ICs efficiently

cd ~/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/11Jun2009/Matlab/
clear all
flist={}
flist_11_26_59_6x17_s183
siz = 600000; % how many samples of data to load (5 s)
ntk=initialize_ntkstruct(flist{20}, 'hpf', 500, 'lpf', 3000);
[ntk2 ntk]=ntk_load(ntk, siz);
ntk2=detect_valid_channels(ntk2,1);

%% NEO_ICA


% do neo ica time_shifting
out=neo_ica_time_shifting(ntk2,'n_ica',20,'n_shifts',4,'xcorr_thr',0.6,'max_samples',400000);

% some vizualization
plot_coeffs_vs_time(out,ntk2)
comp=2;
plot_ch_based_sigs(out,ntk2,comp,'max_samples',100000)

% compute independent components
ics=compute_ics(ntk2,out);


