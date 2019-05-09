function [selEls  areaOutInds] = get_electrodes_in_donut(center, rIn, rOut)

all_els=hidens_get_all_electrodes(2);
all_els.x_unique = unique(all_els.x);
all_els.y_unique = unique(all_els.y);

outputIn = geometry.get_circle(center, rIn,50);
outputOut = geometry.get_circle(center, rOut,50);

x = all_els.x;
y = all_els.y;

areaIn = inpolygon(x,y,outputIn.x,outputIn.y);
areaInInds = find(areaIn);
areaOut = inpolygon(x,y,outputOut.x,outputOut.y);
areaOutInds = find(areaOut);

ctrInds = (find(ismember(areaOutInds, areaInInds)));
areaOutInds(ctrInds) = [];

selEls = all_els.el_idx(areaOutInds);

% figure, plot(x(areaOutInds),y(areaOutInds),'*b')

% plot(xv,yv,x(in),y(in),'r+',x(~in),y(~in),'bo')
