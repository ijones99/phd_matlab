function plot_peak2peak_amplitudes(wfs,x,y, varargin)
% function plot_peak2peak_amplitudes(outRegional)
%
% varargin
%   xy_res: [# #] to specify resolution of plot


xyRes = [100 100];
hFig = [];
nContourLines = 40;
minAmp = [];
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'xy_res')
            xyRes = varargin{i+1};        
        elseif strcmp( varargin{i}, 'h_fig')
            hFig = varargin{i+1};
        elseif strcmp( varargin{i}, 'n_contour_lines')
            nContourLines = varargin{i+1};
        elseif strcmp( varargin{i}, 'min_amp')
            minAmp = varargin{i+1};
        end
    end
end

xres = xyRes(1);
yres = xyRes(2);

z = max(wfs,[],2)-min(wfs,[],2);

if ~isempty(minAmp)
   idxSubMin = find(z <  minAmp);
   z(idxSubMin) = 0;
end

xmax=max(x);
ymax=max(y);
xmin=min(x);
ymin=min(y);
xv = linspace(xmin, xmax,xres);
yv = linspace(ymin, ymax,yres);
[xi,yi] = meshgrid(xv,yv);
zi = griddata(x,y,z,xi,yi,'cubic');

if isempty(hFig)
    contour(xi,yi,zi,nContourLines);
else
    contour(hFig,xi,yi,zi,nContourLines);
end
shading interp
% grid on
% axis equal

end