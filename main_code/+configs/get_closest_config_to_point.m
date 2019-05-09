function [configName idx] = get_closest_config_to_point(inputElNo, dirName)

all_els=hidens_get_all_electrodes(2);

% get coords of el
elIndAll = find(all_els.el_idx== inputElNo);
if isempty(elIndAll)
    fprintf('el not found.\n')
    return;
end
coordsSelEl = [all_els.x(elIndAll) all_els.y(elIndAll)];


% get center locations
if exist(fullfile(dirName,'config_info.mat'),'file');
   load(fullfile(dirName,'config_info.mat'));
else
    [configCtrX configCtrY configCtrXAll configCtrYAll configFileNames] = ...
        plot_config_positions_from_el2fi(dirName, '*el2fi.nrk2','do_plot',0,'label_center')

     save(fullfile(dirName,'config_info.mat'), ...
        'configCtrX', 'configCtrY', 'configCtrXAll', ...
        'configCtrYAll', 'configFileNames');    
end

% get closest electrode to selected point
[idx, dist]=geometry.get_closest_point_to_matrix(configCtrX, configCtrY,...
   coordsSelEl)


configName = configFileNames{idx};



end