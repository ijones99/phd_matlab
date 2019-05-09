%% compare wn_checkerboard
figure, hold on
neurName = '5055n28';
manualData = file.load_single_var('../analysed_data/T10_18_39_17_wn_checkerboard_n_01/03_Neuron_Selection/',...
    'st_5055n28.mat')
plot(manualData.ts*2e4,'b');
autoData = file.load_single_var('/home/ijones/Projects/hamster_visual_characterization/neurons_saved/17Jun2014/',...
    'run_01_ums5055n28_auto2008')
plot(autoData.wn_checkerbrd.st,'r');
legend({'manual', 'auto'})
title(sprintf('wn checkerboard: manual vs auto (%s)',neurName));
%% compare spots
figure, hold on
manualData = file.load_single_var('../analysed_data/T10_18_39_26_spots_n_01/03_Neuron_Selection/',...
    'st_5055n18.mat')
plot(manualData.ts*2e4,'b');
autoData = file.load_single_var('/home/ijones/Projects/hamster_visual_characterization/neurons_saved/17Jun2014/',...
    'run_01_ums5055n28_auto2008')
plot(autoData.spt.st,'r');
legend({'manual', 'auto'})
title(sprintf('spots: manual vs auto (%s)',neurName));
