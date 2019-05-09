function fileName = flist2stream(flist)
% fileName = flist2stream(flist)

fileNameStartLoc = strfind(flist{1},'Trace');
fileName = strrep(flist{1}(fileNameStartLoc:end),'.ntk','');


end