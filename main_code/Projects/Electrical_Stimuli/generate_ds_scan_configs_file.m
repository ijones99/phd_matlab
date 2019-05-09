function configs = generate_ds_scan_configs_file(Settings, nrkFileGroups)
% FUNCTION configs = generate_ds_scan_configs_file(Settings, nrkFileGroups)
% nrkFileGroups should be a cell

configs = {};

for i=1:length(nrkFileGroups)

    configs(i).flistidx= nrkFileGroups{i};

    configs(i).name= 'Rabbit retina, high density configuration';
    if and(isfield(Settings, 'BAR_WIDTH'),isfield(Settings, 'BAR_LENGTH'))
        configs(i).info= sprintf('Bar dims %dx%d um2',Settings.BAR_WIDTH(1),Settings.BAR_LENGTH(1) );
    elseif and(and(isfield(Settings, 'BAR_WIDTH_PX'), isfield(Settings, 'UM_TO_PIX_CONV')),isfield(Settings, 'BAR_LENGTH_PX'))
        configs(i).info= sprintf('Bar dims %dx%d um2',Settings.BAR_WIDTH_PX(1)*Settings.UM_TO_PIX_CONV...
            ,Settings.BAR_LENGTH(1)*Settings.UM_TO_PIX_CONV );
    else
       fprintf('Error finding bar width in config file.\n'); 
    end
    configs(i).DIRECTIONS= Settings.DIRECTIONS; %in moving bars function
    configs(i).SPEED=  Settings.SPEED; %in moving bars function
    configs(i).RGB= Settings.RGB; % %in moving bars function
    configs(i).align= Settings.align;
    configs(i).march_square=[];
    
end

end
