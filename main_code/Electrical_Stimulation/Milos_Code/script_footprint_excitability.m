
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    Footprint excitability      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        25. Aug 2013            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Written by Milos Radivojevic  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Experiment parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Configurations' directory %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    BASE_DIR            =       '/home/milosra/testings/matlab_stimscan/';    
    PLOT                =       1;                 % Not recommended ;)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Configurations settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   Recording electrodes
    Axonal_trunk            =      [1780 2085 2391 2595 2799 3208 3616 4125 4329 4635 5044 5452 5757 6165 6472 6677 6882 7292 7699];
    Branch_1                =      [2083 2080 2384 2584 2786 2988 3598 3593 3596 3396];
    Branch_2                =      [3108 3212 3318 3422 3424 3528 3529];
    Branch_3                =      [4532 4735 4733 4731 4829 4827 5030 5335 5435];
    Branch_4                =      [5657 5761 5967 5968 6071 6176 6075 6179];
    Recording_electrodes    =      [Axonal_trunk Branch_1 Branch_2 Branch_3 Branch_4];

%   Stimulation electrodes
    Stim_el                 =      [755 756 757 758 759 760 761 762 856 857 858 859 860 861 862 863 864 958 959 960 961 962 963 964 965 966 1060 1061 ...
                                    1062 1063 1064 1065 1066 1067 1068 1162 1163 1164 1165 1166 1167 1168 1169 1170 1264 1265 1266 1267 1268 1269 ... 
                                    1270 1271 1272 1366 1367 1368 1369 1370 1371 1372 1374 1471 1473 1475];  % Use "plotelectrodenumbers" or "clickelectrode" to get elcs of interest

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stimulation settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   Single-electrode stimulation
    Stim_el_volt        =       100;            % Stimulation voltage
    StimNumberExp       =       60;             % Number of stimulations in experiment sections
    chipaddress         =       1;              % "slot" where chip is plugged [0-4]
    stim_mode           =       1;              % [previous==0; voltage==1; current==2]
    phase               =       200;            % [us; microseconds]
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%   Removal of stimulation electrode(s) from available electrodes
    if ismember(Stim_el,Recording_electrodes)
       S                =       find(ismember(Recording_electrodes,Stim_el));
       Recording_electrodes(S) =       [];
    end
    
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Open FPGA server socket %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fpga_sock = tcpip('11.0.0.7',32125);
fopen(fpga_sock);
 
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Generate configuration with one stimulation electrode %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if PLOT
    figure('Name', 'config');
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

for configs             =       1:length(Stim_el);   
   
    if configs > 1
        pause(2)
    end
    
%   make neuropos file 
    neuroposfile=[BASE_DIR sprintf('%03d.neuropos.nrk',  configs-1)];
    fid = fopen(neuroposfile, 'w');
    
%   stimulation electrodes

%   Random selection of stimulation electrode
    STIM_EL          = Stim_el(configs);

    for i=1:length(STIM_EL)
        [x y]=el2position( STIM_EL(i) );
        fprintf(fid, 'Neuron matlab%i: %d/%d, 10/10, stim\n',i,round(x),round(y));
    end 

%   Electrodes without stimulation request
    electrodes      =       Recording_electrodes;

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
        st1 = find(ismember(Stim_el, STIM_EL));

        al=find(ismember(Recording_electrodes, elidx));  
        missed_recs=setdiff(Recording_electrodes, elidx);
    
    if PLOT

    %   plot stimulation sites
        plot(mposx(stimulation_site+1),mposy(stimulation_site+1),'sk', 'color', 'b');

    %   plot recording sites
        plot(mposx(Recording_electrodes(al)+1),mposy(Recording_electrodes(al)+1),'o', 'color', 'g');

    %   plot missed recording sites
        plot(mposx(missed_recs+1),mposy(missed_recs+1),'x', 'color', 'r');
    end
    
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot missed stimulation sites %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    for i=1:length(Stim_el)
        plot(mposx(Stim_el(i)+1),mposy(Stim_el(i)+1),'x', 'color', 'r');
    end
        
electrodes = stimulation_site;        
savefile = 'electrodes.mat';
save(savefile, 'electrodes')

pause(10)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Close FPGA server socket %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fclose(fpga_sock);
fclose('all');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
