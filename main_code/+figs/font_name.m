function font_name(fontName)
% FONT_NAME(fontName)
% set font name for all

set(gca,'fontName',fontName)
set(findall(gcf,'type','text'),'fontName',fontName)

end
