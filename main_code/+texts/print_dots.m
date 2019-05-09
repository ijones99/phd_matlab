function print_dots(percentVal, numDots)
% print_dots(percentVal, numDots)

textDotsOut = '.';
textSpaces = ' ';
idxDotsPrint = ones(1, round(numDots*percentVal/100));
idxSpaces = ones(1,numDots - length(idxDotsPrint));
% fprintf(repmat('\b',1,numDots+2))
fprintf('[%s%s]\n',textDotsOut(idxDotsPrint),textSpaces(idxSpaces))


end