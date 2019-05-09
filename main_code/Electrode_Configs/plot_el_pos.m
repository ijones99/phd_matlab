function plot_el_pos(x,y,elNums, varargin)
% function PLOT_EL_POS(x,y,elNums)

plotStyle = '.';
textOffset = [3 3];
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'plot_style')
            plotStyle = varargin{i+1};
        if strcmp( varargin{i}, 'text_offset')
            textOffset = varargin{i+1};
            
        end
    end
end

plot(x,y,plotStyle);
text(x+textOffset(1),y+textOffset(2),num2str(elNums));




end