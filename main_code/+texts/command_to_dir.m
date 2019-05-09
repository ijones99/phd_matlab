function strOut = command_to_dir(strIn)
% strOut = COMMAND_TO_DIR(strIn)

lastDotLoc = strfind(strIn,'.'); 
strIn(lastDotLoc(end)) = '/';
strOut = ['+', strrep(strIn,'.','/+')];

strOut = ['~/Matlab/', strOut]


strOut = [strOut, '.m'];


end