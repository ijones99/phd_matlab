function [xFitPercent yFitPercent zInterp fitData zInterpMask] = find_rf_center_by_fitting_gaussian(Z,varargin)
% [xFitPercent yFitPercent zInterp fitData zInterpMask] = FIND_RF_CENTER_BY_FITTING_GAUSSIAN(Z)
% 
% PURPOSE: fit a Gaussian to a receptive field and find the center
%
% varargin: 
%   'do_plot'
%
% author: ijones adapted from ...
%   http://www.mathworks.com/matlabcentral/fileexchange/37087-fit-2d-gaussian-function-to-data
doPlotFit = 1;
doPlot = 0;
maskEdgeUm = 150;
numSqrsEdge = 12;
sqrDimUm = 75;
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'do_plot')
            doPlot = 1;
        elseif strcmp( varargin{i}, 'mask_size_um')
            maskEdgeUm = varargin{i+1};
        end
    end
end



if size(Z,1) > 30
    warning('Very large matrix input.')
end


% interp
Z = double(interp2(Z, 3));

pixPerSqrEdge = size(Z,1) / numSqrsEdge;
pixPerUm = pixPerSqrEdge/sqrDimUm;
mask = round(maskEdgeUm*pixPerUm);

% mean to zero
Z = Z-mean(mean(Z));
% change range to 0-2
Z = normalize_values(Z,[0 2]);
% flip to positive peak if necessary
if mean(mean(Z)) > 1
    Z = 2-Z;
end
if doPlot 
    figure, imagesc(Z);
end
zInterp = Z;
%% find rough max
if doPlot
    figure, imagesc(Z); hold on;
end
[rows,cols,vals] = find(Z>=max(max(Z))-0.5);
peakRangeXaxis = [min(cols) max(cols)];
peakRangeYaxis = [min(rows) max(rows)];
meanX = round(mean(cols));
meanY = round(mean(rows));
if doPlot
    plot(mean(cols),mean(rows),'ko');
end
% remove all except for center
zInterpMask = zeros(size(Z));

% range to cut out
rangeY = meanY-mask:meanY+mask; rangeY = rangeY(find(and(rangeY>0,rangeY<=size(Z,2))));
rangeX = meanX-mask:meanX+mask; rangeX = rangeX(find(and(rangeX>0,rangeX<=size(Z,1))));

zInterpMask( rangeY, rangeX) = Z( rangeY, rangeX);

if doPlot 
    figure, imagesc(zInterpMask);
end
Z = zInterpMask;


%% ---------settings---------------------
MdataSize = size(Z,1); % Size of nxn data matrix
% parameters are: [Amplitude, x0, sigmax, y0, sigmay, angel(in rad)]
x0 = [1,0,50,0,50,0]; %Inital guess parameters
x = [2,2.2,7,3.4,4.5,+0.02*2*pi]; %centroid parameters
noise = 10; % noise in % of centroid peak value (x(1))
InterpolationMethod = 'nearest'; % 'nearest','linear','spline','cubic'
FitForOrientation = 0; % 0: fit for orientation. 1: do not fit for orientation

xin = x; 
noise = noise/100 * x(1);
[X,Y] = meshgrid(-MdataSize/2:MdataSize/2-1);
xdata = zeros(size(X,1),size(Y,2),2);
xdata(:,:,1) = X;
xdata(:,:,2) = Y;
[Xhr,Yhr] = meshgrid(linspace(-MdataSize/2,MdataSize/2,300)); % generate high res grid for plot
xdatahr = zeros(300,300,2);
xdatahr(:,:,1) = Xhr;
xdatahr(:,:,2) = Yhr;

%% --- Fit---------------------
if FitForOrientation == 0
    % define lower and upper bounds [Amp,xo,wx,yo,wy,fi]
    lb = [0,-MdataSize/2,0,-MdataSize/2,0,-pi/4];
    ub = [realmax('double'),MdataSize/2,(MdataSize/2)^2,MdataSize/2,(MdataSize/2)^2,pi/4];
    [x,resnorm,residual,exitflag] = lsqcurvefit(@D2GaussFunctionRot,x0,xdata,Z,lb,ub);
else
    x0 =x0(1:5);
    xin(6) = 0;
    x =x(1:5);
    lb = [0,-MdataSize/2,0,-MdataSize/2,0];
    ub = [realmax('double'),MdataSize/2,(MdataSize/2)^2,MdataSize/2,(MdataSize/2)^2];
    [x,resnorm,residual,exitflag] = lsqcurvefit(@D2GaussFunction,x0,xdata,Z,lb,ub);
    x(6) = 0;
end
% plot 3d image
if doPlot
    figure;
    C = del2(Z);
    mesh(X,Y,Z,C); %plot data
    hold on;
    surface(Xhr,Yhr,D2GaussFunctionRot(x,xdatahr),'EdgeColor','none'); %plot fit
    axis([-MdataSize/2-0.5 MdataSize/2+0.5 -MdataSize/2-0.5 MdataSize/2+0.5 -noise noise+x(1)]);
    alpha(0.2);
    hold off
end

%% -----Plot profiles----------------
if doPlot | doPlotFit
    hf2 = figure(2);
    set(hf2, 'Position', [20 20 950 900]);
    alpha(0);
    subplot(4,4, [5,6,7,9,10,11,13,14,15]);
    imagesc(X(1,:),Y(:,1)',zInterp);
    set(gca,'YDir','reverse');
    colormap('jet');
    
    string1 = ['       Amplitude','    X-Coordinate', '    X-Width','    Y-Coordinate','    Y-Width','     Angle'];
    string2 = ['Set     ',num2str(xin(1), '% 100.3f'),'             ',num2str(xin(2), '% 100.3f'),'         ',num2str(xin(3), '% 100.3f'),'         ',num2str(xin(4), '% 100.3f'),'        ',num2str(xin(5), '% 100.3f'),'     ',num2str(xin(6), '% 100.3f')];
    string3 = ['Fit      ',num2str(x(1), '% 100.3f'),'             ',num2str(x(2), '% 100.3f'),'         ',num2str(x(3), '% 100.3f'),'         ',num2str(x(4), '% 100.3f'),'        ',num2str(x(5), '% 100.3f'),'     ',num2str(x(6), '% 100.3f')];
    
    k=1; fitData.amp = x(k);
    k=k+1; fitData.x_coord = x(k);
    k=k+1; fitData.x_width = x(k);
    k=k+1; fitData.y_coord = x(k);
    k=k+1; fitData.y_width = x(k);
    k=k+1; fitData.angle = x(k);
    
    text(-MdataSize/2*0.9,+MdataSize/2*1.15,string1,'Color','red')
    text(-MdataSize/2*0.9,+MdataSize/2*1.2,string2,'Color','red')
    text(-MdataSize/2*0.9,+MdataSize/2*1.25,string3,'Color','red')
end

xFitPercent = x(2)/(0.5*size(Z,2));
yFitPercent = -x(4)/(0.5*size(Z,1));

%% -----Calculate cross sections-------------
% generate points along horizontal axis
m = -tan(x(6));% Point slope formula
b = (-m*x(2) + x(4));
xvh = -MdataSize/2:MdataSize/2;
yvh = xvh*m + b;
hPoints = interp2(X,Y,Z,xvh,yvh,InterpolationMethod);
% generate points along vertical axis
mrot = -m;
brot = (mrot*x(4) - x(2));
yvv = -MdataSize/2:MdataSize/2;
xvv = yvv*mrot - brot;
vPoints = interp2(X,Y,Z,xvv,yvv,InterpolationMethod);

if doPlot | doPlotFit
    hold on % Indicate major and minor axis on plot
    
    % % plot pints
    % plot(xvh,yvh,'r.')
    % plot(xvv,yvv,'g.')
    
    % plot lins
    plot([xvh(1) xvh(size(xvh))],[yvh(1) yvh(size(yvh))],'r');
    plot([xvv(1) xvv(size(xvv))],[yvv(1) yvv(size(yvv))],'g');
    
    hold off;
    axis([-MdataSize/2-0.5 MdataSize/2+0.5 -MdataSize/2-0.5 MdataSize/2+0.5]);
end

%%
if doPlot | doPlotFit
    ymin = - noise * x(1);
    ymax = x(1)*(1+noise);
    xdatafit = linspace(-MdataSize/2-0.5,MdataSize/2+0.5,300);
    hdatafit = x(1)*exp(-(xdatafit-x(2)).^2/(2*x(3)^2));
    vdatafit = x(1)*exp(-(xdatafit-x(4)).^2/(2*x(5)^2));
    subplot(4,4, [1:3]);
    xposh = (xvh-x(2))/cos(x(6))+x(2);% correct for the longer diagonal if fi~=0
    plot(xposh,hPoints,'r.',xdatafit,hdatafit,'black');
    axis([-MdataSize/2-0.5 MdataSize/2+0.5 ymin*1.1 ymax*1.1]);
    subplot(4,4,[8,12,16])
    xposv = (yvv-x(4))/cos(x(6))+x(4);% correct for the longer diagonal if fi~=0
    plot(vPoints,xposv,'g.',vdatafit,xdatafit,'black');
    axis([ymin*1.1 ymax*1.1 -MdataSize/2-0.5 MdataSize/2+0.5]);
    set(gca,'YDir','reverse');
    figure(gcf) ;% bring current figure to front
end

end