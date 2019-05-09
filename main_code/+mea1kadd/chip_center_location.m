function chipCtrXY = chip_center_location
% chipCtrXY = CHIP_CENTER_LOCATION

TL.xy = [239.5 222.0];
TR.xy = [4072 222];
BL.xy = [239.5 2304.5];
BR.xy = [4072 2304.5];

TL.el = 0;
TR.el = 219;
BL.el = 26180;
BR.el = 26399;


% x val
rowLen = TR.xy(1) -TL.xy(1);
chipCtrXY(1) = TL.xy(1)+rowLen/2;

% y val
colLen = BL.xy(2) -TL.xy(2);
chipCtrXY(2) = TL.xy(2)+colLen/2;


end