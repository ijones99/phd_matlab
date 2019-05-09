function [ ppAmps elCoordsX elCoordsY] = plot_footprints( ...
    elPositionXY, waveform, varargin )



% PURPOSE: This function 
% [ppAmps elCoordsX elCoordsY] = plot_footprints_all_els( elConfigInfo, waveformData, varargin )
% waveform = [reps x chs x time]
% init vars
plotType = 'single';
plotStyle = '-';
plotColor = [0 0 1];
addNeuronLabel = 0;
lineWidth = 1;
selChInds = 0;
ampScale = 1;
doPlot = 1;
adjForNeuroRouter = 0;
excludeEls = [];
plotSelElsRed = 0;
interDistX = 16.2;
plotEls = 1;
revYDir = 0;
revXDir = 0;
inputIsWaveforms = 1;
flipTemplatesUD = 0;
flipTemplatesLR = 0;
doLegend = 0;
textLabel = {};
textLabelOffsetXY = [10 20 ];
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'plot_type')
            plotType = varargin{i+1};
        elseif strcmp( varargin{i}, 'plot_color')
            plotColor = varargin{i+1};
        elseif strcmp( varargin{i}, 'plot_style')
            plotStyle = varargin{i+1};
        elseif strcmp( varargin{i}, 'line_width')
            lineWidth = varargin{i+1};
        elseif strcmp( varargin{i}, 'sel_ch_inds')
            selChInds = varargin{i+1};
        elseif strcmp( varargin{i}, 'exclude_els')
            excludeEls = varargin{i+1};
        elseif strcmp( varargin{i}, 'scale')
            ampScale = varargin{i+1};
        elseif strcmp( varargin{i}, 'no_plot')
            doPlot = 0;
        elseif strcmp( varargin{i}, 'format_for_neurorouter')
            adjForNeuroRouter = 1;
        elseif strcmp( varargin{i}, 'hide_els_plot')
            plotEls = 0;
        elseif strcmp( varargin{i}, 'input_templates')
            inputIsWaveforms = 0;
        elseif strcmp( varargin{i}, 'plot_sel_els_red')
            plotSelElsRed  = 1;
            selElsToPlotRed = varargin{i+1};
        elseif strcmp( varargin{i}, 'rev_y_dir')
            revYDir = 1;
        elseif strcmp( varargin{i}, 'rev_x_dir')
            revXDir = 1;
        elseif strcmp( varargin{i}, 'flip_templates_ud')
            flipTemplatesUD  = 1;
        elseif strcmp( varargin{i}, 'flip_templates_lr')
            flipTemplatesLR  = 1;
        elseif strcmp( varargin{i}, 'do_legend')
            doLegend = 1;
        elseif strcmp( varargin{i}, 'label')
            textLabel = varargin{i+1};
            if isnumeric(textLabel)
                textLabel = num2cell(  textLabel);
            end
        elseif strcmp( varargin{i}, 'label_xy')
            textLabelOffsetXY = varargin{i+1};
            
        end
    end
end

zoom out

xAxisStart = -round(size(waveform,3)/2)+1;
xAxisEnd = size(waveform,3)+xAxisStart-1;
xaxis = [xAxisStart: xAxisEnd];
scaleFactorX = interDistX/length(xaxis);
xaxisScaled = xaxis*scaleFactorX;
% get all waveforms
% waveforms = permute(waveformData, [2 3 1] );

% make templates
templates = squeeze(mean(waveform,1));

% max waveform size
maxwaveformAmpInData = max(max(max(templates,[],1)-min(templates,[],1)));
     
% get peak to peak data
ppAmps = max(templates,[],2)-min(templates,[],2);

% get scale factor for amplitude
if isempty(ampScale)
    maxAmpSet = 9.7939;% min(abs(diff(unique(elConfigInfo.elY)))); % max amplitude desired
    scaleFactor = maxAmpSet/max(max(max(ppAmps)));
else
    scaleFactor = ampScale/max(max(max(ppAmps)));
end

% apply to templates
templates = templates'*scaleFactor;
waveform = waveform*scaleFactor;

plotXAxis = [repmat(elPositionXY(:,1),1,length(xaxisScaled)) + repmat(xaxisScaled,length(elPositionXY(:,1)),1)]';

hold on
numReps = 10;

cMap = plot.colormap_optimal_colors(numReps);

for i=1:numReps
    plotYAxis = squeeze(waveform(i,:,:))';
    plotYAxis = mea1kadd.footprint_apply_offset(plotYAxis);
    plotYAxis = repmat(elPositionXY(:,2)',length(xaxisScaled),1)  - plotYAxis;
   
    
    plot(plotXAxis , plotYAxis,plotStyle,'Color',cMap(i,:),'LineWidth', lineWidth );
end

if plotEls
    plot(elPositionXY(:,1),elPositionXY(:,2),'og');
end

if ~isempty(textLabel)
    hTxt = text(elPositionXY(:,1)+textLabelOffsetXY(1),elPositionXY(:,2)+textLabelOffsetXY(1),...
        textLabel);
end

set(gca,'YDir','reverse');

axis equal

end