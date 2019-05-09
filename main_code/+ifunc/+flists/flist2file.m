function fileName = flist2file(flist)
fileNameStartLoc = strfind(flist{1},'Trace');
fileName = strrep(flist{1}(fileNameStartLoc:end),'.ntk','');


end