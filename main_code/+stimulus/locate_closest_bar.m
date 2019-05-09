function locate_closest_bar(degreesIn, offsetVec, neurPtLocRelCtr)

% y = mx+b
% line1 = [x1 y1]
%         [x2 y2]
% get slope, slopeInit
slopeInit = geometry.deg2slope(degreesIn);

figure, hold on
dVec = [];
for i=1:length(offsetVec)
    x = 0;        
    y = -offsetVec(i)/cos( degreesIn*pi/180);
    
    line1 = geometry.line_from_formula(slopeInit, y);
    dVec(i) = geometry.perpendicular_dist_pt_to_line(line1, neurPtLocRelCtr);
    
    
    plot(line1(:,1),line1(:,2));
    axis square, xlim(150*[-2 2]), ylim(150*[-2 2])
end
plot(neurPtLocRelCtr(1),neurPtLocRelCtr(2),'ro')



end