function fig2other(figName, dirNameRead, dirNameWrite,conv2Type)
% fig2eps(figName, dirNameRead, dirNameWrite,conv2Type)

if ~strcmp(conv2Type,'.')
    conv2TypeMod = strcat('.',conv2Type);
end

h = open(fullfile(dirNameRead,figName));
% saveas(h, fullfile(dirNameWrite,strrep(figName,'.fig','.eps')),'depsc');
exportfig(h, fullfile(dirNameWrite,strrep(figName,'.fig',conv2TypeMod )) ,'Resolution', 120,'Color', 'rgb', ...
    'Format', conv2Type)

end