function [mposx mposy mat footprintwaveforms  footprintinfo]   = construct_footprint_from_mea1_data(mea1, ...
    umsclusno, selspiketimes, varargin)

doDebug=0;
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'debug')
            doDebug = 1;
        end
    end
end


%% plot the footprint

footprintinfo = {};
% for movie
mposx = [];
mposy = [];
mat = [];
footprintinfo.el_idx = [];
footprintinfo.x = [];
footprintinfo.y = [];

maxnumwfs = 300;
minnumwfs = 20;
footprintwaveforms = [];


clusterinds = [];
for i = 1:length(mea1)
    %     try
    if iscell(selspiketimes)
        selSpikeTimes = selspiketimes{i};
    else
        selSpikeTimes = selspiketimes;
    end
    if size(selSpikeTimes,2) == 2
        
        clusterinds = find(selSpikeTimes(:,1)==umsclusno);
    else
        % the case when only times are given (no inds)
        clusterinds = 1:length(selSpikeTimes);
    end
        
        
    if length(clusterinds) > minnumwfs
        try
            if length(clusterinds) > maxnumwfs
                clusterinds = clusterinds(1:maxnumwfs);
            end
            if size(selSpikeTimes,2) == 2
                spiketimessamples = selSpikeTimes(clusterinds,2);
            else
                spiketimessamples = selSpikeTimes;
            end
            h5data = mea1{i};
            [data] = extract_waveforms_from_h5(h5data, spiketimessamples );
            
            dataoffsetcorr = data.average-repmat(mean(data.average(:,end-30:end),2),1,size(data.average,2));
            footprintwaveforms = [footprintwaveforms; dataoffsetcorr];
            
            mposx = [mposx ; data.x];
            mposy = [mposy ; data.y];
            footprintinfo.el_idx = [footprintinfo.el_idx; data.el_idx];
            footprintinfo.x = [footprintinfo.x; data.x];
            footprintinfo.y = [footprintinfo.y; data.y];
            
            mat   = [mat ; dataoffsetcorr ];
            
            %     catch
            %         fprintf('no spikes for %d.\n', i)
            %     end
            if doDebug
                if i==1
                    figure, hold on;
                end
                plot_footprints_simple([footprintinfo.x footprintinfo.y], ...
                    footprintwaveforms, ...
                    'input_templates','hide_els_plot',...
                    'plot_color','b', 'flip_templates_ud','flip_templates_lr','scale', 45);
                title(num2str(i));
                i
                junk = input('press key');
            end
            
        end
    else
        fprintf('Too few waveforms for %d\n', i)
    end
    progress_info(i,length(mea1))
end





end