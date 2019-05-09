 figure, hold on
 gui.plot_els( 'marker_style', 's' ,'marker_face_color',[.5 .5 .5],...
     'marker_edge_color','none','marker_size',2)

 load ../analysed_data/profiles/clus_00100.mat
 
 xEls = neur(1).footprint.x;
 yEls = neur(1).footprint.y;
 
 plot(xEls,yEls, 'ks', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'none',...
     'MarkerSize', 2)
 
 axis equal