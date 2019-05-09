function wfsCtr = center_wfs(wfs)
% wfsCtr = CENTER_WFS(wfs)
%
% wfs: [el x sample];

baseline = median(wfs(:,1:7),2);
baselineMat = repmat(baseline,1, size(wfs,2));

wfsCtr= wfs - baselineMat;




end
