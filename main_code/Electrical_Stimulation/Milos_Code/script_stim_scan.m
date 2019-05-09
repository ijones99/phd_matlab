
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          StimScan              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        26. Aug 2013            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Written by Milos Radivojevic  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Experiment parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Configurations' directory %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    BASE_DIR            =       '/home/milosra/testings/matlab_stimscan/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Options %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    PLOT                =       1;                 % Not recommended ;)
    SELECTED_AREA       =       1;              % Scan selected area only (define variable 'elc_to_take')
    MULTIPLE_SITE_STIM  =       1;              % Use two (or more) stimulation electrodes

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% General settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    chipaddress         =       1;              % "slot" where chip is plugged [0-4]
    stim_mode           =       1;              % [previous==0; voltage==1; current==2]
    phase               =       200;            % [us; microseconds]
    StimNumberExp       =       60;             % Number of stimulations in experiment sections

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stimulation settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%   Recording electrodes
    elc_to_take         =       [];             % Use "plotelectrodenumbers" or "clickelectrode" to get elcs of interest

%   Single-electrode stimulation
    Stim_el             =       300;            % Stimulation electrode with DAC encoding
    Stim_el_volt        =       100;            % Stimulation voltage

%   Two-electrodes stimulation
    Stim_el_1           =       11011;          % First stimulation electrode without DAC encoding
    Stim_el_2           =       300;            % Second stimulation electrode with DAC encoding
    Stim_el_1_volt      =       50;             % Stimulation voltage for first elc
    Stim_el_2_volt      =       100;            % Stimulation voltage for second elc
    ISI                 =       5;              % Interstimulut interval (min ==1[ms])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
if SELECTED_AREA
    available_els       =       elc_to_take;
else
    available_els       =       [1 : 11011];
end

if MULTIPLE_SITE_STIM
    STIM_EL             =       [Stim_el_1 Stim_el_2];
else
    STIM_EL             =       Stim_el;
end
    
%   Removal of stimulation electrode(s) from available electrodes
    if ismember(STIM_EL,available_els)
       S                =       find(ismember(available_els,STIM_EL));
       available_els(S) =       [];
    end
    
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Open FPGA server socket %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fpga_sock = tcpip('11.0.0.7',32125);
fopen(fpga_sock);
 
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Generate random configuration with N fixed electrodes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

col=hsv(120);

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

for configs             =       1:100   
   
    if configs > 1
        pause(2)
    end
    
%   make neuropos file 
    neuroposfile=[BASE_DIR sprintf('%03d.neuropos.nrk',  configs-1)];
    fid = fopen(neuroposfile, 'w');

%   stimulation electrodes
    for i=1:length(STIM_EL)
        [x y]=el2position( STIM_EL(i) );
        fprintf(fid, 'Neuron matlab%i: %d/%d, 10/10, stim\n',i,round(x),round(y));
    end 

%   Number of recording channels (N)
    if length(available_els(1,:,1)) > 125
        N = 125;
    elseif length(available_els(1,:,1)) > 100
        N = 100;
    elseif length(available_els(1,:,1)) > 80
        N = 80;
    elseif length(available_els(1,:,1)) > 60
        N = 60;
    elseif length(available_els(1,:,1)) > 40
        N = 20;
    elseif length(available_els(1,:,1)) > 20
        N = 10;
    else
        break, 
    end;   

%   Random selection of N electrodes
    electrodes          = randsample(available_els, N);
 
%   Electrodes without stimulation request
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

%   Exclude electrodes used i previous configuration
    I=find(ismember(available_els,elidx));
    available_els(I)    = [];  
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Reload & visualize configuratio %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if PLOT

%   plot stimulation sites
        for i=1:length(STIM_EL)
            plot(mposx(STIM_EL(i)+1),mposy(STIM_EL(i)+1),'sk','MarkerEdgeColor', 'k', 'MarkerFaceColor', 'r');
        end
        ss =randperm(100,1);
   plot(mposx(elidx+1), mposy(elidx+1), 'o','color',col(ss,:)); 
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

    if MULTIPLE_SITE_STIM

%   Two-electrodes stimulation

        for Stim                =    1:StimNumberExp  

        %   First pulse without DAC2 encoding
            delay               =    300;   
            volt                =    Stim_el_1_volt;
            dacselection        =    2;
            channel             =    stimChNo(1);
            First_pulse         =    [(chipaddress),(dacselection),(channel),(ceil(volt)/2.9),((ceil(phase/50))),(epoch),(0),(round(delay*20)),(stim_mode)];
            First_pulse         =    (int16(First_pulse));
            fwrite(fpga_sock,First_pulse,'int16');                  % send stimulation

        %   Second pulse with DAC2 encoding
            delay               =    ISI;   
            volt                =    Stim_el_2_volt;
            dacselection        =    0;
            channel             =    stimChNo(1);
            Second_pulse        =    [(chipaddress),(dacselection),(channel),(ceil(volt)/2.9),((ceil(phase/50))),(epoch),(0),(round(delay*20)),(stim_mode)];
            Second_pulse        =    (int16(Second_pulse));
            fwrite(fpga_sock,Second_pulse,'int16');                 % send stimulation
        end
    else
        
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
    
    plot(mposx(available_els+1), mposy(available_els+1), 'sk', 'MarkerEdgeColor','k','MarkerFaceColor', [1 1 1]*.8);
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Close FPGA server socket %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fclose(fpga_sock);
fclose('all');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
