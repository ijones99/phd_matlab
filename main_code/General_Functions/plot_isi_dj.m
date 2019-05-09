function plot_isi(neuron,varargin)

%PLOT_ISI  plot interspike intervall of neurons
%
%   PLOT_ISI(NEUR) plots ISI of neurons. NEUR can be a single neuron (e.g
%   nnn.neurons{1}, det_neur{1}) or a cell containing several neurons (e.g.
%   nnn.neurons or det_neur).  In this case all ISI diagrams are plotted.
%
%   PLOT_ISI(...,'max_time',TIME) limits the time axis up to TIME [ms] and
%   provides a better resolution (Default = 100). Chose TIME=0 for maximal
%   value, max_time is then the highest ISI.
%
%   PLOT_ISI(...,'n_bins',NBINS) set the number of bins (default = 50).
%
%   PLOT_ISI(...,'no_figure') plots without opening a new figure.
%
%   PLOT_ISI(...,'do_fr') plots also firing rate.
%
%   PLOT_ISI(...,'combine') plot combined ISI from all input neurons.


% Author: jaeckeld
          
maxt=80;
no_fig=0;
n_bins=50;
in_samples=0;
do_fr=0;
do_combine=1;

i=1;

while i<=length(varargin)
    if not(isempty(varargin{i}))
        if strcmp(varargin{i}, 'max_time')
            i=i+1;
            maxt=varargin{i};
        elseif strcmp(varargin{i}, 'n_bins')
            i=i+1;
            n_bins=varargin{i};
        elseif strcmp(varargin{i}, 'no_figure')
            no_fig=1;
        elseif strcmp(varargin{i}, 'in_samples')
            in_samples=1;            
        elseif strcmp(varargin{i}, 'do_fr')
            do_fr=1;        
        elseif strcmp(varargin{i}, 'combine')
            do_combine=1;              
        else
            fprintf('unknown argument at pos %d\n', 1+i);
        end
    end
    i=i+1;
end



sr=20000;

if ~no_fig
    
    if do_fr
        scrsz = get(0,'ScreenSize');
        figure('Position',scrsz);
    else
        figure
    end
end

if in_samples
    maxt=maxt*sr/1000;
end



if(iscell(neuron))
    hh=floor(sqrt(length(neuron)));
    ww=ceil(length(neuron)/hh);
    combined_ts=[];
    for i=1:length(neuron)
        subplot(hh,ww,i)
        
        if isfield(neuron{i},'glob_ts')
            ts=neuron{i}.glob_ts;
        else
            ts=neuron{i}.ts;
        end
        
        if ~in_samples
            ts=ts/sr*1000; %get ms
        end
        if do_combine
            combined_ts=[combined_ts ts];
        end
        isi=diff(sort(ts));
        
        if maxt>0
            
            isi=isi(isi<maxt);
        end

        hist(isi,n_bins)
        xlim([0 maxt]);
        if not(mod(i+ww-1,ww))
            ylabel('Spike count')
        end
        if i>(hh-1)*ww
            if ~in_samples
                xlabel('ISI [ms]')
            else
                xlabel('ISI [samples]')
            end
        end
        
        if do_fr
            fr=length(ts)/((max(ts)-min(ts))/1000); % [s]
            xlimm=get(gca,'XLim');
            ylimm=get(gca,'YLim');
            ytextpos1=ylimm(2)*0.8;%-(ylimm(2)-ylimm(1))/20;
%             ytextpos2=ylim(2)-(ylim(2)-ylim(1))*1.6/20;
            xtextpos=xlimm(1)+(xlimm(2)-xlimm(1))/20;
            text(xtextpos,ytextpos1,['FR = ',num2str(fr), ' Hz'],'color','r')
%             text(xtextpos,ytextpos2,['std amplitude = ',int2str(std(pktpks))],'color','r')
            
        end
        
        title(['Neuron ',int2str(i)]);
 
                
    end;
    if do_combine
        isi=diff(sort(combined_ts));
        if maxt>0
            isi=isi(isi<maxt);
        end
        figure
        hist(isi,n_bins)
        xlim([0 maxt]);
        title('combined neurons')
    end
else
    
    if isfield(neuron,'glob_ts')
        ts=neuron.glob_ts;
    else
        ts=neuron.ts;
    end
    if ~in_samples
            ts=ts/sr*1000; %get ms
    end
        
    
    isi=diff(sort(ts));
    
    if maxt>0
        xlim([0 maxt]);
        isi=isi(isi<maxt);
    end
    
    hist(isi,n_bins)
    
    if ~in_samples
        xlabel('ISI [ms]')
    else
        xlabel('ISI [samples]')
    end
    ylabel('Spike count')
    title('Interspike Interval Histogram');
    

end
