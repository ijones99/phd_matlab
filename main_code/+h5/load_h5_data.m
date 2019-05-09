function mea1 = load_h5_data(flist,varargin)
% function MEA1 = load_h5_data(flist)

forceFileConversion = 0;
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'force_file_conversion')
            forceFileConversion = 1;
        end
    end
end


mea1 = {};
for i=1:length(flist)
    h5FileName = strrep(flist{i},'ntk','h5');
    if forceFileConversion
        eval(sprintf('!rm %s', h5FileName));
    end
    if ~exist(h5FileName,'file')
        mysort.mea.convertNTK2HDF(flist{i},'prefilter', 1);
    end
    mea1{i} = mysort.mea.CMOSMEA(h5FileName, 'useFilter', 0, 'name', 'Raw');
    fprintf('Loading...%3.0f percent done.\n', i/length(flist)*100);
end






end