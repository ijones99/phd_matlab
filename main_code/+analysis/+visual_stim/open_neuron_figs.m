dirFig = '~/ln/vis_stim_hamster/plots/neuron_profiles/';

%% search by idx
selIdx = 20;
figName = strrep(paraOutputMat.neur_names{selIdx},'.mat', '.fig');
open(fullfile(dirFig, figName))



%% search by string

figSearchStr = {'08Oct2014', 'clus_1224'};
selIdx = cells.cell_find_str2( paraOutputMat.neur_names,   figSearchStr,   'two_and_exp');
figName = strrep(paraOutputMat.neur_names{selIdx},'.mat', '.fig');
open(fullfile(dirFig, figName))
