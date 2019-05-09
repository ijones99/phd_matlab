function dateVal = get_dir_date

currDir = pwd;
slashLoc = strfind(currDir, '/');
dateVal = currDir(slashLoc(end-1)+1:slashLoc(end)-1);


end