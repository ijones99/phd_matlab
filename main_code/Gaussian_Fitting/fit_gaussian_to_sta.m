function [percentWithinAperture gaussianFittedImage maskedFitImage result] = ...
    fit_gaussian_to_sta( xi, yi, apertureDiameterPx , staStackDir,gaussianFitDir, ...
    clusterName, varargin)
% guassianFit 
% [xi,yi] = meshgrid(ceil(-630/2)+1:floor(630/2), ceil(-630/2)+1:floor(630/2));

% vars
doSaveFile = 0;
doPlot = 0;
if ~isempty(varargin)
    for j=1:length(varargin)
        

        if strcmp(varargin{j},'do_plot')
            doPlot =1;
        elseif strcmp(varargin{j},'do_save_file')
            doPlot = 1;    
        end
    end
end

fileName = dir(fullfile(staStackDir,strcat('sta_fr_sta_*',clusterName, '*')));

load(fullfile(staStackDir,fileName(1).name));

staImageStack = savedFrames; clear savedFrames;

edgeLength = size(staImageStack,1);

[indsSection mask] = get_circle_inds(edgeLength, apertureDiameterPx,'center');
[indsSectionRing maskRing] = get_circle_inds(edgeLength, apertureDiameterPx,'ring');
% find minima of sta
stdFrames = std(double(staImageStack),[],3);

imPeakVal = max(max(abs(stdFrames)));
peakInd = find(stdFrames==imPeakVal(1));
[yPeak, xPeak ] = ind2sub(size(stdFrames ),peakInd(1));
STA = squeeze(staImageStack(yPeak, xPeak, :));

% find frame where STA is largest
[Y,frameToFit] = max(STA);

% fit to image
result = autoGaussianSurf(xi,yi,double(staImageStack(:,:, frameToFit)));

% get x,y of peak position
[yPeak,xPeak,vals] = find(result.G == max(max(result.G))); 
yPeak = yPeak(1); xPeak = xPeak(1);

% get value sigma away from that value
valueWithinOneSigma = result.G(yPeak, (xPeak - round(result.sigmax)));

% save Gaussian fit
gaussianFittedImage = result.G;
% set all values within sigma to 1
gaussianFittedImage(find(gaussianFittedImage>=valueWithinOneSigma))=1;
gaussianFittedImage(find(gaussianFittedImage<valueWithinOneSigma))=0;

% get value of area
areaWithinSigmaRadius = sum(gaussianFittedImage);

% apply mask to this image
maskAppliedImage = gaussianFittedImage.*mask;

% calculate percent this area within stimulation aperture
percentWithinAperture = sum(maskAppliedImage)/areaWithinSigmaRadius;

maskedFitImage = result.G.*mask;

if doPlot
    h = figure; hold on % make figure
    subplot(2,2,1); axis square;imagesc(staImageStack(:,:, frameToFit)+maskRing*max(max(staImageStack(:,:, frameToFit)))), title(strcat(['STA for ', clusterName])) % plot orig image
    minOrigImValue = min(min(staImageStack(:,:, frameToFit)));maxOrigImValue = max(max(staImageStack(:,:, frameToFit))); % values for color bar range
    caxis([minOrigImValue maxOrigImValue]); %set colorbar range
    subplot(2,2,2); axis square;imagesc(result.G +maskRing) % plot fitted image
    minImValue = min(min(result.G));maxImValue = max(max(result.G)); % values for color bar range
    caxis([minImValue maxImValue]); %set colorbar range
    subplot(2,2,3); axis square;imagesc(maskedFitImage+maskRing); caxis([minImValue maxImValue]); %set colorbar range % plot fitted image
    subplot(2,2,4); hold on
    plot(staImageStack(yPeak,:,frameToFit) ,'b'); %plot original image data
    plot(result.G(yPeak,:)+mean(staImageStack(yPeak,:,frameToFit))-mean(result.G(yPeak,:)) ,'r');
    % cutoff line
    valueWithinOneSigmaAdjusted = valueWithinOneSigma+ ...
        mean(staImageStack(yPeak,:,frameToFit))-mean(result.G(yPeak,:));
    plot([0 length(result.G(yPeak,:))], [valueWithinOneSigmaAdjusted ...
        valueWithinOneSigmaAdjusted],'k')
end

if doSaveFile
   exportfig(h,fullfile(gaussianFitDir,strcat('Gaussian_Fit_Mask_', ...
    clusterName)), ...
    'fontmode','fixed', 'fontsize',8,'Color', 'rgb' ); 
end

end