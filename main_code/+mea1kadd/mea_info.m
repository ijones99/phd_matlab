function chipCtrXY = mea_info
% chipCtrXY = MEA_INFO
%
% Info
%   corners info
%       xy location
%       el number
%   chip center location

chipCtrXY = [];

chipCtrXY.TL.xy = [239.5 222.0];
chipCtrXY.TR.xy = [4072 222];
chipCtrXY.BL.xy = [239.5 2304.5];
chipCtrXY.BR.xy = [4072 2304.5];

chipCtrXY.TL.el = 0;
chipCtrXY.TR.el = 219;
chipCtrXY.BL.el = 26180;
chipCtrXY.BR.el = 26399;


% x val
rowLen = chipCtrXY.TR.xy(1) -chipCtrXY.TL.xy(1);
chipCtrXY.ctr.xy(1) = chipCtrXY.TL.xy(1)+rowLen/2;

% y val
colLen = chipCtrXY.BL.xy(2) -chipCtrXY.TL.xy(2);
chipCtrXY.ctr.xy(2) = chipCtrXY.TL.xy(2)+colLen/2;

% row spacing
chipCtrXY.elsPerRow = [chipCtrXY.TR.el+1];
% col spacing
chipCtrXY.elsPerCol = (chipCtrXY.BR.el+1)/chipCtrXY.elsPerRow;
% spacing
chipCtrXY.spacing_xy(1) = (chipCtrXY.TR.xy(1) -chipCtrXY.TL.xy(1))/(chipCtrXY.elsPerRow-1);
chipCtrXY.spacing_xy(2) = (chipCtrXY.BL.xy(2) -chipCtrXY.TL.xy(2))/(chipCtrXY.elsPerCol-1) ;

end