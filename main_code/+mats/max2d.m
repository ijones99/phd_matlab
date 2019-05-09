function [row, col, ind, value] = max2d(X)
% [row, col, ind, value] = MAX2D(X)

[value,ind]=max(X(:));
[row,col] = ind2sub(size(X),ind);

end