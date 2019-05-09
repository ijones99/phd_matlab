function respPerc = threshold_responses(m_stim, uniqueVoltages,lookupTbStim, Xread, selStimEl, readoutEl,varargin)
% respPerc = THRESHOLD_RESPONSES(m_stim, uniqueVoltages,lookupTbStim, Xread, selStimEl, readoutEl)
%
% varargin:
%   y_spacing: spacing between plots
%   'x_axis_window'
%   'y_thresh'
%   'spike_deflection_dir' [-1 , 1];

ySpacing = 20;
xAxisWinSet = [];
yThresh = [];


% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'y_spacing')
            ySpacing = varargin{i+1};
        elseif strcmp( varargin{i}, 'x_axis_window')
            xAxisWinSet= varargin{i+1};
        elseif strcmp( varargin{i}, 'y_thresh')
            yThresh = varargin{i+1};
        
        end
    end
end


Fs = 2e4;
preStim = 0.002*Fs;
postStim = 0.005*Fs;


selStimCh = mea1kadd.el2ch(selStimEl, m_stim.elNo);
readoutCh = mea1kadd.el2ch(readoutEl, m_stim.elNo);

lenV = length(uniqueVoltages);
colorVals = graphics.distinguishable_colors(lenV);

if isempty(xAxisWinSet) | isempty(yThresh)
    h=figure; hold on
    figs.scale(h,40,90);
    
    % get params
    for i=lenV
        currV = uniqueVoltages(i);
        lutIdx = find(lookupTbStim(:,2)==currV);
        fp1 = raw.extract_epoch(Xread, lookupTbStim(lutIdx,1), preStim,postStim);
        fpReps = reshape(fp1,[preStim+postStim+1,length(lutIdx)])';
        fpReps = mea1kadd.footprint_apply_offset(fpReps','offset_sample_range', ...
            preStim+postStim-50:preStim+postStim)';
        plot(fpReps');
        
    end
  
end
if isempty(xAxisWinSet)
    xAxisWinSet = input('Enter x axis limits >> ');
end
if isempty(yThresh)
    yThresh = input('Enter threshold value>> ');
end
respPerc = nan(1,lenV);
for i=1:lenV
    currV = uniqueVoltages(i);
    lutIdx = find(lookupTbStim(:,2)==currV);
    fp1 = raw.extract_epoch(Xread, lookupTbStim(lutIdx,1), preStim,postStim);
    fpReps = reshape(fp1,[preStim+postStim+1,length(lutIdx)])';
    fpReps = mea1kadd.footprint_apply_offset(fpReps','offset_sample_range', ...
        preStim+postStim-50:preStim+postStim)';
    
    [rows cols] = find(std(fpReps(:,xAxisWinSet(1):xAxisWinSet(2)),[],2)>yThresh);
    rows;
    exceededThr = unique(rows);
    respPerc(i) = length(exceededThr)/size(fpReps,1);
end

1;

end
