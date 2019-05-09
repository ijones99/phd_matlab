function convert_all_ntk_to_h5_files(dirName, flist, doPreFilter)
% function convert_all_ntk_to_h5_files(dirName, flist, doPreFilter)

for i=1:length(flist)
    if ~exist(strrep(flist{i},'.ntk','.h5'))
        mysort.mea.convertNTK2HDF(flist{i},'prefilter', doPreFilter);
    else
        fprintf('Already converted.\n');
    end
    fprintf('progress %3.0f\n', 100*i/length(flist));
end

end