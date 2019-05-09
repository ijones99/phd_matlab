function auto_preprocess_ntk_data
%%
% there are assumed to be files remaining to be processed
noUnprocFilesRemaining = 0;

while noUnprocFilesRemaining == 0
    
 
    % there are unprocessed files
    unprocFilesExist = 1;
    
    % load preProcessInfoNtk
    cd ~
    load('~/preProcessInfoNtk.mat')
    
    % look for unprocessed files
    unprocessedFileFound = 0;
    
    for i=1:length(preProcessInfoNtk)
        if strcmp(preProcessInfoNtk{i}.status,'unprocessed')
            unprocessedFileFound = 1;
            break
        end
        
    end
    
    % if all files have been processed, then program can quit on next round
    if i == length(preProcessInfoNtk)
        noUnprocFilesRemaining = 1;
    end
    
    
    % "i" contains index for group to process
    
    % cd to directory
    eval(['cd ', preProcessInfoNtk{i}.directory ]);
    fprintf(strcat((['cd ', preProcessInfoNtk{i}.directory ])));
    % ---------- Settings ----------
    numEls = 7;
    % suffixName = '_orig_stat_surr';
    flistName = preProcessInfoNtk{i}.flist;
    suffixName = strrep(flistName ,'flist','');
    [ suffixName flist flistFileNameID dirNameFFile  dirName.St ...
        dirName.El dirName.Cl ] = setup_for_ntk_data_loading(flistName, suffixName);
    clear elConfigInfo
    elConfigClusterType = 'overlapping'; elConfigInfo = get_el_pos_from_nrk2_file;
    
    % look for unprocessed electrodes    
    elNumbersDir = extract_el_numbers_from_files(  dirName.El, '*.mat', flist);
    
    % check to see whether there any in common with those requested for
    % processing
    [junk, elIndsAlreadyProc] = (ismember( preProcessInfoNtk{i}.els,elNumbersDir));

    % find inds of els remaining to process
    elIndsToProcess = find(elIndsAlreadyProc == 0);
    
    if ~isempty(elIndsToProcess) % if there are electrodes to process, then proceed
                 
        i, pause(0.5)
        fprintf('There are electrodes to process\n');
        elNumbersToProc = preProcessInfoNtk{i}.els(elIndsToProcess);
        fprintf('Electrodes to process:\n');
        elNumbersToProc
        preProcessInfoNtk{i}.status = 'processed'; % mark as processed
        save('~/preProcessInfoNtk.mat', 'preProcessInfoNtk'); % save to file
        % process data
        try
            pre_process_data(suffixName, flistName, 'config_type','overlapping', 'sel_by_els',elNumbersToProc, 'kmeans_reps', 10);
        catch
            fid = fopen('Error_Log_Processing.txt','a')
            t = now;
            c = datevec ( t );
            s = datestr ( c, 0 );
                        
            fprintf('%s: error preprocessing %s %s\n',s,suffixName, flistName  )
            fprintf(fid, '%s: error preprocessing %s %s\n',s,suffixName, flistName  )
            fclose(fid);
        end
        
    else % otherwise, mark as processed
        fprintf('There are not any electrodes to process\n');
        preProcessInfoNtk{i}.status = 'processed'; % mark as processed
        save('~/preProcessInfoNtk.mat', 'preProcessInfoNtk'); % save to file
        
        
        
        
    end
    
    % repeat
    
    
end
exit
%%

end