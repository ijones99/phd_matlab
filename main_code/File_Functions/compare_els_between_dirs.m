function [elNumbers fileInds] = compare_els_between_dirs(dir1, dir2, filePattern1, filePattern2, flist)


elNumbersDir1 = extract_el_numbers_from_files(  dir1, filePattern1 , flist);%file numbers in first dir
elNumbersDir2 = extract_el_numbers_from_files(  dir2, filePattern2 , flist);% file numebrs in second dir

elNumbers = elNumbersDir1(find(~ismember(elNumbersDir1,elNumbersDir2))); % get el numbers in dir2

fileInds = get_file_inds_from_el_numbers(dir1,filePattern1 , elNumbers);



end