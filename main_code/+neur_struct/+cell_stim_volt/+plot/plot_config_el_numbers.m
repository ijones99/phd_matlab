function plot_config_el_numbers(out, varargin)
% function plot_config_el_numbers(out)
% 
% argument:
%   out.x
%   out.y
%   out.channel_nr
%
% varargin: 
%   h_fig: figure handle

hFig = [];
textOffset = [1 1];
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'h_fig')
            hFig = varargin{i+1};
        elseif strcmp( varargin{i}, 'text_offset')
            textOffset = varargin{i+1};
        end
    end
end

if isfield(out,'x_unique')
    xCoord = out.x_unique;
    yCoord = out.y_unique;
else
    xCoord = out.x;
    yCoord = out.y;
end


if ~isempty(hFig)
    for i=1:length(xCoord)
        text(xCoord(i)+textOffset(1), yCoord(i)+textOffset(2), num2str(out.channel_nr(i)));
    end
else
    for i=1:length(xCoord)
        text(xCoord(i)+textOffset(1), yCoord(i)+textOffset(2), num2str(out.channel_nr(i)));
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