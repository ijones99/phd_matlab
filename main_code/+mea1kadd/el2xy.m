function xyLoc = el2xy(elNum)
% xyLoc = EL2XY(elNum)
%
% get x y coordinates from el num

TL.xy = [239.5 222.0];
TR.xy = [4072 222];
BL.xy = [239.5 2304.5];
BR.xy = [4072 2304.5];

TL.el = 0;
TR.el = 219;
BL.el = 26180;
BR.el = 26399;

% rows
elsPerRow = [TR.el+1];
spac.xy(1) = (TR.xy(1) -TL.xy(1))/(elsPerRow-1);

% cols
elsPerCol = (BR.el+1)/elsPerRow;
spac.xy(2) = (BL.xy(2) -TL.xy(2))/(elsPerCol-1) ;

% x loc (starting at 0) - cols
colNum = rem(  elNum, elsPerRow);
xyLoc(1) = TL.xy(1) +spac.xy(1)*colNum;

% y loc (starting at 0) - rows
rowNum = floor(elNum/elsPerRow);
xyLoc(2) = TL.xy(2) +spac.xy(2)*rowNum;


end