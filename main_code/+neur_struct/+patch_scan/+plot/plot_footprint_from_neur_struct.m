function [nrg ah ] = plot_footprint_from_neur_struct(...
    neur, doPlotNeuroRouter, varargin)
% function [nrg ah ] = plot_footprint_from_neur_struct(...
%     neurons, doPlotNeuroRouter, varargin)
%
% varargin:
%   cluster_no: selected cluster number(s)
%   cluster_idx: selected index/indices of neurons (takes priority over
%       cluster_no specification)


clusterNo = [];
clusterNoAll = [];
clusterIdx = [];
specifyPlotColor = [];
ah = [];
ampScale = 1;

% get all cluster numbers
for iNeur = 1:length(neur.neurons)
    clusterNoAll(iNeur) = neur.neurons{iNeur}.cluster_no;
end

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'cluster_no')
            clusterNo = varargin{i+1};
        elseif strcmp( varargin{i}, 'cluster_idx')
            clusterIdx = varargin{i+1};
        elseif strcmp( varargin{i}, 'plot_color')
            specifyPlotColor = varargin{i+1};
        elseif strcmp( varargin{i}, 'fig_h')
            ah = varargin{i+1};
        elseif strcmp( varargin{i}, 'scale')
            ampScale = varargin{i+1};
        end
    end
end

% if there is no value for cluster number, then set to all clusters
if isempty(clusterNo) 
    clusterNo = clusterNoAll;
end

% if no cluster index is specified, find index by cluster number
if isempty(clusterIdx)
    [clusterIdx junk ] = multifind(clusterNoAll,clusterNo,'J');
end

%% plot the footprint

if doPlotNeuroRouter & isempty(ah)
    nrg = nr.Gui;
    set(gcf, 'currentAxes',nrg.ChipAxesBackground);
    ah = nrg.ChipAxes;

end

for i=1:length(clusterIdx)
    try
        dataOffsetCorr = neur.neurons{clusterIdx(i)}.template.data-repmat(...
            mean(neur.neurons{clusterIdx(i)}.template.data(end-30:end,:),1),...
            size(neur.neurons{clusterIdx(i)}.template.data,1),1);
        
        if isempty(specifyPlotColor)
            plotColor = rand(1,3);
        else
            plotColor =specifyPlotColor;
        end
        
        if doPlotNeuroRouter
            plot_footprints_simple([neur.neurons{clusterIdx(i)}.x' neur.neurons{clusterIdx(i)}.y'], ...
                dataOffsetCorr', ...
                'input_templates','hide_els_plot','format_for_neurorouter','flip_templates_lr',...
                'plot_color','b', 'flip_templates_ud', ...
                'plot_color', plotColor,'scale', ampScale);
        else
            plot_footprints_simple([neur.neurons{clusterIdx(i)}.x' neur.neurons{clusterIdx(i)}.y'], ...
                dataOffsetCorr', ...
                'input_templates','hide_els_plot',...
                'plot_color','b', 'plot_color', plotColor,'scale', ampScale);
        end
        
    catch
        fprintf('No spikes for %d.\n', clusterIdx(i))
    end
    drawnow
    
    if ~doPlotNeuroRouter
        axis equal
    end
    progress_info(clusterIdx(i),length(neur.neurons))
end

if ~exist('nrg', 'var')
   nrg = []; 
end

















end