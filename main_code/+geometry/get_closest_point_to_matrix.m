function [idx minDist] = get_closest_point_to_matrix(xAll, yAll,xySel)

if isrow(xAll)
    xAll = xAll';
end

if isrow(yAll)
    yAll = yAll';
end

xyAll = [xAll yAll];

xySelMat = repmat(xySel,size(xyAll,1),1);

distances = sqrt((xyAll(:,1)-xySel(:,1)).^2+(xyAll(:,2)-xySel(:,2)).^2);

[minDist,idx] = min(distances);

end