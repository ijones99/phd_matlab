function strOut = dir_to_command(strIn)
% strOut = DIR_TO_COMMAND(strIn)

locMatlabEnd = strfind(strIn,'Matlab')+7;
strOut = strIn(locMatlabEnd:end);
strOut = strrep(strOut,'.m','');
strOut = strrep(strOut,'/+','.');
strOut = strrep(strOut,'+','');
strOut = strrep(strOut,'/','.');
end