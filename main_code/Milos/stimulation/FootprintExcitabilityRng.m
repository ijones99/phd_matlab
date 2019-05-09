
function FootprintExcitabilityRng(varargin)
% Milos Radivojevic 2013
%
%      FootprintExcitability(varargin)
%
%      'no_plot'         -    doesn't plot configurations
%      'path'            -    path and title of configurations
%      'stim_elcs'       -    stimulation electrode
%      'chipaddress'     -    slot where chip is pligged [0 - 4]
%      'stim_mode'       -    voltage == 1; current == 2
%      'phase'           -    half-duration of stimulation pulse (in us)
%      'stim_number'     -    number of stimulations per configuration
%      'stim_volt'       -    stimulation voltage

PLOT = 1;

i=1;
while i<=length(varargin)
    if not(isempty(varargin{i}))
        if strcmp(varargin{i}, 'no_plot')
            PLOT=0;
        elseif strcmp(varargin{i}, 'path')
            i=i+1;
            BASE_DIR=varargin{i};
        elseif strcmp(varargin{i}, 'stim_elcs')
            i=i+1;
            stim_elcs=varargin{i};
        elseif strcmp(varargin{i}, 'rec_elcs')
            i=i+1;
            rec_elcs=varargin{i};
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
        elseif strcmp(varargin{i}, 'stim_volt')
            i=i+1;
            stim_volt=varargin{i};
        else
            fprintf('unknown argument at pos %d\n', 1+i);
        end
    end
    i=i+1;
end

%   Removal of stimulation electrode(s) from available electrodes
if ismember(stim_elcs,rec_elcs)
    S                =       find(ismember(rec_elcs,stim_elcs));
    rec_elcs(S) =       [];
end

VoltN                   =       randperm(length(stim_volt(1,:,1)));

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

for configs             =       1:length(stim_elcs);
    
    %   make neuropos file
    neuroposfile=[BASE_DIR sprintf('%03d.neuropos.nrk',  configs-1)];
    fid = fopen(neuroposfile, 'w');
    
    %   stimulation electrodes
    STIM_EL          = stim_elcs(configs);
    
    for i=1:length(STIM_EL)
        [x y]=el2position( STIM_EL(i) );
        fprintf(fid, 'Neuron matlab%i: %d/%d, 10/10, stim\n',i,round(x),round(y));
    end
    
    %   Electrodes without stimulation request
    electrodes      =       rec_elcs;
    
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
        st = find(ismember(STIM_EL, stim_elcs));
        stimulation_site(configs) = STIM_EL(st);
        st1 = find(ismember(stim_elcs, STIM_EL));
        
        al=find(ismember(rec_elcs, elidx));
        missed_recs=setdiff(rec_elcs, elidx);
        
        if PLOT
            
            %   plot stimulation sites
            plot(mposx(stimulation_site+1),mposy(stimulation_site+1),'sk', 'color', 'b');
            
            %   plot recording sites
            plot(mposx(rec_elcs(al)+1),mposy(rec_elcs(al)+1),'o', 'color', 'g');
            
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
    
    loop             =       stimloop;
    enable=0; dacSel=0; cLarge=0; channel=0; broadcast=1;
    loop.push_connect_channel(Chipaddress, enable, dacSel, cLarge, channel, broadcast);
    enable=1; dacSel=0; cLarge=0; channel=stimChNo(i); broadcast=0;
    loop.push_connect_channel(Chipaddress, enable, dacSel, cLarge, stimChNo(i), broadcast); % first channel
    loop.flush();
    pause(3)
    
    epoch                   =       configs-1;
    
    %   Single-electrodes stimulation
    for Stim                =       1:StimNumberExp
        for i           	=       VoltN
            %   Stimulus with DAC2 encoding
            delay           =       300;
            volt            =       stim_volt(i);
            dacselection  	=       0;
            channel         =       stimChNo(1);
            loop.push_biphasic_pulse(Chipaddress, 0, channel, volt, Phase/50, epoch, round(delay*20), Stim_mode);
            loop.push_simple_delay(delay)
            loop.flush();                 % send stimulation
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot missed stimulation sites %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


for i=1:length(stim_elcs)
    plot(mposx(stim_elcs(i)+1),mposy(stim_elcs(i)+1),'x', 'color', 'r');
end

electrodes = stimulation_site;
savefile = 'electrodes.mat';
save(savefile, 'electrodes')
