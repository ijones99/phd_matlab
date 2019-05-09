function outputCell = csv2cell(fileName)

fid = fopen(fileName);

outputCell = fscanf(fid,'%s');

fclose(fid)


end