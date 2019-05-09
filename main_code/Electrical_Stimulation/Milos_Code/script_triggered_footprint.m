
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     Triggered footprint       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        27. Aug 2013            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Written by Milos Radivojevic  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Experiment parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Configurations' directory %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

BASE_DIR            =       '/home/milosra/testings/matlab_stimscan/';
PLOT                =       1;                 % Not recommended ;)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Configurations settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Scanned area
xmin = 600; xmax = 1000;

ymin = 500; ymax = 1100;

% Size of blocks
x_block = 6; y_block = 12;

% XY overlap
x_overlap = 2; y_overlap = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stimulation settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   Single-electrode stimulation
Stim_el             =       1;              % Use "plotelectrodenumbers" or "clickelectrode" to get elcs of interest
Stim_el_volt        =       100;            % Stimulation voltage
StimNumberExp       =       60;             % Number of stimulations in experiment sections
chipaddress         =       1;              % "slot" where chip is plugged [0-4]
stim_mode           =       1;              % [previous==0; voltage==1; current==2]
phase               =       200;            % [us; microseconds]

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Open FPGA server socket %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fpga_sock = tcpip('11.0.0.7',32125);
fopen(fpga_sock);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Generate configuration with one stimulation electrode %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
    
    if configs > 1
        pause(15)
    end
    
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
    %ndr_exe='`which NeuroDishRouter`';
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
    
    epoch               =        configs-1;
    
    %   Single-electrodes stimulation
    
    for Stim                =    1:StimNumberExp
        
    %   First pulse without DAC2 encoding
        delay               =    300;
        volt                =    Stim_el_volt;
        dacselection        =    0;
        channel             =    stimChNo(1);
        Stim_pulse          =    [(chipaddress),(dacselection),(channel),(ceil(volt)/2.9),((ceil(phase/50))),(epoch),(0),(round(delay*20)),(stim_mode)];
        Stim_pulse          =    (int16(Stim_pulse));
        fwrite(fpga_sock,Stim_pulse,'int16');                  % send stimulation
    end
end

pause(10)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Close FPGA server socket %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fclose(fpga_sock);
fclose('all');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
