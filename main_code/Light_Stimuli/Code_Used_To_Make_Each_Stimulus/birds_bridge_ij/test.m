% load data
load /home/ijones/Documents/Equipment/Projector/2011_11_03' Measurements'/2011_11_03_blu+green.mat

% plot data
figure
plot(intensity_level, values_in_uW,'*');

% label
xlabel('Pixel Value (int)'), ylabel('Brightness (uW)')

