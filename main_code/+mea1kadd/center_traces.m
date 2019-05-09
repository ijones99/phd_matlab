function wfsCtr = center_traces(wfs)
% wfsCtr = CENTER_WFS(wfs)
%
% wfs: [40x1024x15]

baseline = median(wfs(1:7,:,:),1);
baselineMat = repmat(baseline,[size(wfs,1),1,1]);

wfsCtr= wfs - baselineMat;




end
