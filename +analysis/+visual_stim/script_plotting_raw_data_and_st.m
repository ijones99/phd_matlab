[flistFileNameID flist flistName] = wrapper.proc_and_spikesort_save_data( )
runNo = input('Enter run no >> ');
flistName = sprintf('flist_spots_n_%02d',runNo);
flist = {}; eval(flistName);
suffixName = strrep(flistName,'flist', '');
flistFileNameID = get_flist_file_id(flist{1}, suffixName);
dirNameFFile = strcat('../analysed_data/',   flistFileNameID);
dirNameSt = strcat('../analysed_data/',   flistFileNameID,'/03_Neuron_Selection/');
dirNameEl = strcat('../analysed_data/',   flistFileNameID,'/01_Pre_Spikesorting/');
dirNameCl = strcat('../analysed_data/',   flistFileNameID,'/02_Post_Spikesorting/')

sortChoice = input('spikesort? [y/n]','s')
if strcmp(sortChoice,'y')
    fileType = 'mat';
    elNumbers = compare_files_between_dirs(dirNameEl, dirNameCl, fileType, flist)
    selInds = input(sprintf('sel inds of el numbers to sort [1:%d]> ',length(elNumbers)));
    sort_ums_output(flist, 'add_dir_suffix',suffixName, 'sel_els_in_dir', ...
        elNumbers(selInds), 'specify_output_dir', flistFileNameID)%elNumbers([1:10]+10*(segmentNo-1))); %'sel_els_in_dir',...
%     selEls(end));%'all_in_dir')%;% 'all_in_dir')%); %,
end

%% EXTRACT TIME STAMPS FROM SORTED FILES 
% auto: create st_ files & create neuronIndList.mat file with names of all
% ...neurons found.
extract_spiketimes_from_cl_files(flist, 'add_dir_suffix',suffixName )
%% plot raw data with stim changes, spiketimes, etc.
flist = {}; flist{end+1} =  '../proc/Trace_id1588_2014-06-17T10_18_39_27.stream.ntk'
% load ../analysed_data/T10_18_39_17_wn_checkerboard_n_01/03_Neuron_Selection/st_5055n28.mat
ntk2 =  load_ntk2_data(flist,10*60*2e4, 'keep_only', 90);
figure, hold on
interStimTime = 0.5;
stimChangeTs = get_stim_start_stop_ts2(neur.spt.frameno,interStimTime);
plot(ntk2.sig)
hold on, m = 1;for i=1:2:length(stimChangeTs), text(stimChangeTs(i), 90, num2str(spotsSettings.dotDiam(m))),m=m+1;end
ylim([-100 100])
plot.raster(st_5055n3.ts*2e4,'height',160,'color','g')
% plot.raster(st_5052n79.ts*2e4,'height',2,'color','c')
plot.raster(stimChangeTs,'height',160,'color','r')





%%
plot.raster(stimChangeTs,'height',10,'color','k')

