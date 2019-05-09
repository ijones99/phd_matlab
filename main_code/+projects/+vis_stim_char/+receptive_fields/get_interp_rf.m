function rf  = get_interp_rf(i, LUT, dataOut, interpNum)
% rf  = GET_INTERP_RF(i, LUT, dataOut, interpNum)

cellLocalIdx = LUT(i,4);

imOn = dataOut.sta(cellLocalIdx).imONAdj;
imOff = dataOut.sta(cellLocalIdx).imOFFAdj;


pOn = dataOut.total_spikes_ON(cellLocalIdx)/[dataOut.total_spikes_ON(cellLocalIdx)+dataOut.total_spikes_OFF(cellLocalIdx)];
pOff = dataOut.total_spikes_OFF(cellLocalIdx) /[dataOut.total_spikes_ON(cellLocalIdx)+dataOut.total_spikes_OFF(cellLocalIdx)];

if dataOut.total_spikes_ON(cellLocalIdx) > dataOut.total_spikes_OFF(cellLocalIdx)
    mm = imOn;
else
    mm= imOff;
    
end


rf = interp2(mm,interpNum);






end
