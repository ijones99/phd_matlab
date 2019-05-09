function font_size(fontSize)
%  FONT_SIZE(fontSize)
% set font size for all

set(gca,'FontSize',fontSize)
set(findall(gcf,'type','text'),'FontSize',fontSize)


end