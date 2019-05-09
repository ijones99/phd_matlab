function [results p] = fit_ellipses_to_rf(imData, varargin)

% [results p] = fit_ellipses_to_rf(imData, varargin)
% Variable Arguments 
%     plot_gaussian
%     plot_ellipse
%     fig_handle
%     title_text

doPlotGaussian = 0;
doPlotEllipse = 0;
figHandle = [];
titleText = '';
meshgridSize = 30;
faceColor = 'b';
lineWidth = 1;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'plot_gaussian')
            doPlotGaussian = 1;
        elseif strcmp( varargin{i}, 'plot_ellipse')
            doPlotEllipse = 1;
          elseif strcmp( varargin{i}, 'fig_handle')
            figHandle = varargin{i+1} ;  
          elseif strcmp( varargin{i}, 'title_text')
            titleText = varargin{i+1} ;
        elseif strcmp( varargin{i}, 'meshgrid_size')
            meshgridSize = varargin{i+1} ;
        elseif strcmp( varargin{i}, 'color')
            faceColor = varargin{i+1} ;
        elseif strcmp( varargin{i}, 'line_width')
            lineWidth= varargin{i+1} ;
        
        end
        
    end
end

[xi,yi] = meshgrid(1:meshgridSize,1:meshgridSize);

% masking
imData = double(imData);
% zi = max(max(imData))-imData;
% avgVal = mean(mean(zi))*1.2;
% zi(find(zi<avgVal)) = 0;
imMask =create_mask(imData, 'threshold_multiple',3);%
zi = imMask.*imData;


% get result for fitting Gaussian
results = autoGaussianSurf(xi,yi,zi)

% flip gaussian fit to correct orientation (if necessary)
ctrRFVal = abs(imData(round(results.y0), round(results.x0)));
meanImData = abs(mean(mean(imData)));
ctrRFValFitted = abs(results.G(round(results.y0), round(results.x0)));
meanFittedGaussian = abs(mean(mean(results.G)));
if (ctrRFVal>meanImData) - (ctrRFValFitted>meanFittedGaussian) ~= 0 % if both 
    ... do not have the same orientation (max val to mean)
   results.G = max(max(results.G))-results.G;      
end


if doPlotGaussian % plot, if requested
    figure, hold on
    subplot(2,1,1)
    
    imagesc(imData), axis square
    title(strcat(titleText,'Calculated RF Original'));
    subplot(2,1,2),
    imagesc((results.G)), axis square
    title(strcat(titleText,'Fitted Gaussian'));
end
% calc. ellipses

p = calculateEllipse(results.x0, results.y0, results.sigmax, results.sigmay, ...
    results.angle*180/(pi));

if doPlotEllipse % plot, if requested
    if ~isempty(figHandle), figure(figHandle), else, figure, end
    plot(p(:,1), p(:,2),'Color', faceColor,'LineWidth',lineWidth,'MarkerFaceColor',[0.5 0.5 0.5]), axis equal
    title(strcat('Ellipse Fitted to RF'));
end