function d = distance_point_to_line(pt, v1, v2)
%  d = DISTANCE_POINT_TO_LINE(pt, v1, v2)
%
% arguments:
%   pt: point
%   v1: first location along vector (2d or 3d)
%   v2: second location along vector (2d or 3d)
%
% source: http://www.mathworks.com/matlabcentral/answers/95608-is-there-a-function-in-matlab-that-calculates-the-shortest-distance-from-a-point-to-a-line


if length(pt) < 3
    if ~isrow(pt)
        pt = pt';
    end
    pt = [pt 0];
end


if length(v1) < 3
    if ~isrow(v1)
        v1 = v1';
    end
    v1 = [v1 0];
end


if length(v2) < 3
    if ~isrow(v2)
        v2 = v2';
    end
    v2 = [v2 0];
end


a = v1 - v2;

b = pt - v2;

d = norm(cross(a,b)) / norm(a);

end