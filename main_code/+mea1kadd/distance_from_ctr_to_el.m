function moveVal = center_on_MEA(elNum)
% moveVal = CENTER_ON_MEA(elNum)
%

% chip ctr
chipCtrXY = mea1kadd.mea_info;

% el location
elXY = mea1kadd.el2xy(elNum);

% movement
moveVal = (elXY-chipCtrXY.ctr.xy);


fprintf('>>>>>> Move x: %04.1f and y: %04.1f \n', moveVal(1), -moveVal(2));
    

end