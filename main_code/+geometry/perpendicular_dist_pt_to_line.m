function d = perpendicular_dist_pt_to_line(line1, pt1)
% PERPENDICULAR_DIST_PT_TO_LINE(line1, pt1)
%
% d = abs(y-mx-b)/sqrt(m^2+1); b=intercept; m = slope
%
% line1 = [x1 y1]
%         [x2 y2]

[b m] = geometry.line_formula( line1 );

if ~isinf(m)
    x = pt1(1); y = pt1(2);
    d = abs(y-m*x-b)/sqrt(m^2+1);
else % line is parallel
    d = abs(pt1(1)-line1(1,1));
end


end