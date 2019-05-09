function create_configuration_from_el_numbers(dirName, fileName, selectedElectrodes, stimElIdx)
selectedElectrodes = selectedElectrodes + 1;
npos = nr.hidens_create_route_neuron_cell(selectedElectrodes,  stimElIdx);

interElSize=[16.2 19.588];

nr.hidens_write_neuroplacement(dirName, [fileName '.neuropos.nrk'], npos,...
    interElSize);
nr.hidens_execute_routing(dirName, fileName );


end