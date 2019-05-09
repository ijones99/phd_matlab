function fig2eps_all(selDirName)

fileNames = dir(fullfile(selDirName,'*.fig'));

for i=1:length(fileNames)
    figName = fileNames(i).name;
    
    fig2eps(figName, selDirName)
    
    
end

end