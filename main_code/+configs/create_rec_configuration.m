function [elidxInFile chNoInFile] = create_rec_configuration(elNums, configName, configPath  )

if configPath(end) ~= '/'
    configPath(end+1) = '/';
end

% route els
out = MakeConfig('config_path',configPath, ...
    'config_name', configName, 'stim_elcs', [], ...
        'rec_elcs', elNums, 'no_plot' );

% check routed els
[elidxInFile chNoInFile] = get_el_ch_no_from_el2fi(configPath, configName);




end