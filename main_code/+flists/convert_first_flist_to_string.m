function flistText = convert_first_flist_to_string(flist)
% flistText = convert_first_flist_to_string(flist)

if iscell(flist)
   if length(flist) > 1 % multiple file names
       warning('Converting only first flist file name.\n');
   end
   flistText = flist{1};
   
else
    warning('Already a string; nothing to do.');
    flistText = flist;
end



end