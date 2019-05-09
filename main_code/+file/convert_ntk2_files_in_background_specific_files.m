function convert_ntk2_files_in_background_specific_files()
% CONVERT_NTK2_FILES_IN_BACKGROUND(checkInterval)


dirPath = '../proc/';


% get file names
[fileNamesNtk idxFileByDate]= get_file_names_from_dir(dirPath, '*.ntk','get_sort_by_datenum_inds');
fileNamesH5 = get_file_names_from_dir(dirPath, '*.h5');

fileNamesNtk = strrep(fileNamesNtk,'.ntk','');
fileNamesH5 = strrep(fileNamesH5,'.h5','');



for i=1:length(idxFileByDate)
    fprintf('%d) %s\n', i, fileNamesNtk{idxFileByDate(i)})
end

idxSelFiles = input('Select file idx to process >> ' );

for i=1:length(idxSelFiles)
    fprintf('%s\n', fileNamesNtk{idxFileByDate(idxSelFiles(i))})
end

junk = input('\nok? >> ');



for i=1:length(idxSelFiles)
    %flist name
    flist = sprintf('../proc/%s.ntk', fileNamesNtk{idxFileByDate(idxSelFiles(i))});
    
    mysort.mea.convertNTK2HDF(flist,'prefilter', 1);
    fprintf('Converted file %s.\n', flist)
    
end




end