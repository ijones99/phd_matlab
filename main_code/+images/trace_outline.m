function boundary = trace_outline(imIn)
% boundary = TRACE_OUTLINE(imIn)
%
% to plot:
%   plot(boundary(:,2),boundary(:,1),'g','LineWidth',3);

BW = double(logical(imIn));
[row,col,vals] = find(BW==1);

boundary = bwtraceboundary(BW,[row(end), col(end)],'n');



end
