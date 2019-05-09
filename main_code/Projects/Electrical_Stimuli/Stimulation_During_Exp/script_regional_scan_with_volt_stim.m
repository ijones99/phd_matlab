%% send configurations to chip while stimulating with voltage %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ------------------ SETTINGS ------------------ %
ipAddress = 'bs-dw17';
neurolizerSlotNo = 0;
recordTime = 5; % seconds
% ---------------------------------------------- %
fileNameConfig = dir([[ scanConfigDir,'/'], '*hex.nrk2']);
for i=1:length(fileNameConfig)
    fileNameConfig(i).name = strrep(fileNameConfig(i).name,'.hex.nrk2','');
end
if scanConfigDir(end) ~= '/';
    scanConfigDir(end+1) = '/';
end

for i=1:length(fileNameConfig)
    % Convert hex to cmdraw.nrk2
    i
    doConvertHex = 0;
    if ~exist(sprintf('%s%s.cmdraw.nrk2', scanConfigDir, fileNameConfig(i).name)) || doConvertHex
        convert_config_hex2cmdraw(['../Configs/', scanConfigDir], fileNameConfig(i).name)
    end
    
    % Send config to chip
    send_config_to_chip(['../Configs/', scanConfigDir], fileNameConfig(i).name)
    pause(0.5);
    hidens_startSaving(neurolizerSlotNo,ipAddress,'','');
    pause(recordTime);
    hidens_stopSaving(neurolizerSlotNo,ipAddress);
    pause(0.5);
    fprintf('-------------- Progress %.0f -------------- /n',100*i/length(fileNameConfig))
end
disp('Done.')