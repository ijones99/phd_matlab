function titleexclude(titleText, varargin)


textToExclude{1} = '_';
textToReplace{1} = '-';

for i=1:length(textToExclude)
   
    titleText = strrep(titleText,textToExclude{i}, textToReplace{i});
    
end

title(titleText);

end