function plot_el_pos_and_number(elNums, varargin)
% function PLOT_EL_POS(x,y,elNums)

plotStyle = '.';
textOffset = [3 3];
doPlotEls = 1;
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'plot_style')
            plotStyle = varargin{i+1};
        elseif strcmp( varargin{i}, 'text_offset')
            textOffset = varargin{i+1};
        elseif strcmp( varargin{i}, 'plot_els')
            doPlotEls = 1;
            
        end
    end
end


all_els=hidens_get_all_electrodes(2);

elNums = reshape(elNums,1,size(elNums,1)*size(elNums,2));
localinds = find(ismember(all_els.el_idx,elNums));
x = all_els.x(localinds);
y = all_els.y(localinds);

if doPlotEls
    plot(x,y,plotStyle);
end
text(x+textOffset(1),y+textOffset(2),num2str(all_els.el_idx(localinds)'));





end