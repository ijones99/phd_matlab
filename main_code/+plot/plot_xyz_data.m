function plot_peak2peak_amplitudes(x,y,z, varargin)
% function plot_peak2peak_amplitudes(outRegional)
%
% varargin
%   xy_res: [# #] to specify resolution of plot


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

if isempty(hFig)
    if doPlotTopo
        contour(xi,yi,zi,nContourLines,'LineWidth',2);
    else
        surf(xi,yi,zi,nContourLines);
    end
else
    if doPlotTopo
        contour(hFig,xi,yi,zi,nContourLines,'LineWidth',2);
    else
        surf(hFig,xi,yi,zi,nContourLines);
    end
end
shading interp
% grid on
% axis equal

end