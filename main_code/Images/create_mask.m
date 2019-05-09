function maskIm = create_mask(inputIm, varargin)
%function outputIm = create_mask(inputIm, thresholdMultiple)
%       arguments
%       plot_mask 
%       plot_im_and_mask
%       threshold_multiple: multiple of the normalized image
%  
% varargin:
%   'plot_mask'
%   'plot_im_and_mask'
%   'threshold_multiple'
%   'threshold_percent'
%   'no_erosion'  
% 
% author: ijones

doPlotMask = 0;
doPlotImAndMask = 0;
thresholdMultiple = 3;
thresholdPercentAmp = [];
doErosion = 1;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'plot_mask')
            doPlotMask = 1;
        elseif strcmp( varargin{i}, 'plot_im_and_mask')
            doPlotImAndMask = 1;
        elseif strcmp( varargin{i}, 'threshold_multiple')
            thresholdMultiple = varargin{i+1};   
        elseif strcmp( varargin{i}, 'threshold_percent')
            thresholdPercentAmp = varargin{i+1};
        elseif strcmp( varargin{i}, 'no_erosion')
            doErosion = 0;
        end
    end
end


% take only abs value
inputIm = abs(inputIm);

% get mean
meanInputIm = mean(mean(inputIm));

% subtract mean
normIm = abs(inputIm-meanInputIm);

% threshold image
threshIm = normIm;
if isempty(thresholdPercentAmp)
    threshIm(threshIm<thresholdMultiple*mean(mean(threshIm))) = 0;
else
    p2pMin = min(min(threshIm));
    p2pMax = max(max(threshIm));
    p2pAmp = p2pMax-p2pMin;
    threshIm(threshIm<p2pMin+p2pAmp*thresholdPercentAmp/100)=0;
    
end
% binarized image
binarizedIm = ((threshIm));

% erode image
if doErosion
    se = strel('disk',1);
    erodedIm = double(logical(imerode(binarizedIm,se)));
    se2 = strel('disk',4);
    maskIm = double(imdilate(erodedIm,se2));
else
    maskIm = double(binarizedIm);
end

if doPlotMask
    figure, imagesc(maskIm);
end
% plot to compare image and mask
if doPlotImAndMask
    figure, hold on,
    subplot(2,1,1), imagesc(inputIm), axis square
    subplot(2,1,2), imagesc(maskIm), axis square
    
end


end