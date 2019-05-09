function savefigtofile(h, dirOutputFig, fileName)
% FUNCTION SAVEFIGTOFILE(DIROUTPUTFIG, FILENAME)
% 
% Arguments:
%   DirOutputFig: directory to save file to
%   fileName: name of file


if ~isdir(dirOutputFig)
    fprintf('Directory does not exist. Creating directory...\n');
    mkdir('dirOutputFig');
end
exportfig(gcf, fullfile(dirOutputFig,strcat(fileName,'.ps')) ,'Resolution', 120,'Color', 'rgb')

end