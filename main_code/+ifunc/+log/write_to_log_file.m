function write_to_error_log_file(funcName, Message,varargin)
% write_to_error_log_file(funcName, Message)
% tip: to get function name, use p = mfilename('fullpath')
% VARAGIN
%   'dir': directory to write to
%
% ijones

P.dir = '';
P = mysort.util.parseInputs(P, varargin, 'error');

fp = fopen(fullfile(P.dir,'Log_File_Data_Processing.txt'),'a');
dateVal = datestr(now,0);
fprintf(fp, '%s -> %s -> %s\n', ...
    dateVal , funcName, Message);
fclose(fp);

end