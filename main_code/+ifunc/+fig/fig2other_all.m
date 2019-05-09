function fig2other_all(selDirName,conv2Type, varargin)
P.fileSearchStr = [];
P = mysort.util.parseInputs(P, varargin, 'error');

if ~isempty(P.fileSearchStr)
    fileNames = dir(fullfile(selDirName,strcat('*', P.fileSearchStr,'*.fig')));
else
    fileNames = dir(fullfile(selDirName,'*.fig'));
end

for i=1:length(fileNames)
    figName = fileNames(i).name;
    ifunc.fig.fig2other(figName, selDirName,selDirName,conv2Type);
    
    
end

end