function ratioVal = ratio(matIn, opIn, valIn)
% ratioVal = ratio(argIn)
% Arguments:

% evaluate
eval(sprintf('numeratorVal = length(find(matIn %s %d));',opIn, valIn)); 

ratioVal = numeratorVal/length(matIn);




end