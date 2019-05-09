function elInfo = els_get_all
% elInfo = ELS_GET_ALL

 elInfo.els = [0:26399];
[allX allY]= mea1kadd.el2xy_v2( elInfo.els);
 elInfo.x = allX;
 elInfo.y = allY;



end
