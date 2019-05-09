function get_meta_and_data_file_struct(expDate)

dirName = ['/net/bs-filesvr01/export/group/hierlemann/recordings/Mea1k/ijones/', expDate,'/data/']

fileNames = filenames.get_filenames('*',dirName);

namesOnly = {};
metaFileIdx = [];

for i = 1:length(fileNames)
    
    if fileNames(i).name ~= '.' & fileNames(i).name ~= '..'
        namesOnly{end+1} = fileNames(i).name;
    end
    
    
end
