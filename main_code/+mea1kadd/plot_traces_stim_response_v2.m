function fpRepsAll = plot_mean_traces_response_v2(f_stim, m_stim, xread, uniqueVoltages,lookupTbStim, readoutEl, varargin)
% fpRepsAll = PLOT_MEAN_STIM_RESPONSE(f_stim, m_stim, uniqueVoltages,lookupTbStim, selStimEl, readoutEl, readoutEl)
%
% varargin:
%   y_spacing: spacing between plots

ySpacing = 80;

Fs = 2e4; % samples per sec
FsMsec = Fs/1e3; % samples per msec
preStim = round(0.0005*Fs);
postStim = round(0.0025*Fs);

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'y_spacing')
            ySpacing = varargin{i+1};
        
        end
    end
end



lenV = length(uniqueVoltages);
colorVals = graphics.distinguishable_colors(lenV);

readoutElIdx = find(ismember(m_stim.elNo,readoutEl));
fpRepsAll = {};
for i=1:lenV
    currV = uniqueVoltages(i);
    lutIdx = find(lookupTbStim(:,2)==currV);
    %fp1 = raw.extract_epoch(xread, lookupTbStim(lutIdx,1), preStim,postStim);
    spikeTimes = lookupTbStim(lutIdx,1);
    [SponWfs, SponWfMean, SponWfMeanCtr] =  mea1kadd.extract_footprint_from_spiketimes(...
        spikeTimes, f_stim,'pre_stim',preStim, 'post_stim',postStim) ;
    fpReps = squeeze(SponWfs(:,readoutElIdx,:))';
    %     fpReps = reshape(fp1,[preStim+postStim+1,length(lutIdx)])';
    fpRepsAll{i} = fpReps;
    fpReps = mea1kadd.footprint_apply_offset(fpReps','offset_sample_range', ...
        preStim+postStim-20:preStim+postStim)';
    
    plot([1:length(fpReps)]/FsMsec, fpReps'+ySpacing*(i-1));
    text(1, ySpacing*(i-1)+ySpacing/2, num2str(currV));

end

xlabel('time (msec)');
ylabel('response trace (V-corr units)');

end
