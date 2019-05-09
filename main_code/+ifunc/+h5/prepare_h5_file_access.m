function hdmea = prepare_h5_file_access(dateVal, h5FileName)
% function hdmea = prepare_h5_file_access(dateVal, h5FileName)

h5_file = fullfile('/links/groups/hima/recordings/HiDens/SpikeSorting/Roska/', ...
   dateVal, h5FileName);

hpf = 350;
lpf = 8000;
filterOrder = 6;
hdmea = mysort.mea.CMOSMEA(h5_file, 'hpf', hpf, 'lpf', lpf, 'filterOrder', filterOrder);



end