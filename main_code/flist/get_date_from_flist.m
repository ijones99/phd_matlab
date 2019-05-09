function dateName = get_date_from_flist(flist)

if iscell(flist)
   flistString = flist{1};
else
    flistString = flist;
end

tLoc = strfind(flistString,'T');
dateStrLoc = [tLoc(2)-10 tLoc(2)-1];
dateName = flistString(dateStrLoc(1):dateStrLoc(2));

end