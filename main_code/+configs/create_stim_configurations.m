function out = create_stim_configurations(stimEls, staticEls, recEls, ...
    numElsPerConfig, configName, configPath  )

numStimEls = length(stimEls);

% randomize els
stimEls = stimEls(randperm(numStimEls));

% number of els
numElsPerConfig = 40-length(staticEls);

% create configs
remainingEls = stimEls;
configEls = {};
i = 1;
out = {};
while length(remainingEls > 0) && i < 6
    currConfigName = sprintf('%s_%02d', configName, i); 
    if length(remainingEls) >= numElsPerConfig
        % electrodes in current config (being created)
        currConfigEls = [staticEls remainingEls(1:numElsPerConfig)];
    else
        currConfigEls = [staticEls remainingEls];
    end
    
    % route els
    out{i} = MakeConfig('config_path',configPath, ...
        'config_name', currConfigName, ...
        'stim_elcs', currConfigEls,...
        'rec_elcs', [], 'no_plot' );
    
    % check routed els
    [elidxInFile chNoInFile] = get_el_ch_no_from_el2fi(configPath, currConfigName);
    
    % delete routed els
    remainingEls(find(ismember(remainingEls,elidxInFile))) = [];
    i = i+1;
end









end