function plot_mean_stim_response(m_stim, uniqueVoltages,lookupTbStim, Xread, selStimEl, readoutEl)
% PLOT_MEAN_STIM_RESPONSE(m_stim, uniqueVoltages,lookupTbStim, Xread, selStimEl, readoutEl)

Fs = 2e4;
preStim = 0.005*Fs;
postStim = 0.015*Fs;
ySpacing = 20;

selStimCh = mea1kadd.el2ch(selStimEl, m_stim.elNo);
readoutCh = mea1kadd.el2ch(readoutEl, m_stim.elNo);

lenV = length(uniqueVoltages);
colorVals = graphics.distinguishable_colors(lenV);

fpMed = nan(lenV,preStim+postStim+1);
for i=1:lenV
    currV = uniqueVoltages(i);
    lutIdx = find(lookupTbStim(:,2)==currV);
    fp1 = raw.extract_epoch(Xread, lookupTbStim(lutIdx,1), preStim,postStim);
    fpReps = reshape(fp1,[preStim+postStim+1,length(lutIdx)])';
    fpReps = mea1kadd.footprint_apply_offset(fpReps','offset_sample_range', ...
        preStim+postStim-50:preStim+postStim)';
    
    %     plot(fpReps');
    fpMed(i,:) = nanmean(fpReps(:,:),1);
    
    %     ylim([-100 100])
    %     shg
    %     ju= input('enter >>')
end
h=figure; hold on
figs.scale(h,40,90);
for i=1:lenV
    plot( fpMed(i,:)+ySpacing*(i-1),'Color',colorVals(i,:) ,'LineWidth',2);
end
legend(num2str(uniqueVoltages))
title(sprintf('stim el %d (ch%d), readout el %d (ch%d)', ...
    selStimEl, selStimCh, readoutEl,readoutCh));


end
