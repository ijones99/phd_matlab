function [ctrLoc maxAmp ] = find_center_with_contour(x,y,z, varargin)
%[ ctrLoc maxAmp ] = FIND_CENTER_WITH_CONTOUR(x,y,z, varargin)

xyRes = [100 100];
hFig = [];
nContourLines = 40;
doPlotTopo = 1;
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'xy_res')
            xyRes = varargin{i+1};        
        elseif strcmp( varargin{i}, 'h_fig')
            hFig = varargin{i+1};
        elseif strcmp( varargin{i}, 'n_contour_lines')
            nContourLines = varargin{i+1};
        elseif strcmp( varargin{i}, 'plot_surf')
            doPlotTopo = 0;
        
        end
    end
end

xres = xyRes(1);
yres = xyRes(2);

xmax=max(x);
ymax=max(y);
xmin=min(x);
ymin=min(y);
xv = linspace(xmin, xmax,xres);
yv = linspace(ymin, ymax,yres);
[xi,yi] = meshgrid(xv,yv);
zi = griddata(x,y,z,xi,yi,'cubic');

maxAmp = max(max(zi));
[I J] = find( zi == maxAmp);
ctrLoc.x = xi(I,J);
ctrLoc.y = yi(I,J);


end