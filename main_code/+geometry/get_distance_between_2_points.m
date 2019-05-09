function [ distance] = get_distance_between_2_points(x, y, x1, y1)
% [ distance] = GET_DISTANCE_BETWEEN_2_POINTS(x, y, x1, y1)

if nargin < 3
    x1 = 0; y1 = 0;
end

distance = sqrt((x-x1).^2 +(y-y1).^2 );

end