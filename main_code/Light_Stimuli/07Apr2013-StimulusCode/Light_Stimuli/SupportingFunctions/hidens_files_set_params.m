function hidens_files_set_params(path, search_string, param_name, value)
% Set recording parameters on a bunch of files

% TODO: have a list of file as input argument instead of path and search_string
% (and do the search outside this function if needed).
% This would allow greater flexibility in choosing the files.

% TODO: allow to set more than parameter for single call.


% Get path of proc directory (where params files are)
cur_path=pwd;
cd('../proc');
proc_path=pwd;
cd(cur_path);

% Search files on proc dir
file_list=dir([proc_path '/' search_string]);

% For each file in list
file_idx=1;
while file_idx <= size(file_list,1)
    
    % Get complete file path
    dummy.fname=[proc_path '/' file_list(file_idx).name];
    
    % Get number of available rec_analysing parameters
    rec_param_ending_list=get_rec_param_ending_list(dummy);
    
    if isempty(rec_param_ending_list)
        rec_param_ending_list{1}='';
    end
    
    for rec_param_idx=1:size(rec_param_ending_list,2)
        rec_param_cur_ending=rec_param_ending_list{rec_param_idx};
        fprintf('rec anal params %d - ending (%s)\n', rec_param_idx, rec_param_cur_ending);
        

        dummy=load_params(dummy, 'recfile');
        fprintf('***************************************\n');
        fprintf('*\n*  %s\n*\n', file_list(file_idx).name);

        skip_file=0;

        dummy.recfile_param
        
        skip_param=0;
        
        if not(skip_file) && not(skip_param)
            skip_file=ntk_get_lock(dummy);
            if skip_file
                disp('file is locked couldn''t set parameter');
            end
        end

        if not(skip_file) && not(skip_param)
            dummy.recfile_param.(param_name)=value;
            save_params(dummy, 'recfile');
        end
    end
    ntk_remove_lock(dummy);
    file_idx=file_idx+1;
end
disp('done');


