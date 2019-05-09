function out = set_stim_and_readout_els( out , saveFileName, varargin)
% function out = SET_STIM_AND_READOUT_ELS( out , saveFileName, varargin)
% varargin
%   dir_path: set directory path
%   save: 0 or 1 to save file
%
% author: ijones
numPts = 6; 
saveDir = '';
doSave = 1;
h = [];
suppressXYLims = 0;
xyUnique = 0;
stimReadoutSame = 0;
doSelAxonElsManually = 1;
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'dir_path')
            saveDir = varargin{i+1};
        elseif strcmp( varargin{i}, 'save')
            doSave = varargin{i+1};
        elseif strcmp( varargin{i}, 'fig_h')
            h = varargin{i+1};
        elseif strcmp( varargin{i}, 'suppress_xy_lims')
            suppressXYLims = 1;
        elseif strcmp( varargin{i}, 'xy_from_all_flists')
            xyUnique = 1;
        elseif strcmp( varargin{i}, 'stim_and_readout_same')
            stimReadoutSame = 1;
            fprintf('set_stim_and_readout_els: same stim and readout.\n')
        elseif strcmp( varargin{i}, 'sel_only_somatic_els')
            doSelAxonElsManually = 0;
            fprintf('select only axonal els.\n');
        end
    end
end

if isempty(h)
%     h = figure, hold on
end
if xyUnique
    xVals = out.x_unique;
    yVals = out.y_unique;
    elIdxVals = out.el_idx_unique;
else
    xVals = out.x;
    yVals = out.y;
    elIdxVals = out.el_idx;
end
    
if ~iscolumn(elIdxVals)
    elIdxVals = elIdxVals';
end
plot_el_pos(xVals,yVals,elIdxVals,'plot_style', 'r+','text_offset', [1 1]);

% set x and y limits
if ~suppressXYLims
    set(h, 'Position', [274          56        1107        1042]);
    minMaxX = [min(xVals) max(xVals)];
    minMaxY = [min(yVals) max(yVals)];
    
    xlim([minMaxX(1)-50 minMaxX(2)+50] );
    ylim([minMaxY(1)-50 minMaxY(2)+50] );
    axis equal
end



% set somatic stim, axonal response
junk = input('select somatic stimulus els');

[a b] = select_els_in_sel_pt_polygon( out, 'num_points',...
    numPts, 'fig_h', h)
stimEls.soma = a;

if doSelAxonElsManually
    junk = input('select axonal stimulus els');
    [a b] = select_els_in_sel_pt_polygon( out, 'num_points', ...
        numPts, 'fig_h', h);
    stimEls.axon = a;
else
    axonElIdxInds = find(~ismember(out.el_idx_unique,stimEls.soma));
    stimEls.axon = out.el_idx_unique(axonElIdxInds);
end
out.stim_in_out.stim_els = stimEls;


if doSave
    save(fullfile(saveDir,saveFileName), 'out');
end
end