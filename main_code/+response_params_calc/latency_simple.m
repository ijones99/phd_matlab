function paramOut_Latency_sec = latency_simple(firingRateMean, edges, varargin)
% paramOut_Latency = RESPONSE_PARAMS_CALC.LATENCY_simple(firingRateMean,
% edges
%
% purpose: Calculate "Response Latency:" 
% Response Latency (Latency).
%
% Arguments:
%   firingRateMean = [avgFiringRate_sec ]
%
% out: (in seconds)
%
% The latency of each cell was estimated by measuring the time to the peak of...
% its response during the presentation of its preferred stimulus, i.e., the spot 
% size that produced the most spikes, during the increasing-spot-stimulus paradigm. 
% The response was measured as the mean firing rate measured over an integration 
% window of 25 ms. (Farrow et. al. 2011, J Neurophysiology)
%
% 'fit_spline' 'show_plot' 'first_peak' 'raster' 'min_spikecount'

minRelPeakSize = 0.75;
fitCurve = [];
doPlot = 0;
doUseFirstPeak = 0;
rasterReps = [];
minFR = 0;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'fit_spline')
            fitCurve  = 1;
        elseif strcmp( varargin{i}, 'show_plot')
            doPlot = 1;
        elseif strcmp( varargin{i}, 'first_peak')
            doUseFirstPeak = 1;
        elseif strcmp( varargin{i}, 'raster')
            rasterReps =varargin{i+1};
        elseif strcmp( varargin{i}, 'min_fr')
            minFR =varargin{i+1};
        end
    end
end



acqRate = 2e4;

if ~isempty(fitCurve)
    x = edges/acqRate;
    y = firingRateMean;
    
    cs = spline(x,y);
    xx = linspace(0,1,501);
    fittedSpline = ppval(cs,xx);
    if doUseFirstPeak
        [pks,locs] = findpeaks(fittedSpline);
        idxHighPeaks = find(pks./max(pks) > minRelPeakSize);
        pks = pks(idxHighPeaks);
        locs = locs(idxHighPeaks);
        if pks > minFR
            paramOut_Latency_sec  = xx(locs(1));
        else
            paramOut_Latency_sec   = NaN;
        end
    else
        [pks,idxMaxFR] = max(fittedSpline);
        if pks(1) > minFR
            paramOut_Latency_sec  = xx(idxMaxFR(1));
        end
    end
   
   if doPlot 
       clf
       plot(x,y,'o',xx,ppval(cs,xx),'-r'); hold on
       plot(paramOut_Latency_sec,pks(1),'ks');
       if ~isempty(rasterReps)
         for i=1:length(rasterReps)
            plot.raster2(rasterReps{i}/2e4, 'offset', 0.7*(i-1),'height',0.5)
         end
       end
       
     
   end
   
else
    [Y,idxMaxFR] = max(firingRateMean);    
    % % zero point in edges
    % zeroIdx = find(edges==0);
    % if isempty(zeroIdx)
    %     zeroIdx = 1;
    % end
    %
    % integWinTime_sec = diff(edges(end-1:end))/2e4;
    % % time to max firing rate
    % paramOut_Latency_sec = (idxMaxFR(1)-zeroIdx-1 ) *integWinTime_sec;
    if max(idxMaxFR) < minFR
        paramOut_Latency_sec = nan;
    else
        
        paramOut_Latency_sec  = edges(idxMaxFR(1))/acqRate;
    end

end
end