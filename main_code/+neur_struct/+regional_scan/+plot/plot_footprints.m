function plot_footprints(footprint, varargin)
% PLOT_FOOTPRINTS(footprint)
%
% varargin
%   format_for_neurorouter (no arg req)


formatForNeurorouter = 0;
scaleFP = 15;
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'format_for_neurorouter')
            formatForNeurorouter = 1;
        elseif strcmp( varargin{i}, 'scale')
            scaleFP= varargin{i+1};
        end
    end
end

if formatForNeurorouter
    plot_footprints_simple([footprint.mposx ...
        footprint.mposy], footprint.wfs, ...
        'input_templates','hide_els_plot','format_for_neurorouter',...
        'plot_color','b', 'flip_templates_ud','flip_templates_lr','scale', scaleFP);
    
else
    plot_footprints_simple([footprint.mposx ...
    footprint.mposy], footprint.wfs, ...
    'input_templates','hide_els_plot',...
    'plot_color','b', 'scale', scaleFP);

    
end

end