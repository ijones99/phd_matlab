function plot_config_labels(out, labelChoice, varargin)
% function plot_config_el_numbers(out)
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

if strcmp(labelChoice,'el_idx')
    for i=1:length(out.x)
        text(out.x(i)+textOffset(1), out.y(i)+textOffset(2), num2str(out.el_idx(i)));
    end
elseif strcmp(labelChoice,'ch_number')
    for i=1:length(out.x)
        text(out.x(i)+textOffset(1), out.y(i)+textOffset(2), num2str(out.channel_nr(i)));
    end
end



end