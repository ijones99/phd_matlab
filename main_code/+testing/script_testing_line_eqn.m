
%%

angleIn = 45;

angleOut = psychtoolbox.angle_transfer_function(angleIn);

%
close all
plotCol = {'r','c','b'};

offset = 100%[-250 0 250];
figure, hold on, axis equal

for iOffset =1:length(offset)
    
    % get vector for angle
    [X,Y] = pol2cart(angleOut*pi/180,250);
     xyAngle(:,1) = [ 0 0 ]; 
    xyAngle(:,2) = [X Y];    
    
    % offset vector
    [X,Y] = pol2cart((angleOut+90)*pi/180,offset(iOffset));
    xyAngle2(:,1) = [ X Y ]; 
    xyAngle2(:,2) = [X Y];    
         
    xyOffset = xyAngle+xyAngle2;
    
    % plot
    plot(xyOffset(1,:),xyOffset(2,:),'--x','Color', plotCol{iOffset}), grid on
    
    pt = [10 10];
    v1 = xyOffset(:,1)';
    v2 = xyOffset(:,2)';
    
    d = geometry.distance_point_to_line(pt, v1, v2);
    
end
d
legend(num2str(offset'));
plot(0,0,'r+')
plot(pt(1),pt(2),'bx')
