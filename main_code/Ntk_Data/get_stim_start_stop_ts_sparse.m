function [stimFramesTsStartStop] = get_stim_start_stop_ts_sparse(frameno)
% [stimFramesTsStartStop] = GET_STIM_START_STOP_TS_SPARSE(frameno)

acqRate = 2e4;


stimFramesTsStartStop = find(diff(frameno)==1);




end
