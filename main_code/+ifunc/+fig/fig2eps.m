function fig2eps(figName, dirNameRead, dirNameWrite)
% fig2eps(figName, dirNameRead, dirNameWrite)

if nargin < 3
    dirNameWrite = dirNameRead;
end

h = open(fullfile(dirNameRead,figName));
% saveas(h, fullfile(dirNameWrite,strrep(figName,'.fig','.eps')),'depsc');
exportfig(h, fullfile(dirNameWrite,strrep(figName,'.fig','.eps')) ,'Resolution', 120,'Color', 'rgb')

end