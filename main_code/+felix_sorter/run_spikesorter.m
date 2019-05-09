function [gdf_merged T_merged localSorting localSortingID] = run_spikesorter(h5FileList, sortOutPath, sortingName)
% [gdf_merged T_merged localSorting localSortingID] = RUN_SPIKESORTER(h5FileList, sortOutPath, sortingName)
%
% Build Mea that concatenates multiple ntk files (WARNING NEED TO HAVE THE SAME CONFIGURATIONS!
    compoundMea = mysort.mea.compoundMea(h5FileList, 'useFilter', 0, 'name', 'PREFILT');

    % SORT
   
    [gdf_merged T_merged localSorting localSortingID] = ...
        ana.startHDSorting(compoundMea, sortOutPath);
   
    save(fullfile(sortOutPath, [sortingName '_results.mat']), ...
        'gdf_merged', 'T_merged', 'localSorting', 'localSortingID');
    
end