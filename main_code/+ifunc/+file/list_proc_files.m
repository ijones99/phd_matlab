function list_proc_files
% get file names
ntkFileNames = dir('../proc/*.ntk');

for i=1:length(ntkFileNames)
   fprintf('(%d) %s\n',i, ntkFileNames(i).name);
    
    
end



end