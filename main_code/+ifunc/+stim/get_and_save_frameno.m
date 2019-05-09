function get_and_save_frameno(flistName, stimName)
acqFreq = 2e4;
for i=1:length(flistName)
    flist = {}; eval(flistName{i});
    [dirName suffixName flist flistFileNameID streamName tName]= ...
        ifunc.data_proc.set_dirs_for_init_processing(flistName{i},stimName{i});
    
    mkdir(dirName.gp)
    if ~exist(fullfile(dirName.gp,strcat(['frameno_', flistFileNameID,'.mat'])))
        frameno = get_framenos(flist, acqFreq*60*60);
        save(fullfile(dirName.gp,strcat(['frameno_', flistFileNameID,'.mat'])), 'frameno');
        %     save shifted version of frameno
        shift_and_save_frameno_info(flistFileNameID);
    end
end
end