
%%
suffixName = '_orig_stat_surr_med';
flist = {}; flist_orig_stat_surr_med;
suffixName = '_orig_mouse';
flist = {}; flist_orig_mouse;

% suffixName = '_dyn_surr_med_dyn_surr_shuff_pix_10_50_90';
% flist = {}; flist_dyn_surr_med_dyn_surr_shuff_pix_10_50_90;

numEls = 7; 
flistFileNameID = get_flist_file_id(flist{1}, suffixName);
% dir names
dirNameSt = strcat('../analysed_data/',   flistFileNameID,'/03_Neuron_Selection/');
dirNameCl = strcat('../analysed_data/',   flistFileNameID,'02_Post_Spikesorting/');
dirNameFFile = strcat('../analysed_data/',   flistFileNameID);

%%
dateValTxt = '17July2012';
dirNameSTA = strcat(fullfile('../Figs/',   flistFileNameID, '/raster'));
selNeuronInds = [1]
textLabel = {...
  'orig'; 'stat_surr'}  

%     'DynSurr'; 'DynSurrShuff'; 'Pix10'; 'Pix50'; 'Pix90' }
    
    

plot_raster_for_natural_movie(flistFileNameID, flist, dateValTxt, dirNameSTA, selNeuronInds, textLabel)