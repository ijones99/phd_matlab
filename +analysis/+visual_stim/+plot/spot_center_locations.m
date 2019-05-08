function spot_center_locations(refClusInfo)
% SPOT_CENTER_LOCATIONS(refClusInfo)
% Purpose:
%   plot the locations of the cells found.

h2=figure, hold on
figs.set_size_fig(h2,[75   472   639   529]);
plot.locations_with_labels(refClusInfo.clus_ctr_xy , ...
    num2str(refClusInfo.clus_no));

xLine = [-450 0  ; 450  0   ];
yLine = [0    -450  ; 0 450];

line(xLine, yLine,'Color','r')
grid on

end