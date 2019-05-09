function plot_matches_for_sel_neurs(selNeuronInds, heatMapMatrix)

%% plot matches for certain neurons


for iSelNeuronInds = 1:length( selNeuronInds )
    
    figure, plot(heatMapMatrix(selNeuronInds(iSelNeuronInds),:),'b--*')
    title(strcat('Neuron # ', num2str(selNeuronInds(iSelNeuronInds))));
    xlabel('Neuron Index Number');
    ylabel('Percent Match with Reference Neuron');

end