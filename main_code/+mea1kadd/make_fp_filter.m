function fpFilter =  make_fp_filter(m_stim, validIdx, SponWfMeanCtr)
% fpFilter =  MAKE_FP_FILTER(m_stim, validIdx, SponWfMeanCtr)

figure
% plot footprints
plot_footprints_simple([ m_stim.mposx(validIdx)*18 ...
    m_stim.mposy(validIdx)*18], SponWfMeanCtr(:,validIdx)', ...
    'input_templates','hide_els_plot','label', validIdx);
ju = input('Zoom in to select channels for filter>> ');
[elNoFilt chFilt] =  mea1kadd.select_els_in_polygon( ...
    m_stim.elNo, m_stim.mposx*18, m_stim.mposy*18 );
fpFilter.wfs = -SponWfMeanCtr;
fpFilter.ch = chFilt;
fpFilter.el = mea1kadd.ch2el( chFilt,m_stim);


end
