function adjustedXY = array2beamer_xy_adjustment(inputXY)

% FOR TESTING
% figure, hold on, axis square, xlim([-40 40]),ylim([-40 40]), grid on
% XY = [-10 20];
% XYadj = beamer.array2beamer_xy_adjustment(XY);
% plot(XY(1),XY(2),'ob');
% plot(XYadj(1),XYadj(2),'or');


fprintf('Not yet working!!')
return;

% adjustedXY = array2beamer_mat_adjustment(inputXY)
% NOTE: inputXY is relative to the center of the config!
%
% rotate 90 degrees counterclockwise and flipud

startAngleRadian = atan(inputXY(2)/inputXY(1));
adjAngleRadian =startAngleRadian + (90/360)*2*pi(); 

lineLength = sqrt(inputXY(1)^2+inputXY(2)^2);

% rotate
yCCRot = lineLength*sin(adjAngleRadian);
xCCRot = lineLength*cos(adjAngleRadian);

adjustedXY = [xCCRot -yCCRot];
end