function plot_config_el_numbers_multi_configs(out, ind, varargin)
% function plot_config_el_numbers(out)
% 
% argument:
%   out.x
%   out.y
%   out.channel_nr
%
% varargin: 
%   h_fig: figure handle

doUseConfigFile = 0;
hFig = [];
textOffset = [1 1];
fontFormat = {};
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'h_fig')
            hFig = varargin{i+1};
        elseif strcmp( varargin{i}, 'text_offset')
            textOffset = varargin{i+1};
        elseif strcmp( varargin{i}, 'use_config_file')
            doUseConfigFile = 1;
        elseif strcmp( varargin{i}, 'text_format')
            fontFormat = varargin{i+1};
        
        end
    end
end



if doUseConfigFile
    % find dirname
    dirName = sprintf('../Configs/%s/', out.run_name);
    el2fiName = out.configs_stim_volt.config{ind};
    [elidxInFile chNoInFile] = get_el_ch_no_from_el2fi(dirName, el2fiName);
elseif isfield(out,'channel_nr') && iscell(out.channel_nr)
    chNoInFile = out.channel_nr{ind};
else 
   fprintf('Error with channel numbers.\n'); 
end
    
    

if iscell(out.x)
    xCoord = out.x{ind};
    yCoord = out.y{ind};
else
    xCoord = out.x;
    yCoord = out.y;
    
end


if ~isempty(hFig)
    for i=1:length(xCoord)
        
        text(xCoord(i)+textOffset(1), yCoord(i)+textOffset(2), num2str(chNoInFile(i)),...
            'FontWeight', 'bold');
        
    end
else
    for i=1:length(xCoord)
        
        text(xCoord(i)+textOffset(1), yCoord(i)+textOffset(2), num2str(chNoInFile(i)), ...
            'FontWeight', 'bold');
        
    end
end

% get limits for x and y from data
xLimInData = minmax(xCoord)+[-100 100];
yLimInData = minmax(yCoord)+[-100 100];

% get limits for x and y from window settings
xLimWindow = get(gca,'xlim');
yLimWindow = get(gca,'ylim');

% if limits in data are less than those in window, change limits
if or(xLimWindow(2)< xLimInData(2),yLimWindow(2)< yLimInData(2))
   xlim( xLimInData );
   ylim( yLimInData );
end



end