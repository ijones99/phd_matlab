function stim_settings_file(Settings)

dirNameBase = 'log_settings';
if ~exist(dirNameBase,'dir')
    mkdir(dirNameBase);
end
dirName = [dirNameBase, '/', datestr(now, 'ddmmmyyyy')];
if ~exist(dirName,'dir')
    mkdir(dirName);
end

dateStr = now;
stimName = strrep(Settings.STIM_NAME,'.mat','');
fileName = sprintf( '%s_T%s_%s',datestr(dateStr, 'ddmmmyyyy'), ...
    datestr(dateStr, 'HHMMSS'), stimName)

save(fullfile(dirName,fileName),'Settings')



end