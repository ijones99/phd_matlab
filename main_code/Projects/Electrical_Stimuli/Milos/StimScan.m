function StimScan(varargin)
% Milos Radivojevic 2013
%
%      StimScan(varargin)
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



SELECTED_AREA = 0;
PLOT = 1;

i=1;
while i<=length(varargin)
    if not(isempty(varargin{i}))
        if strcmp(varargin{i}, 'no_plot')
            PLOT=0;
        elseif strcmp(varargin{i}, 'scanned_area')
            i=i+1;
            SELECTED_AREA = 1;
            elc_to_take=varargin{i};
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
        else
            fprintf('unknown argument at pos %d\n', 1+i);
        end
    end
    i=i+1;
end


if SELECTED_AREA
    available_els       =       elc_to_take;
else
    available_els       =       [1 : 11011];
end

%   Removal of stimulation electrode(s) from available electrodes

STIM_EL             =       Stim_el;
if ismember(STIM_EL,available_els)
    S                =       find(ismember(available_els,STIM_EL));
    available_els(S) =       [];
end

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
    
    loop             =       stimloop;
    
    enable=0; dacSel=0; cLarge=0; channel=0; broadcast=1;
    loop.push_connect_channel(Chipaddress, enable, dacSel, cLarge, channel, broadcast);
    enable=1; dacSel=0; cLarge=0; channel=stimChNo(i); broadcast=0;
    loop.push_connect_channel(Chipaddress, enable, dacSel, cLarge, stimChNo(i), broadcast); % first channel
    loop.flush();
    pause(3)
    
    epoch               =        configs-1;
    
    %   Single-electrodes stimulation
    
    for Single_stim                =    1:StimNumberExp
        
        %   Stimulus with DAC2 encoding
        delay            =       300;
        volt             =       Stim_el_volt;
        dacselection  	 =       0;
        channel             =    stimChNo(1);
        loop.push_biphasic_pulse(Chipaddress, 0, channel, volt, Phase/50, epoch, round(delay*20), Stim_mode);
        loop.push_simple_delay(delay)
        loop.flush();
    end
end

plot(mposx(available_els+1), mposy(available_els+1), 'sk', 'MarkerEdgeColor','k','MarkerFaceColor', [1 1 1]*.8);