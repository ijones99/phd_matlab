function plot_footprint_from_h5data(h5Data, ts, varargin)
% PLOT_FOOTPRINT_FROM_H5DATA(h5Data, ts)

ampScale = 30;
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'scale')
            ampScale  = varargin{i+1};
   
        end
    end
end

preSpikeTime = 40; % in samples
postSpikeTime = 40; % in samples


plotColor = 'k';

[data] = extract_waveforms_from_h5(h5Data{1}, ts, ...
    'pre_spike_time', preSpikeTime,'post_spike_time',postSpikeTime );
%%
avgData = data.average';
dataOffsetCorr = avgData-repmat(...
            mean(avgData(end-30:end,:),1),...
            size(avgData,1),1);
h=figure;
gui.plot_hidens_els('marker_style', 'cx'), hold on 
        
        
plot_footprints_simple([data.x data.y], ...
    dataOffsetCorr', ...
    'input_templates','hide_els_plot',...
    'plot_color','b', 'plot_color', plotColor,'scale', ampScale);


end