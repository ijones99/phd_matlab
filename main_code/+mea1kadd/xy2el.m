function el = xy2el(x,y)
% el = XY2EL(x,y)

row = mea1kadd.y2row(y);
col = mea1kadd.x2col(x);

el = (row-1)*220+col-1;


end
