function run_auto_sort(flistNames, stimNames, varargin)
acqFreq = 2e4;

P.expDate = get_dir_date;
P = mysort.util.parseInputs(P, varargin, 'error');

for j=1:length(stimNames)
    ifunc.file.convert_ntk2_files_to_h5(P.expDate);
    flist = {}; eval(flistNames{j});
    
    % flistNames{1} = 'flist_noise_movie';stimNames{1} = 'Noise_Movie';
    % set up directories
    [dirName suffixName flist flistFileNameID streamName tName]= ...
        ifunc.data_proc.set_dirs_for_init_processing(flistNames{j},stimNames{j});
    elConfigInfo = get_el_pos_from_nrk2_file;
    elConfigInfo.channelNr = convert_el_numbers_to_chs(flist{j}, elConfigInfo.selElNos);
    % Prepare H5 File Access
    h5File = strrep(strrep(flist,'../proc/',''),'ntk','h5');
    h5File = h5File{1};
    dateVal = get_dir_date
    hdmea = ifunc.h5.prepare_h5_file_access(dateVal, h5File);
    
    selectedPatches = select_patches_exclusive(7, elConfigInfo );
    
    for i=1:length(selectedPatches)
        groupsidx{i} = selectedPatches{i}.selElNos;
    end
    ifunc.proc.sort_cluster_based(P.expDate, flist, groupsidx);
    
    [selElsIdx elsToExcludeIdx] = ifunc.el_config.get_sel_el_ids(hdmea);

    extract_spiketimes_from_auto_cluster_files( flistFileNameID,...
        dirName.auto_sorter_gps)
    %>> Calculate STA info
    neurNames = extract_neur_names_from_files(dirName.st,'*_00*.mat');
    % do init processing
    neurIdx = 1:length(neurNames);
    ifunc.auto_run.initial_neuron_processing(flistNames{1},stimNames{1}, [], [], ...
        get_dir_date,'neurIdx', neurIdx)
end