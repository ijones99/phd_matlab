function elNumbersRem = compare_files_between_dirs(dirName1, dirName2, fileType, flist)

filePattern = strcat('*.',fileType);

% get electrode numbers in directory
elNumbersDir1 = extract_el_numbers_from_files(  dirName1, filePattern , flist);
elNumbersDir2 = extract_el_numbers_from_files(  dirName2, filePattern , flist);

% get el numbers not processed
elNumbersRem = elNumbersDir1(find(~ismember(elNumbersDir1,elNumbersDir2))); 


end