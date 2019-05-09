function intersectVals = check_routing(runName)

dirName = sprintf('../Configs/%s/',runName);
fileNames = dir(fullfile(dirName,'*el2fi*'));

elidxInFile = {};
for i=1:length(fileNames )
    [elidxInFile{i} chNoInFile] = ...
        get_el_ch_no_from_el2fi(dirName, fileNames(i).name);
end

intersectVals = elidxInFile{1};
for i=2:length(fileNames)
    intersectVals = intersect(elidxInFile{i},intersectVals);
end

end