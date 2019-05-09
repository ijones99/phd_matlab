%% Plot stimulability
figure, neur_struct.regional_scan.plot.plot_peak2peak_amplitudes(outRegional);

%% original
figure, hold on

z = max(outRegional.footprint.wfs,[],2)-min(outRegional.footprint.wfs,[],2);
x = outRegional.footprint.mposx;
y = outRegional.footprint.mposy;

xres=100;
yres=100;

xmax=max(x);
ymax=max(y);
xmin=min(x);
ymin=min(y);
xv = linspace(xmin, xmax,xres);
yv = linspace(ymin, ymax,yres);
[xi,yi] = meshgrid(xv,yv);
zi = griddata(x,y,z,xi,yi,'cubic');
contour(xi,yi,zi,40)
shading interp
grid on