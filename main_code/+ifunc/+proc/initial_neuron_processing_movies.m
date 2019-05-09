function initial_neuron_processing_movies(stimNames, dirList, flistNames, doExtractSt)
acqFreq = 2e4;

if ischar(dirList)
    dirListTemp{1} = dirList; clear dirList;
    dirList = dirListTemp;
end
%go through directories
for iDir = 1:length(dirList)
    % go to dir
    if iscell(dirList)
        cd(dirList{iDir});
    else
        cd(dirList);
    end
    % load flist
    for iStim = 1:length(flistNames)
        % set up directories
        [dirName suffixName flist flistFileNameID streamName tName]= ...
            ifunc.data_proc.set_dirs_for_init_processing(flistNames{iStim},stimNames{iStim});
        % Prepare H5 File Access
        h5File = strrep(strrep(flist,'../proc/',''),'ntk','h5');
        h5File = h5File{1};
        dateVal = get_dir_date
        hdmea = ifunc.h5.prepare_h5_file_access(dateVal, h5File);
        [selElsIdx elsToExcludeIdx] = ifunc.el_config.get_sel_el_ids(hdmea);
        mkdir(dirName.gp)
        if ~exist(fullfile(dirName.gp,strcat(['frameno_', flistFileNameID,'.mat'])),'file')
            frameno = get_framenos(flist, acqFreq*60*60);
            save(fullfile(dirName.gp,strcat(['frameno_', flistFileNameID,'.mat'])), 'frameno');
            % save shifted version of frameno
            shift_and_save_frameno_info(flistFileNameID);
        end
        %>> Calculate STA info
        if ~exist(dirName.st, 'dir')
            mkdir(dirName.st);
        end
        if doExtractSt
            
            % extract spike times
            extract_spiketimes_from_auto_cluster_files( flistFileNameID, dirName.auto_sorter_gps)
            
        end
        
        neurNames = extract_neur_names_from_files(dirName.st,'*_00*.mat');
        
        % do init processing
        neurIdx = 1:length(neurNames);
        
        % load flist
        flist = {}; eval(flistNames{iStim});
        
        ifunc.profiles.save_basic_profile(dirName, neurNames,stimNames{iStim}, flistFileNameID, ...
            [], [], hdmea,'stimulus_type', 'Movies');       
        
    end
end
end