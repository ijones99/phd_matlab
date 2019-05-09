function dirName  = load_data_dir
% function dirName = LOAD_DATA_DIR
%
% Directories containing project data
%

dirName = [];

dirName.dataDirBase = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska';

% data directories
dirName.dataDirShort = { ...
    '04Dec2014';
    '04Dec2014_02';
    '09Dec2014';
    '09Dec2014_02';
    '16Dec2014';
    '16Dec2014_02';
    '17Dec2014'
    }';

dirName.dataDirLong = {};

% data directories long
for i=1:length(dirName.dataDirShort )
    dirName.dataDirLong{i} = sprintf('%s/%s/', dirName.dataDirBase, dirName.dataDirShort{i});
end

% other directories
dirName.prof = '../analysed_data/profiles/';
dirName.marching_sqr_over_grid =  '../analysed_data/marching_sqr_over_grid/';
dirName.common.marching_sqr_over_grid = '~/ln/vis_stim_hamster/data_analysis/marching_sqr_over_grid/';
dirName.common.figs = '~/ln/vis_stim_hamster/data_analysis/Figs/';
dirName.common.params = '~/ln/vis_stim_hamster/data_analysis/parameters/';
dirName.common.clus_params = '~/ln/vis_stim_hamster/data_analysis/clustering_parameters/';
dirName.common.meta = '~/ln/vis_stim_hamster/data_analysis/meta/';

% local dirs
dirName.local.marching_sqr = '../analysed_data/marching_sqr/';
dirName.local.marching_sqr_over_grid =  '../analysed_data/marching_sqr_over_grid/';

% Local Figs
dirName.local.figs.marching_sqr_over_grid = '../Figs/marching_sqr_over_grid/';
dirName.local.figs.drifting_linear_pattern =  '../Figs/drifting_linear_pattern/';





end