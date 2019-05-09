function plot_text_labels_on_meal1k(x,y,labels, varargin)
% function PLOT_EL_POS(x,y,elNums)

plotStyle = '.';
textOffset = [3 3];
doPlotEls = 1;
textColor = 'k';
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'plot_style')
            plotStyle = varargin{i+1};
        elseif strcmp( varargin{i}, 'text_offset')
            textOffset = varargin{i+1};
        elseif strcmp( varargin{i}, 'plot_els')
            doPlotEls = 1;
        elseif strcmp( varargin{i}, 'color')
            textColor = varargin{i+1};
            
        end
    end
end

if isrow(labels)
    labels = labels';
end


text(x+textOffset(1),y+textOffset(2),num2str(labels),'Color', textColor );





end