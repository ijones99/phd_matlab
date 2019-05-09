function chgStr = replace_characters(chgStr, charToReplace)
% chgStr = replace_characters(chgStr, charToReplace)
%
% charToReplace: cell with char to replace, followed by char to insert

for i=1:length(charToReplace)
    
    chgStr=strrep(chgStr, charToReplace{i}(1), charToReplace{i}(2));
end


end