function cell2csv(fileName, cellToWrite, permissionsVal)
% cell2csv(fileName, cellToWrite,permissionsVal)

if nargin < 3
    permissionsVal = 'a';
    
end

%# write line-by-line
fid = fopen(fileName,permissionsVal);

if fid>0
for i=1:size(cellToWrite,1) % go along rows
    
    for j=1:size(cellToWrite,2)-1 % go along cols
        if ~isempty(cellToWrite{i,j})
            fprintf(fid, '%s,', cellToWrite{i,j});
            fprintf('%s,', cellToWrite{i,j});
        else
            fprintf(fid, ',');
            fprintf(',');
        end
    end
        if ~isempty(cellToWrite{i,j+1})
            fprintf(fid,'%s,', cellToWrite{i,j+1});
            fprintf('%s,', cellToWrite{i,j+1});
        else
            fprintf(fid,',');
            fprintf(',');
        end
    fprintf(fid,'\n');
    fprintf('\n');
end

fclose(fid);
else
    
   fprintf('Error opening file\n') 
end
end