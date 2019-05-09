function y=hidens_create_chip_image(el_pos, pixels_per_um, devsize)
% y = hidens_create_chip_image(el_pos, pixels_per_um, devsize)
% generates a bitmap image of the chip ...
% el_pos is structure with x and y positions of the electrodes
%   ususaly the one returned by hidens_get_all_electrodes
% pixels_per_um is image scale factor
% devsize is vector of the x and y dimensions of the wholechip

% the original Urs's code, bit slow as it is using a loop cycle for printing each electrode
% el_x_n=4.1*pixels_per_um;
% el_x_p=4.1*pixels_per_um;
% el_y_n=2.9*pixels_per_um;
% el_y_p=2.9*pixels_per_um;
% pt_x_n=5.6*pixels_per_um;
% pt_x_p=5.6*pixels_per_um;
% pt_y_n=4.4*pixels_per_um;
% pt_y_p=9.9*pixels_per_um;
%
% pos.x=el_pos.x*pixels_per_um;
% pos.y=el_pos.y*pixels_per_um;
%
% col_backgroung=uint8(255);
% col_pt=uint8(180);
% col_el=uint8(10);
%
% ig=ones(ceil(devsize(2)*pixels_per_um), ceil(devsize(1)*pixels_per_um), 'uint8')*col_backgroung;
%
% for i=1:size(pos.x,2)
%     ig(floor(pos.y(i)-pt_y_n):ceil(pos.y(i)+pt_y_p),floor(pos.x(i)-pt_x_n):ceil(pos.x(i)+pt_x_p))=col_pt;
%     ig(floor(pos.y(i)-el_y_n):ceil(pos.y(i)+el_y_p),floor(pos.x(i)-el_x_n):ceil(pos.x(i)+el_x_p))=col_el;
% end
%
% y=ig;

% Optimized Jan's code, assumes some kind of vertical alignment of the electrodes 
% and loops only through these columns

  devsize = devsize*pixels_per_um;

  %  as the electrodes are aranged in columns, it's better to sort it by X posistion ...
  pos_data=sortrows([el_pos.x',el_pos.y']);

  fdx = [0;find(diff(pos_data(:,1)))]+1; % begining of each column
  xpos = pos_data(fdx,1)';
  el_minx = floor((xpos-4.1)*pixels_per_um);
  el_maxx = ceil ((xpos+4.1)*pixels_per_um);
  pt_minx = floor((xpos-5.6)*pixels_per_um);
  pt_maxx = ceil ((xpos+5.6)*pixels_per_um);

  % as 0 is used for masking, neither col_pt or col_el can be zero
  col_backgroung=255;
  col_pt=180;
  col_el=10;

  im=ones(ceil(devsize(2)), ceil(devsize(1)))*col_backgroung;

  fdx = [fdx;size(pos_data,1)+1];
  for i=1:length(xpos)
    ypos = pos_data(fdx(i):fdx(i+1)-1,2);

    ystart           = floor ((ypos-4.4)*pixels_per_um);
    yend             = ceil ((ypos+9.9)*pixels_per_um);
    column_i         = zeros(ceil(devsize(2)),1);
    column_i(ystart) = 1;
    column_i(yend)   = column_i(yend) - 1;
    column_i         = cumsum(column_i)*ones(1,pt_maxx(i)-pt_minx(i)+1)*col_pt;
    im(:,pt_minx(i):pt_maxx(i)) = im(:,pt_minx(i):pt_maxx(i)).*(column_i==0) + column_i;

    ystart           = floor ((ypos-2.9)*pixels_per_um);
    yend             = ceil ((ypos+2.9)*pixels_per_um);
    column_i         = zeros(ceil(devsize(2)),1);
    column_i(ystart) = 1;
    column_i(yend)   = column_i(yend) - 1;
    column_i = cumsum(column_i)*ones(1,el_maxx(i)-el_minx(i)+1)*col_el;
    im(:,el_minx(i):el_maxx(i)) = im(:,el_minx(i):el_maxx(i)).*(column_i==0) + column_i;
  end
  % im(10:20,10:20) = 0; % alignment mark

  y = uint8(im);

