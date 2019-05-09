function selEls = select_els_on_neurorouter(nrg, numEls, textVal)




while length(nrg.configList.selectedElectrodes) < numEls 
    pause(0.2)
end
selEls = nrg.configList.selectedElectrodes;
selEls = selEls(:,1)';
fprintf('Done selecting %s.\n', textVal)



end