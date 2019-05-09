function area_out = auc(x,y)
% area_out = AUC(x,y)

x = [x(1) x x(end)];
y = [0 y 0];


area_out = polyarea(x, y);



end