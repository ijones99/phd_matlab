function outVec = xy2vec(xyPos)
% outVec = XY2VEC(xyPos)

if ~iscolumn(xyPos.x)
    xyPos.x = xyPos.x'
    xyPos.y = xyPos.y';
end

outVec =zeros(length(xyPos.x),2);
outVec(:,1) = xyPos.x;
outVec(:,2) = xyPos.y;




end