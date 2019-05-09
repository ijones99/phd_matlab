function [x_offset y_offset] = unit_vector_components_from_angle(angleVec)
% [x_offset y_offset] = UNIT_VECTOR_COMPONENTS_FROM_ANGLE(angleVec)

y_offset = round2(sin(angleVec*pi/180),0.001);
x_offset = round2(cos(angleVec*pi/180),0.001);


end