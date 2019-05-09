function [staFrames staTemporalPlot plotInfo bestSTA h] = ...
    make_sta( spikeTimes, stimFrames, frameInd, varargin)
% time domain is acquisition timepoints (e.g. 2e4 Hz)
% OUTPUT:
%   file: staTemporalPlot_[neuronName].mat, matrix: staTemporalPlot
%   file: staFrames_[neuronName].mat, matrix: staFrames
%   file: plotInfo.mat, matrix: plotInfo
plotAperatureOutline = 1;

% init vars
neuronName='';
flistFileNameID = '';
dirSTA = strcat('../Figs/responses/White_Noise/');
doPrint = 0;
fontSize = 12;
apertureDiam = 500;
stimWidth = 1200;
doSave = 0;

if iscell(frameInd)
   error('frameno should not be a cell.') 
end

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'neuron_name')
            neuronName = varargin{i+1};
        elseif strcmp( varargin{i}, 'flist_name')
            flistFileNameID = varargin{i+1};
        elseif strcmp( varargin{i}, 'output_dir')
            dirSTA = varargin{i+1};
        elseif strcmp( varargin{i}, 'do_print')
            doPrint = 1;
        elseif strcmp( varargin{i}, 'do_save')
            doSave = 1;
        end
    end
end

if length(spikeTimes)< 40
    warning('Too few spikes');
end

% ---- vars ----- %
acqRate = 2e4; % acquisition rate
titleName = strrep(strcat(flistFileNameID,'_', neuronName),'_', '-');

% ---- account for projector delay ---- %
% projectorDelay_smp = 860;
% frameInd = [zeros(1,projectorDelay_smp) frameInd]; % add extra zeros to push stim frame forward in time

% ---- times from which to make the movie around the spike ---- %
staAveragingTimesRelToSpike_msec = -1:.040:.1;
staAveragingTimesRelToSpike_samples = staAveragingTimesRelToSpike_msec*acqRate;

% ---- init sta array ---- %
staFrames = single(zeros(size(stimFrames,1), size(stimFrames,2),...
    length(staAveragingTimesRelToSpike_samples)));

% --- make fig ---- %
scrsz = get(0,'ScreenSize');
% [left bottom width height]
if doPrint
    h=figure('Position',[1 1 scrsz(3)/2 scrsz(4)]);
else 
    h=[];
end

numCols = 4;
numRows = ceil(length(staAveragingTimesRelToSpike_samples)/numCols);

% rowsCols

for i=1:length(staAveragingTimesRelToSpike_samples); % cycle through alclearl the timepoints around the spike occurrence
    
    timeStampsToAverage = spikeTimes+staAveragingTimesRelToSpike_samples(i); % these are the timestamps at which we want to average
    timeStampsToAverage(find(timeStampsToAverage<=0))=[]; % remove zero values
    timeStampsToAverage(find(timeStampsToAverage>length(frameInd))) = [];
    selFrameInds = round(timeStampsToAverage);
    selFrameInds(find(selFrameInds<=0)) = [];% ensure that by rounding, no zeros are introduced!
    frameIndsToAvg = frameInd(selFrameInds);
    frameIndsToAvg(find(frameIndsToAvg<=0)) = [];% remove zero values
%     staFrames(:,:,i) = mean(stimFrames(:,:,frameIndsToAvg),3);
staFrames(:,:,i) = std(stimFrames(:,:,frameIndsToAvg),[],3);
end

outputNormMax = max(max(max(staFrames)));
outputNormMin = min(min(min(staFrames)));

if doPrint
    set(gca,'FontSize',fontSize);
    for i=9:length(staAveragingTimesRelToSpike_samples); % plot STAs
        
        subplot(numRows, numCols,i-8);
        imagesc( staFrames(:,:,i));hold on
        if plotAperatureOutline
            imWidth = size(staFrames(:,:,i),1);
%             circle([imWidth/2 imWidth/2],(imWidth*apertureDiam/stimWidth)/2,imWidth,'k--',2);
        end
        axis off, axis square, caxis([ outputNormMin outputNormMax]);
%         title(strcat([num2str(round(staAveragingTimesRelToSpike_samples(i)/20)), ...
%             ' msec']), 'Fontsize',fontSize)
        
    end
end




% get sta temporal plot at center location
staIms = [];
stdFrames = std(single(staFrames),[],3);
imPeakVal = max(max(abs(stdFrames)));% get max value of std
peakInd = find(abs(stdFrames)==imPeakVal(1));
[yPeak, xPeak ] = ind2sub(size(stdFrames ),peakInd(1));
staIms = squeeze(staFrames(yPeak, xPeak, :));
staIms = staIms(staIms>0);
imWidth = size(staIms,1);
if doPrint
    % Plot the staIms temporal data
    subplotLocations = [numRows*numCols-3:numRows*numCols-2];
    subplotLocations= [subplotLocations-4 subplotLocations ];
    subplot(numRows, numCols, subplotLocations );
    x_axis= round(staAveragingTimesRelToSpike_samples/20);
    set(gca,'FontSize',fontSize)
    plot(x_axis, staIms,'LineWidth',2,'Color','k');
else
    x_axis= round(staAveragingTimesRelToSpike_samples/20);
end
staTemporalPlot.x_axis = x_axis;

staTemporalPlot.staIms = staIms;
if doPrint
    ylabel('STA','Fontsize',fontSize);
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position') - [0 .1 0])
    xlabel('Time Before Spike [s]','FontSize',fontSize);
    
    % plot example RF
    subplotLocations = [numRows*numCols-1:numRows*numCols];
    subplotLocations= [subplotLocations-4 subplotLocations ];
    subplot(numRows, numCols, subplotLocations );
end
baselineSTAVal = mean(staIms(1:4));
diffFromBaseline = abs(staIms - baselineSTAVal);
[junk bestSTA ] = max(diffFromBaseline); bestSTA = bestSTA(1);

if doPrint
    imagesc( staFrames(:,:,bestSTA));hold on;
end

saveBestFrame = 0;
if saveBestFrame
    %     dirSTA = '/home/ijones/Matlab/Downloaded_Functions/Gaussian_Fit_2/Best_STA_Frames';
    mkdir(dirSTA)
    bestSTAIm = staFrames(:,:,bestSTA);
    save_to_profiles_file(neuronName, 'White_Noise', 'bestSTAIm', bestSTAIm,1);
    %     save_to_profiles_file(neuronName, 'White_Noise', 'staIms', staIms,1)
    %     fprintf('saved STA images for %s\n', neuronName);
end

if doPrint
    if plotAperatureOutline
        imWidth = size(staFrames(:,:,bestSTA),1);
%         circle([imWidth/2 imWidth/2],(imWidth*apertureDiam/stimWidth)/2,imWidth,'k--',2);
    end
    axis off, axis square, caxis([ outputNormMin outputNormMax]);
    
    uicontrol('Style', 'text', 'String', titleName, ...
        'HorizontalAlignment', 'center', 'Units', 'normalized', ...
        'Position', [0 .94 1 .05], 'BackgroundColor', [.8 .8 .8], 'FontSize',14);
end
dirMatOutput = strcat('../analysed_data/',strrep(dirSTA,'../analysed_data/',''));
if ~exist(dirMatOutput,'dir')
    mkdir(dirMatOutput)
end
staTemporalPlot.staIms =  staTemporalPlot.staIms';
% save_to_profiles_file(neuronName, 'White_Noise', 'staTemporalPlot', staTemporalPlot,1)% save STA curve
% save_to_profiles_file(neuronName, 'White_Noise', 'staFrames', staFrames,1)% save save best frame

plotInfo.apertureDiam = apertureDiam;
plotInfo.imWidth = imWidth;
plotInfo.stimWidth = stimWidth;
% save_to_profiles_file(neuronName, 'White_Noise', 'plotInfo', plotInfo,1)%
% fprintf('saved STA data for %s\n', neuronName);

if doSave
    exportfig(gcf, fullfile(dirSTA,strcat(titleName,'.ps')) ,'Resolution', 120,'Color', 'cmyk')
end

end