function elNumbersRem = compare_els_between_dir_elconfiginfo(elConfigInfo, dirName, filePattern, flist)

% get electrode numbers in directory
elNumbersDir = extract_el_numbers_from_files(  dirName, filePattern , flist);
elNumbersConfig = elConfigInfo.selElNos;

% get el numbers not processed
elNumbersRem = elNumbersConfig(find(~ismember(elNumbersConfig,elNumbersDir))); 


end