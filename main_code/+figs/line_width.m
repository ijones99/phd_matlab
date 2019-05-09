function line_width_all(lineWidth)
% LINE_WIDTH_ALL(lineWidth)

a=findobj(gcf); % get the handles associated with the current figure

allaxes=findall(a,'Type','axes');
alllines=findall(a,'Type','line');

set(allaxes,'LineWidth',lineWidth)
set(alllines,'Linewidth',lineWidth);


end