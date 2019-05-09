function output = get_circle(center, r, numDivs)
% output = get_circle(center, r)

ang=0:0.01:2*pi; 
ang = linspace(0,2*pi,numDivs);
xp=r*cos(ang);
yp=r*sin(ang);
output = {};
output.x = center(1)+xp;
output.y = center(2)+yp;

end
