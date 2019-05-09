function y=hidens_plot_signalinsets(rawdata, elmap, valid_channel, xmax, ymax, yoffset)


t=size(rawdata,1);

yscale=ymax/(max(max(rawdata))-min(min(rawdata)));
xscale=xmax/t;

xoffset=-xmax/2;

for i=valid_channel
    plot((0:t-1)*xscale+xoffset+elmap.x(i), rawdata(:,i)*yscale+yoffset+elmap.y(i))
end


