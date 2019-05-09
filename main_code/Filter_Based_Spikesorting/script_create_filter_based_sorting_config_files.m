%% create configs file for cluster based sorting

configs.flistidx = 2;
configs.info = 'original natural movie';
configs.name = 'center6x18sp1_PeriphDiagLine.hex.nrk2';

save configurations.mat configs


%% create configs file for filter based sorting

filtersorting.flistidx = [1:10];

save filtersorting.mat filtersorting;