function flistName = convert_t_dir_to_suffix_name( tDir )
% flistName = convert_t_dir_to_suffix_name( tDir )

underscoreLoc = strfind(tDir,'_');
flistName = tDir(underscoreLoc(4):end);




end