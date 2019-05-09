function make_flists(fileNum, flistName)

if length(fileNum) ~= length(flistName)
    fprintf('Error.\n');
    return
end

for i=1:length(fileNum)
    
   ifunc.flists.make_flist(fileNum(i), flistName{i}); 
    
end




end
