function proc_spec_feature(stimNames, dirList, flistNames)
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
    for iStim = 1:length(flistNames) % go through flists
        % set up directories
        [dirName suffixName flist flistFileNameID streamName tName]= ...
            ifunc.data_proc.set_dirs_for_init_processing(flistNames{iStim},stimNames{iStim});
        % Prepare H5 File Access
        h5File = strrep(strrep(flist,'../proc/',''),'ntk','h5');
        h5File = h5File{1};
        dateVal = get_dir_date
        hdmea = ifunc.h5.prepare_h5_file_access(dateVal, h5File);
        [selElsIdx elsToExcludeIdx] = ifunc.el_config.get_sel_el_ids(hdmea);
        
        neurNames = extract_neur_names_from_files(dirName.st,'*_00*.mat');
        
        % load flist
        flist = {}; eval(flistNames{iStim});
        
        for iFile = 1:length(neurNames)
            data = ifunc.profiles.load_profiles_file(neurNames{iFile},stimNames{iStim});
              
            
            save_profiles_file(neurNames{iFile}, dirList{iDir}, data);


        end
        
    end
end
end