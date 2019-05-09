function fpReps = plot_mean_traces_response(uniqueVoltages,lookupTbStim, Xread, varargin)
% fpReps = PLOT_MEAN_STIM_RESPONSE( uniqueVoltages,lookupTbStim, Xread)
%
% varargin:
%   y_spacing: spacing between plots

ySpacing = 20;
postStimT = 20;
postStimT = 20;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'y_spacing')
            ySpacing = varargin{i+1};
        
        end
    end
end


Fs = 2e4; % samples per sec
FsMsec = Fs/1e3; % samples per msec
preStim = 0.002*Fs;
postStim = 0.004*Fs;

lenV = length(uniqueVoltages);
colorVals = graphics.distinguishable_colors(lenV);

lenXread = length(Xread);

fpReps={};

for i=1:lenV
    currV = uniqueVoltages(i);
    lutIdx = find(lookupTbStim(:,2)==currV);
    
    if max(lookupTbStim(lutIdx,1))+postStim <= lenXread
        
        fp1 = raw.extract_epoch(Xread, lookupTbStim(lutIdx,1), preStim,postStim);
        
        %[SponWfs, SponWfMean, SponWfMeanCtr] =  mea1kadd.extract_footprint_from_spiketimes(...
        %   spikeTimes, f,'pre_stim',preStimT, 'post_stim',postStimT) ;
        
        fpReps{i} = reshape(fp1,[preStim+postStim+1,length(lutIdx)])';
        fpReps{i} = mea1kadd.footprint_apply_offset(fpReps{i}','offset_sample_range', ...
            preStim+postStim-50:preStim+postStim)';
        
        
        plot([1:length(fpReps{i})], fpReps{i}'+ySpacing*(i-1));
        text(1, ySpacing*(i-1)+ySpacing/2, num2str(currV));
    else
        warning('data length is less than DAC timestamp.');
        return
    end
    %     if i==lenV-1
    %        2
    %     end
end

xlabel('time (samples)');
ylabel('response trace (V-corr units)');

end
