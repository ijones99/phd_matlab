function [nrg ah] = open_neurorouter
% [nrg ah] = OPEN_NEUROROUTER

nrg = nr.Gui;
set(gcf, 'currentAxes',nrg.ChipAxesBackground);
ah = nrg.ChipAxes;



end