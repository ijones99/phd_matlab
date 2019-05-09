function flistFileNameID = get_flist_file_id(flist, suffixName)
% function flistFileNameID = get_flist_file_id(flist)
% optional argument: suffixname

if nargin==1
    suffixName = '';
end

if iscell(flist)
   if length(flist)==1
       flistCurr = flist{1};
   else
       flistCurr = flist{1};
       warning('only first flist value used for ID.\n');
   end
    
else
    flistCurr  = flist;
end

idNameStartLocation = strfind(flistCurr,'T');idNameStartLocation(1)=[];
idNameEndLocation = strfind(flistCurr,'.stream.ntk')-1;
flistFileNameID = strcat(flistCurr(idNameStartLocation:idNameEndLocation),suffixName);

end