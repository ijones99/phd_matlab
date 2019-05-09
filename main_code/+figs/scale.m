function scale(h,xP,yP)
% SCALE(h,xP,yP)

scrSize = get(0,'screensize');

scrSizeScaled = scrSize.*[1 1 0.01*xP 0.01*yP];
figs.set_size_fig(h,scrSizeScaled);


end