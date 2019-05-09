figure
for iPlot = 1:length(plotCurves)
   subplot(3,3,iPlot); hold on
   plot(speedsUnique, plotCurves(iPlot, :),'-^')
     [cubicFit xValsHiRes cubicCoef,stats,ctr] = ...
        projects.vis_stim_char.analysis.speed_test.fit_curve(...
        speedsUnique,plotCurves(iPlot, :),'degree',3);
    minmaxVal = minmax(plotCurves(iPlot, :));
    
    plot(xValsHiRes,normalize_values( cubicFit,[minmaxVal(1) minmaxVal(2)])...
        ,'r-')
    
    
    [Y,I] = max(cubicFit);
    preferredVal = xValsHiRes(I);
    title(num2str(preferredVal))
end