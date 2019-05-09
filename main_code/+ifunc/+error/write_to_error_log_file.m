function write_to_error_log_file(funcName, Message)


fp = fopen('Error_Log_File.txt','a');
dateVal = datestr(now,0);
fprintf(fp, '%s -> %s -> %s\n', ...
    dateVal , funcName, Message);
fclose(fp);


end