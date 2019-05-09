function line2 = angle_and_offset_to_line(degIn, offset)
% 
% purpose: angle for line





[x y] = geometry.unit_vector_components_from_angle(degIn);
[x_offset y_offset] = geometry.unit_vector_components_from_angle(offset);
x_offset = x_offset*abs(offset);
y_offset = y_offset*abs(offset);
line2 = [0 0; x y]+[x_offset y_offset ;x_offset y_offset ];


% FOR TESTING
figure, hold on, %xlim([-50 50]),ylim([-50 50]), axis square
lineX = line2; plot(lineX(:,1),lineX(:,2),'b','LineWidth', 2);plot(lineX(1,2),lineX(2,2),'bo')

end

