function signalplotter(ntk2, varargin)

%SIGNALPLOTTER   plot recorded signals
%
%   SIGNALPLOTTER(NTK2) plots signals of the first ten recorded channels for the
%   first ten seconds.
%
%   SIGNALPLOTTER(..., 'samples', SAMPL) plots signals in the range of the
%   indices defined in SAMPL. For example SAMPL=1000:2000 plots the signals in
%   that range.
%
%   SIGNALPLOTTER(..., 'max_samples', M_SAMPL) plots signals in the index range
%   of 1:M_SAMPL.
%
%   SIGNALPLOTTER(..., 'chidx', CH_IDX) plot only channels defined in the vector
%   CH_IDX. If CH_IDX is empty, first 10 channels are plotted.
%
%   SIGNALPLOTTER(..., 'elidx', EL_IDX) plot only channels for the
%   electrodes defined in
%   EL_IDX.
%
%   SIGNALPLOTTER(..., 'max_channels',CH) plots the first channels up to channel
%   CH. Default: CH=10.
%
%   SIGNALPLOTTER(..., 'neurons',NNN.NEURONS) sets marker on timestamps of
%   sorted neurons NNN.NEURONS.
%
%   SIGNALPLOTTER(..., 'neurons',NNN.NEURONS,'tspos_style',STYLE) defines how
%   the timestamp is highlighted. STYLE can be 'markers' - for markers - or
%   'lines' - for highlightind the spike in a different color. If nor stated,
%   default is STYLE='markers'.
%
%   SIGNALPLOTTER(..., 'neurons',NNN.NEURONS,'nlist',N_LIST) takes only those
%   neurons into account that are specified in the vector N_LIST.
%
%   SIGNALPLOTTER(..., 'offsetf', FACT) sets the offset between the channels to
%   FACT times the maximum peak to peak amplitude signal. Default value is
%   FACT = 0.5.
%
%   SIGNALPLOTTER(..., 'offset', OFFS) sets the offset to the value OFFS, which
%   is given in uV.
%
%   SIGNALPLOTTER(..., 'Color', COL) sets the signal color to COL.
%
%   SIGNALPLOTTER(..., 'MarkerColor', MCOL) sets the marker color to MCOL.
%
%   SIGNALPLOTTER(..., 'width', width) set line width
%
%   SIGNALPLOTTER(..., 'text', TSTYLE) gives options for text: TSTYLE = 'full'
%   prints channel and electrode number on the figure. TSTYLE = 'simple' only
%   prints signal number. TSTYLE = 'no_text' disables text.
%
%   SIGNALPLOTTER(..., 'xunit', UNIT) sets the unit of the x scale. UNIT can be
%   's' or 'ms' or 'samples', defalut is 'ms'.
%
%   SIGNALPLOTTER(..., 'xrel') start x-axis with zero.
%
%   SIGNALPLOTTER(..., 'zeroMean') removes offset of all channels. This way also
%   unfiltered data (ntk1) can be used.
%
%   SIGNALPLOTTER(..., ARGS)
%   ARGS can be:    - 'noxlabel':   disable xlabel
%                   - 'noylabel':   disable ylabel
%                   - 'xrel':       shift x scale so that it always starts at 1
%
%   SIGNALPLOTTER(..., 'ylim', YLIM) set Y limits to YLIM = [YMIN YMAX]
%
%   SIGNALPLOTTER(...,'eventDetection') apply threshold event detection on data
%   and marks events of every channel. This mode can be used with both different
%   'tspos_style'-configurations 'markers' and 'lines'.
%
%   SIGNALPLOTTER(...,'eventDetection', 'thr_f', THRF) use THRF as threshold
%   factor. Default value is 4.5. See the event detection function
%   simple_event_cut for more information.
%
%   SIGNALPLOTTER(...,'yLableChannels') channel-label on Y-axis
%
%   SIGNALPLOTTER(..., 'mark_one_channel_only') mark every neuron only on
%   according channel
%
%   SIGNALPLOTTER(..., 'separate') plot channels in different windows,
%   works in combination with the 'chidx' argument
%   SIGNALPLOTTER(..., 'separate','chs_per_window',CHS) no. of channels per
%   window
%
%   SIGNALPLOTTER(..., 'sort_els') sort electrodes according to
%   electrode number




% Author:   ufrey/jaeckeld
% Docu:     jaeckeld

samples=[];
channel_idxlist=[];
el_idxlist=[];
max_samples=200000;
max_channels=10;
neurons=[];
n_list=[];
abs_offset=[];
offsetf=0.8;
tspos_style='markers';
markersize=6;
l_color=[];
n_marker_col=[];
do_xrel=0;
text_style='full';
ylims=[];
xunit='ms';
zeromean=0;
event_detection=0;
thr_f=4.5;
width=1.5;

halfWaveRectify=0;
do_neo=0;

mark_one_channel_only=0;
p_ylable=1;
p_xlable=1;
ylable_channels=0;

separate=0;
chs_per_window=[];
sort_els=0;

i=1;
while i<=length(varargin)
    if not(isempty(varargin{i}))
        if strcmp(varargin{i}, 'samples')
            i=i+1;
            samples=varargin{i};
        elseif strcmp(varargin{i}, 'chidx')
            i=i+1;
            channel_idxlist=varargin{i};
        elseif strcmp(varargin{i}, 'elidx')
            i=i+1;
            el_idxlist=varargin{i};
        elseif strcmp(varargin{i}, 'max_samples')
            i=i+1;
            max_samples=varargin{i};
        elseif strcmp(varargin{i}, 'max_channels')
            i=i+1;
            max_channels=varargin{i};
        elseif strcmp(varargin{i}, 'neurons')   %if using neurons, make sure filters are as in raw data
            i=i+1;
            neurons=varargin{i};
        elseif strcmp(varargin{i}, 'nlist')
            i=i+1;
            n_list=varargin{i};
        elseif strcmp(varargin{i}, 'offset')
            i=i+1;
            abs_offset=varargin{i};
        elseif strcmp(varargin{i}, 'offsetf')
            i=i+1;
            offsetf=varargin{i};
        elseif strcmp(varargin{i}, 'tspos_style')
            i=i+1;
            tspos_style=varargin{i};
        elseif strcmp(varargin{i}, 'Color')
            i=i+1;
            l_color=varargin{i};
        elseif strcmp(varargin{i}, 'width')
            i=i+1;
            width=varargin{i};
        elseif strcmp(varargin{i}, 'MarkerColor')
            i=i+1;
            n_marker_col=varargin{i};
        elseif strcmp(varargin{i}, 'MarkerSize')
            i=i+1;
            markersize=varargin{i};
        elseif strcmp(varargin{i}, 'text')
            i=i+1;
            text_style=varargin{i};
        elseif strcmp(varargin{i}, 'zeroMean')
            zeromean=1;
        elseif strcmp(varargin{i}, 'noylabel')
            p_ylable=0;
        elseif strcmp(varargin{i}, 'noxlabel')
            p_xlable=0;
        elseif strcmp(varargin{i}, 'xrel')
            do_xrel=1;
        elseif strcmp(varargin{i}, 'yLableChannels')
            ylable_channels=1;
        elseif strcmp(varargin{i}, 'ylim')
            i=i+1;
            ylims=varargin{i};
        elseif strcmp(varargin{i}, 'xunit')
            i=i+1;
            xunit=varargin{i};
        elseif strcmp(varargin{i}, 'eventDetection')
            event_detection=1;
        elseif strcmp(varargin{i}, 'halfWaveRectify')
            halfWaveRectify=1;
        elseif strcmp(varargin{i}, 'do_neo')
            do_neo=1;    
        elseif strcmp(varargin{i}, 'mark_one_channel_only')
            mark_one_channel_only=1;
        elseif strcmp(varargin{i}, 'separate')
            passargin=varargin;
            passargin(i)=[];
            separate=1;
        elseif strcmp(varargin{i}, 'chs_per_window')
            i=i+1;
            chs_per_window=varargin{i}; 
        elseif strcmp(varargin{i}, 'sort_els')
            sort_els=1;
        elseif strcmp(varargin{i}, 'thr_f')
            i=i+1;
            thr_f=varargin{i};
        else
            fprintf('unknown argument at pos %d\n', 1+i);
        end
    end
    i=i+1;
end

if separate
    if isempty(channel_idxlist)
        channel_idxlist=1:length(ntk2.x);
    end
    if sort_els
        [a inde]=sort(ntk2.el_idx(channel_idxlist));
        channel_idxlist=channel_idxlist(inde);
    end
    if isempty(chs_per_window)
        chs_per_window=10;
    end
    
    for i=1:ceil(length(channel_idxlist)/chs_per_window)
        chs_to_plot=((i-1)*chs_per_window+1):min([(((i-1)*chs_per_window+1)+chs_per_window-1) length(channel_idxlist)]);
        j=1;
        while j<=length(passargin)
            if strcmp(passargin{j}, 'chidx')
                passargin(j+1)=[];
                passargin(j)=[];
            else
                j=j+1;
            end
        end
        figure;
        signalplotter(ntk2,'chidx',channel_idxlist(chs_to_plot),passargin{:})
    end
    return
end

if event_detection                      % only for event detection: remove bad channels first, as they are removed also by the function simple_event_cut
    ntk2=detect_valid_channels(ntk2,1);
end

if strcmp(xunit, 'ms')
    x_scale=1000;
elseif strcmp(xunit, 's')
    x_scale=1;
elseif strcmp(xunit, 'samples')
    x_scale=ntk2.sr;
else
    fprintf('wrong x unit\n')
    return
end

if zeromean
    u=ntk2.sig;
    u=u-repmat(mean(u),size(u,1),1);    % remove offset!
    ntk2.sig=u;
end

if not(isempty(el_idxlist))
    if not(isempty(channel_idxlist))
        error('signalplotter: please specify either elidx or chidx, but not both');
    end
    channel_idxlist=multifind(ntk2.el_idx, el_idxlist, 'J');
end

if isempty(channel_idxlist)
    channel_idxlist=1:min([size(ntk2(1).sig,2) max_channels]);
end
if sort_els
    [a inde]=sort(ntk2.el_idx(channel_idxlist));
    channel_idxlist=channel_idxlist(inde);
end
if isempty(samples)
    samples=1:min([size(ntk2(1).sig,1) max_samples]);
end


shiftx=1;
if do_xrel
    shiftx=samples(1);
end
if do_neo
    ntk2.sig=NEO(ntk2.sig,'method','SNEO','L',10);
end
if halfWaveRectify
    ntk2.sig(find(ntk2.sig<0))=0;
end

pkpk=0;
for i=1:size(ntk2,2)
    npkpk=max(max(ntk2(i).sig(samples, channel_idxlist)))-min(min(ntk2(i).sig(samples, channel_idxlist)));
    if npkpk>pkpk
        pkpk=npkpk;
    end
end

if isempty(n_list)
    n_list=1:length(neurons);
end

if isempty(l_color)
    l_color=lines(max_channels+1);
end


%offset shifted style
offset_val=abs_offset;
if isempty(abs_offset)
    offset_val=pkpk*offsetf;
end

%offset=((cumsum(ones(size(channel_idxlist,2),1))*ones(1,size(samples,2))-1)*offset_val)';

hold on

% Add text to
% FIXME: adding text is very slow
for i=1:length(channel_idxlist)
    plot((samples-shiftx)/ntk2.sr*x_scale, ntk2.sig(samples, channel_idxlist(i))+(i-1)*offset_val, 'Color', l_color(mod(i-1, size(l_color,1))+1,:),'LineWidth',width);
    if strcmp(text_style, 'full')
        text(double((samples(1)-shiftx+0.01*length(samples))/ntk2.sr*x_scale), double((i-0.85)*offset_val), sprintf('ch%d, el%d', channel_idxlist(i), ntk2.el_idx(channel_idxlist(i))));
    elseif strcmp(text_style, 'simple')
        text(double((samples(1)-shiftx+0.01*length(samples))/double(ntk2.sr)*x_scale), double((i-0.85)*offset_val), sprintf('%d',i));
    elseif strcmp(text_style, 'none')
        % don't put any text
    end
end
if p_xlable
    xlabel(['Time [' xunit ']']);
else
    set(gca,'XTickLabel', [])
end
if p_ylable
    ylabel('Amplitude [\muV]')
else
    set(gca,'YTickLabel', [])
end

if ylable_channels
    yposits=((1:length(channel_idxlist))-1)*offset_val;
    set(gca,'YTick',yposits)
    set(gca,'YTickLabel',channel_idxlist)
    if p_ylable
        ylabel('Channel')
    end
end



xlim(([samples(1) samples(end)]-shiftx)/ntk2.sr*x_scale)
if isempty(ylims)
    ylims=[-0.5 length(channel_idxlist)-0.5]*offset_val;
end
ylim(ylims);
box on


%plot timestamps
n_nr=0;
if isempty(n_marker_col)
    % TODO: fix this hack!!
    % n_marker_col=lines(length(n_list)); %too many, but doesn't matter
    n_marker_col=lines(20); %too many, but doesn't matter FIX!!!!!
    
end
for i=1:length(n_list)
    n=neurons{n_list(i)};
    
    % added to resolve t_base problem, check if works properly. (jaeckeld)
    if isfield(n,'finfo')
        n.ts=n.ts-double(n.finfo{1}.first_frame_no);
    end
    
    if strcmp(n.fname, ntk2.fname)
        
        if not(isfield(n,'loc'))        % jaeckeld: seems to work..
            %              n=triangulate_neuron(n);     % nonsense...
            n.loc.tspos=0;
        end
        n_nr=n_nr+1;
        [nci rci]=multifind(n.el_idx, ntk2.el_idx(channel_idxlist), 'J');
        if strcmp(tspos_style, 'markers')
            xpos=n.ts+n.ts_pos+round(n.loc.tspos);
            valid_xpos=multifind(xpos, samples);
            xpos=xpos(valid_xpos);
            if mark_one_channel_only
                plot((xpos-shiftx)/ntk2.sr*x_scale, ntk2.sig(xpos,channel_idxlist(rci(i)))+(rci(i)-1)*offset_val, '^', 'Color', n_marker_col(n_nr,:), 'MarkerSize', markersize);
            else
                for c=1:length(nci)
                    plot((xpos-shiftx)/ntk2.sr*x_scale, ntk2.sig(xpos,channel_idxlist(rci(c)))+(rci(c)-1)*offset_val, '^', 'Color', n_marker_col(n_nr,:), 'MarkerSize', markersize);
                end
            end
        elseif strcmp(tspos_style, 'lines')
            xpos=n.ts+n.ts_pos;
            xstart=xpos-n.event_param.pre2+1;
            xend=xpos+n.event_param.post2;
            validline=xend>=samples(1) & xstart<=samples(end);
            xstart=xstart(validline);
            xend=xend(validline);
            xend(xend>samples(end))=samples(end);
            xstart(xstart<samples(1))=samples(1);
            for e=1:length(xstart)
                tt=xstart(e):xend(e);
                if mark_one_channel_only
                    channel_idxlist2=channel_idxlist(i);
                    plot((repmat(tt, length(channel_idxlist2), 1)-shiftx)'/ntk2.sr*x_scale, ntk2.sig(tt, channel_idxlist2)+repmat((i-1)*offset_val,length(tt),1), 'Color', n_marker_col(n_nr,:), 'LineWidth', 1);
                else
                    plot((repmat(tt, length(channel_idxlist), 1)-shiftx)'/ntk2.sr*x_scale, ntk2.sig(tt, channel_idxlist)+repmat((0:length(channel_idxlist)-1)*offset_val,length(tt),1), 'Color', n_marker_col(n_nr,:), 'LineWidth', 1);
                end
            end
        end
    else
        warning('NTK and neurons do not have the same filename - do nothing');
        
    end
    
end

if event_detection
    
    % first do event detection
    
    pretime=16;
    posttime=16;
    
    working=ntk2;                       % only do event detection on specified samples
    working.sig=ntk2.sig(samples,:);    % (saves time!)
    
    allevents=simple_event_cut(working, thr_f, pretime, posttime);
    
    allevents.ts=allevents.ts+samples(1)-1;               % re-shift to real value
    allevents.ts_begin=allevents.ts_begin+samples(1)-1;
    allevents.ts_pos=allevents.ts_pos+samples(1)-1;
    allevents.ts_end=allevents.ts_end+samples(1)-1;
    
    channel_ts=cell(size(ntk2.el_idx));  %necessary for matlab 2009a (works in 2008b w/out this line)
    for i=1:length(ntk2.el_idx)
        if not(isempty(find(allevents.ch==i,1)))
            channel_ts{i}.ts=find(allevents.ch==i);
        end
    end
    
    % plot them
    for i=1:length(channel_idxlist)
        ch=channel_idxlist(i);
        
        if not(isempty(channel_ts{ch}))
            
            if strcmp(tspos_style, 'markers')
                xpos=allevents.ts(channel_ts{ch}.ts);  %n.ts_pos+round(n.loc.tspos);
                valid_xpos=multifind(xpos, samples);
                xpos=xpos(valid_xpos);
                
                plot((xpos-shiftx+pretime+1)/ntk2.sr*x_scale, ntk2.sig(xpos-shiftx+18,ch)+(i-1)*offset_val, '^', 'Color', n_marker_col(1,:), 'MarkerSize', markersize);
                
            elseif strcmp(tspos_style, 'lines')
                xstart=allevents.ts_begin(channel_ts{ch}.ts);
                xend=allevents.ts_end(channel_ts{ch}.ts);
                validline=xend>=samples(1) & xstart<=samples(end);
                xstart=xstart(validline);
                xend=xend(validline);
                xend(xend>samples(end))=samples(end);
                xstart(xstart<samples(1))=samples(1);
                for e=1:length(xstart)
                    tt=xstart(e):xend(e);
                    plot((tt-shiftx)/ntk2.sr*x_scale, ntk2.sig(tt, ch)+(i-1)*offset_val, 'Color', n_marker_col(1,:), 'LineWidth', 1);
                end
                
            end
            
        end
    end
    
end




