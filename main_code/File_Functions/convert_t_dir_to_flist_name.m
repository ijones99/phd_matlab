function flistName = convert_t_dir_to_flist_name( tDir )
% flistName = convert_flist_name_to_t_dir( tDir )

underscoreLoc = strfind(tDir,'_');
flistName = strcat('flist', tDir(underscoreLoc(4):end));




end