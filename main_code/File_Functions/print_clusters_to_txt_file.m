function print_clusters_to_txt_file(fileDir, filePattern, fileOutputName, varargin)

% set output dir to current dir (default)
outputDir = pwd;

% set sort inds to on
doSortInds = 1;

if ~isempty(varargin)
   for i=1:length(varargin)
      if strcmp(varargin{i}, 'set_output_dir') 
        outputDir = varargin{i+1};
      elseif strcmp(varargin{i}, 'file_inds') 
          fileInds = varargin{i+1};
      elseif strcmp(varargin{i}, 'sort_inds')
          doSortInds = varargin{i+1};
      end
   end
end

% get file names 
fileNames = dir(fullfile(fileDir,filePattern));

% fileInds default
if isempty(fileInds)
    fileInds = [1:length(fileNames)];
end

if doSortInds
   fileInds = sort(fileInds); 
end

% open file
fid = fopen(fullfile(outputDir,fileOutputName),'a');

for i=1:length(fileInds)
    fprintf(fid, strcat([fileNames(fileInds(i)).name, '\t\t', num2str(fileInds(i)),'\n']));
end

% print list of ids at end
fprintf(fid,'\n \n');
fprintf(fid,'[ %s ]', num2str(fileInds));


fclose(fid);

end