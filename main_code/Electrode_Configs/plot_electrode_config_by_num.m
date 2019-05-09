function plot_electrode_config_by_num(dirName, configNumber, varargin)
% function PLOT_ELECTRODE_CONFIG_BY_NUM(dirName, configNumber, varargin)
%
% arguments
%   configNumber = file number;
%
% varargin
%    'label_with_number'
%
warning('Will plot config name number, not file index number!!')

% init vars
doLabel = 0;
doRandColor = 0;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'label_with_number')
            doLabel = 1;        
        elseif strcmp( varargin{i}, 'plot_rand_color')
            doRandColor = 1;
        end
    end
end

% get file names
fileNames = dir(fullfile(dirName,'*fi2el.nrk2'));

hold on
for i=1:length(configNumber)
    
    elConfigInfo = get_el_pos_from_nrk2_file('file_dir', dirName, 'file_name', ...
        fileNames(configNumber(i)).name);
    
    if doLabel
        if doRandColor
            plot_electrode_config('el_config_info', elConfigInfo, ...
                'label', num2str(configNumber(i)+1),'marker_color',rand(1,3), ...
                'prune_stray_els', 1);
        else
            plot_electrode_config('el_config_info', elConfigInfo, ...
                'label', num2str(configNumber(i)+1),'prune_stray_els', 1);
        end
    else
        if doRandColor
            plot_electrode_config('el_config_info', elConfigInfo,...
                'marker_color',rand(1,3),'prune_stray_els', 1);
        else
            
            plot_electrode_config('el_config_info', elConfigInfo,...
                'marker_color','r','prune_stray_els', 1);
        end
        
        
    end
    
    
    
end
    
    
end