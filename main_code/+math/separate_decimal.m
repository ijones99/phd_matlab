function [beforeDec afterDec ] = separate_decimal(myNum)
% [beforeDec afterDec ] = SEPARATE_DECIMAL(myNum)

beforeDec = floor(myNum);


afterDec = myNum-beforeDec;



end
