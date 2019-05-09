function [respPerc fpReps ]= threshold_responses_v3(uniqueVoltages,lookupTbStim, Xread,varargin)
% [respPerc fpReps ]= THRESHOLD_RESPONSES_V3(uniqueVoltages,lookupTbStim, Xread)
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
postStim = 0.0045*Fs;


lenV = length(uniqueVoltages);
colorVals = graphics.distinguishable_colors(lenV);
fpReps={}
if isempty(xAxisWinSet) | isempty(yThresh)
    h=figure; hold on
    figs.scale(h,40,90);
    
    % get params
    for i=lenV
        currV = uniqueVoltages(i);
        lutIdx = find(lookupTbStim(:,2)==currV);
        fp1 = raw.extract_epoch(Xread, lookupTbStim(lutIdx,1), preStim,postStim);
        fpReps{i} = reshape(fp1,[preStim+postStim+1,length(lutIdx)])';
        fpReps{i} = mea1kadd.footprint_apply_offset(fpReps{i}','offset_sample_range', ...
            preStim+postStim-50:preStim+postStim)';
        plot(fpReps{i}');
        
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
    try
    fp1 = raw.extract_epoch(Xread, lookupTbStim(lutIdx,1), preStim,postStim);
    fpReps{i} = reshape(fp1,[preStim+postStim+1,length(lutIdx)])';
    fpReps{i} = mea1kadd.footprint_apply_offset(fpReps{i}','offset_sample_range', ...
        preStim+postStim-50:preStim+postStim)';
    
    [rows cols] = find(std(fpReps{i}(:,xAxisWinSet(1):xAxisWinSet(2)),[],2)>yThresh);
    rows;
    exceededThr = unique(rows);
    respPerc(i) = length(exceededThr)/size(fpReps{i},1);
    catch
       warning('Data probably hit rails');
       respPerc(i) = nan;
    end
end

1;

end
