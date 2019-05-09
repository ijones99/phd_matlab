function TriggerFootprint(varargin)
% Milos Radivojevic 2013
%
%      TriggerFootprint(varargin)
%
%      'no_plot'         -    doesn't plot configurations
%      'path'            -    path and title of configurations
%      'stim_el'         -    stimulation electrode
%      'chipaddress'     -    slot where chip is pligged [0 - 4]
%      'stim_mode'       -    voltage == 1; current == 2
%      'phase'           -    half-duration of stimulation pulse (in us)
%      'stim_number'     -    number of stimulations per configuration
%      'stim_el_volt'    -    stimulation voltage
%      'scanned_area'    -    area of interest (use 'plotelectrodenumbers' or 'clickelectrode')
%      'el_up'           -    upper-left reference electrode (gives xmin & ymin)  
%      'el_down'         -    lower-right reference electrode (gives xmax & ymax)  
%      'x_overlap'       -    number of overlaping electrodes in x-axis
%      'y_overlap'       -    number of overlaping electrodes in y-axis
%      'x_block'         -    lenght of x  
%      'y_block'         -    lenght of y


PLOT = 1;

i=1;
while i<=length(varargin)
    if not(isempty(varargin{i}))
        if strcmp(varargin{i}, 'no_plot')
            PLOT=0;
        elseif strcmp(varargin{i}, 'path')
            i=i+1;
            BASE_DIR=varargin{i};
        elseif strcmp(varargin{i}, 'stim_el')
            i=i+1;
            Stim_el=varargin{i};
        elseif strcmp(varargin{i}, 'chipaddress')
            i=i+1;
            Chipaddress=varargin{i};
        elseif strcmp(varargin{i}, 'stim_mode')
            i=i+1;
            Stim_mode=varargin{i};
        elseif strcmp(varargin{i}, 'phase')
            i=i+1;
            Phase=varargin{i};
        elseif strcmp(varargin{i}, 'stim_number')
            i=i+1;
            StimNumberExp=varargin{i};
        elseif strcmp(varargin{i}, 'stim_el_volt')
            i=i+1;
            Stim_el_volt=varargin{i};
        elseif strcmp(varargin{i}, 'el_up')
            i=i+1;
            el_up=varargin{i};
        elseif strcmp(varargin{i}, 'el_down')
            i=i+1;
            el_down=varargin{i};
        elseif strcmp(varargin{i}, 'x_block')
            i=i+1;
            x_block=varargin{i};
        elseif strcmp(varargin{i}, 'y_block')
            i=i+1;
            y_block=varargin{i};
        elseif strcmp(varargin{i}, 'x_overlap')
            i=i+1;
            x_overlap=varargin{i};
        elseif strcmp(varargin{i}, 'y_overlap')
            i=i+1;
            y_overlap=varargin{i};
        else
            fprintf('unknown argument at pos %d\n', 1+i);
        end
    end
    i=i+1;
end

% Scanned area
[x,y] = el2position(el_up);
xmin = round(x);
ymin = round(y);

[x,y] = el2position(el_down);
xmax = round(x);
ymax = round(y);

version=2;
all_els=hidens_get_all_electrodes(version);

% hard params

x_dist=16.2;
y_dist=19.588;
b=2;    %um buffer

xmin=max([xmin min(all_els.x)]);
ymin=max([ymin min(all_els.y)]);

xmax=min([xmax max(all_els.x)]);
ymax=min([ymax max(all_els.y)]);

% how many blocks?

n_x_blocks=ceil((xmax-xmin)/((x_block+1-x_overlap)*x_dist));
n_y_blocks=ceil((ymax-ymin)/((y_block+1-y_overlap)*y_dist));

scan_els=cell(1,n_x_blocks*n_y_blocks);
c=0;

for i=1:n_x_blocks
    for j=1:n_y_blocks
        c=c+1;
        t_x_min=xmin+((i-1)*(x_block-x_overlap)*x_dist);
        t_y_min=ymin+((j-1)*(y_block-y_overlap)*y_dist);
        
        t_x_max=t_x_min+x_block*x_dist;
        t_y_max=t_y_min+y_block*y_dist;
        
        scan_els{c}=select_electrodes_in_range(t_x_min,t_x_max,t_y_min,t_y_max,'els',all_els);
    end
end

if PLOT
    figure('Name', 'configs');
    paper_w = 1070;
    paper_h = 1090;
    set(gcf,'Position',[1700 150 paper_w paper_h])
    set(gcf,'PaperPosition',[0 0 [paper_w paper_h]/70/3])
    set(gcf,'PaperSize',[paper_w paper_h]/85/3)
    axes('Position',[.08  .053  .833 .907]);
    fontsize = 4;
    
    [mposx mposy]=el2position([0:11015]);
    box on,    hold on;
    axis ij,   axis equal
    plot(mposx,mposy,'.','color',[1 1 1]*.93)
end

cmap=lines(length(scan_els));

for configs             =       1:length(scan_els);
    
    %   make neuropos file
    neuroposfile=[BASE_DIR sprintf('%03d.neuropos.nrk',  configs-1)];
    fid = fopen(neuroposfile, 'w');
    
    %   stimulation electrodes
    
    %   Random selection of stimulation electrode
    STIM_EL          = Stim_el;
    
    [x y]=el2position( STIM_EL );
    fprintf(fid, 'Neuron matlab%i: %d/%d, 10/10, stim\n',i,round(x),round(y));
    
    %   Electrodes without stimulation request
    electrodes      =       scan_els{configs}.el_idx;
    
    for i=1:length(electrodes)
        [x y]=el2position( electrodes(i) );
        fprintf(fid, 'Neuron matlab%i: %d/%d, 10/10\n',i,round(x),round(y));
    end
    fclose(fid);
    
    %   Execute NeuroDishRouter
    %ndr_exe='`which NeuroD/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/05.Aug.2013/proc/Chip1397/Triggered_footprint/el6953_120mvishRouter`';
    ndr_exe='/usr/local/hierlemann/hidens/head/bin/NeuroDishRouter -X';
    [pathstr, name, ext] = fileparts(neuroposfile);
    [~, name]            = fileparts(name);
    fname                = [pathstr '/' name];
    
    cmd=sprintf('%s -n -v 2 -l %s -s %s\n', ndr_exe, neuroposfile, [pathstr '/' name]);
    system(cmd);
    
    stimFilter = cell(1,length(STIM_EL));
    
    %   Extract routed electrodes
    el2fiName = [fname '.el2fi.nrk2'];
    fid=fopen(el2fiName);
    elidx=[];
    
    tline = fgetl(fid);
    while ischar(tline)
        [tokens] = regexp(tline, 'el\((\d+)\)', 'tokens');
        extractedElNo = str2double(tokens{1});
        elidx(end+1)= extractedElNo;
        for i=1:length(STIM_EL)
            if extractedElNo==STIM_EL(i)
                [tokens] = regexp(tline, '\((\w+), filter\)', 'tokens');
                stimFilter(i) = tokens{1};
            end
        end
        tline = fgetl(fid);
    end
    fclose(fid);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Reload & visualize configuratio %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if  ismember(STIM_EL, elidx);
        st = find(ismember(STIM_EL, Stim_el));
        stimulation_site(configs) = STIM_EL(st);
        %         st1 = find(ismember(Stim_el, STIM_EL));
        
        al=find(ismember(electrodes, elidx));
        %         missed_recs=setdiff(electrodes, elidx);
    end
    
    if PLOT
        
        %   plot stimulation sites
        plot(mposx(stimulation_site+1),mposy(stimulation_site+1),'sk', 'color', 'b');
        
        %   plot recording sites
        plot(mposx(electrodes(al)+1),mposy(electrodes(al)+1),'o', 'color', cmap(configs,:));
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Send configuration to chip %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %   Convert hex to cmdraw
    cmd=(['BitStreamer -n -f ' fname '.hex.nrk2']);
    system(cmd)
    
    %   Download to FPGA
    cmd=(['nc 11.0.0.7 32124 < ' fname '.cmdraw.nrk2']);
    system(cmd);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Extract the stimulation channel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    stimChNo = -1 * ones( 1, length( STIM_EL ) );
    for i=1:length(STIM_EL)
        stimChNo(i) = chName2chNo ( stimFilter{i} );
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stimulation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    loop             =       stimloop;
    enable=0; dacSel=0; cLarge=0; channel=0; broadcast=1;
    loop.push_connect_channel(Chipaddress, enable, dacSel, cLarge, channel, broadcast);
    enable=1; dacSel=0; cLarge=0; channel=stimChNo(i); broadcast=0;
    loop.push_connect_channel(Chipaddress, enable, dacSel, cLarge, stimChNo(i), broadcast); % first channel
    loop.flush();
    pause(3)
    
    epoch               =        configs-1;
    
    %   Single-electrodes stimulation
    
    for Stim                =    1:StimNumberExp
        %   Stimulus with DAC2 encoding
        delay            =       500;
        volt             =       Stim_el_volt;
        dacselection  	 =       0;
        channel             =    stimChNo(1);
        loop.push_biphasic_pulse(Chipaddress, 0, channel, volt, Phase/50, epoch, round(delay*20), Stim_mode);
        loop.push_simple_delay(delay)
        loop.flush();
    end
end
