function ntk2h5all( varargin )

dirName = '../proc';


%get file names of ntk2 files
ntkFileNames = dir(fullfile(dirName,'*ntk'));

for i=1:length(ntkFileNames)
    %check if h5 file exists and then convert otherwise
    if ~exist(fullfile(dirName,strrep(ntkFileNames(i).name,'.ntk','.h5')))
        mysort.mea.convertNTK2HDF(fullfile(dirName, ntkFileNames(i).name),'prefilter', 1);
    else
        fprintf('File %s already converted.\n', ntkFileNames(i).name);
        
    end
    progress_info(i, length(ntkFileNames))
    
end



end


