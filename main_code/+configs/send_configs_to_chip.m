function send_configs_to_chip(scanConfigDir, fileNameConfig, varargin)
% SEND_CONFIGS_TO_CHIP(scanConfigDir, fileNameConfig, varargin)
%
% varargin
%   'ip_address'
%   'slot_no'
%   'rec_time'
%
%
ipAddress = 'bs-dw17';
machineName= evalc(['!hostname'])
if isempty(strfind(machineName,ipAddress))
    error(sprintf('Using wrong machine! %s\n',machineName))
    return
end
neurolizerSlotNo = 0;
recordTime = 25; % seconds
% ---------------------------------------------- %




% format names
if isfield(fileNameConfig,'name')
   fileNameConfig2 = {};
   for i=1:length(fileNameConfig)
       fileNameConfig2{i} = fileNameConfig(i).name;
       
   end
   fileNameConfig = fileNameConfig2;
end


% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'ip_address')
            ipAddress = varargin{i+1};
        elseif strcmp( varargin{i}, 'slot_no')
            neurolizerSlotNo = varargin{i+1};
        elseif strcmp( varargin{i}, 'rec_time')
            recordTime = varargin{i+1};
        end
    end
end

if scanConfigDir(end) ~= '/';
    scanConfigDir(end+1) = '/';
end

for i=1:length(fileNameConfig)
    
    % Send config to chip
    send_config_to_chip([ scanConfigDir], fileNameConfig{i})
    fprintf('send to chip: %s\n', strcat([ scanConfigDir], fileNameConfig{i}));
    pause(0.5);
    hidens_startSaving(neurolizerSlotNo,ipAddress,'','');
    pause(recordTime);
    hidens_stopSaving(neurolizerSlotNo,ipAddress);
    pause(0.5);
    fprintf('-------------- Progress %.0f -------------- /n',100*i/length(fileNameConfig))
end

disp('Done.')




end