function create_csv_file_with_headers(fileName, headerCell)
% create_csv_file_with_headers(fileName, headerCell)

%# write line-by-line
fid = fopen(fileName,'wt');
for i=1:size(headerCell,2)-1
    fprintf(fid, '%s, ', headerCell{i});
end
fprintf(fid, '%s', headerCell{i+1});



fclose(fid);

end