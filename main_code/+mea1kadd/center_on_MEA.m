function moveVal = center_on_MEA(elNum)
% moveVal = CENTER_ON_MEA(elNum)
%

% chip ctr
chipCtrXY = mea1kadd.mea_info;

% el location
elXY = mea1kadd.el2xy(elNum);

% movement
moveVal = (elXY-chipCtrXY.ctr.xy);
moveValPrint = -moveVal(2);

fprintf('>>>>>> Move x: %d and y: %d \n', round(moveVal(1)), round(moveValPrint));
    

end