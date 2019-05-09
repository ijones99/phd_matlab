function out = DetectElectrode(varargin)
% Milos Radivojevic 2013
%
%      MakeConfig(varargin)
%
%      'nosave'          -    doesn't save electrodes
%      'path'            -    directory path
%      'FileName'        -    name of the trig file
%      'StimElectrode'   -    stimulation electriode(s)
%      'StimNumber'      -    number of stimulations
%      'ReadoutBranch1'  -    readout electrodes of 1st branch 
%      'ReadoutBranch2'  -    readout electrodes of 2nd branch
%      'ReadoutBranch3'  -    readout electrodes of 3rd branch
%      'ReadoutBranch4'  -    readout electrodes of 4th branch



SAVE = 1;

i=1;
while i<=length(varargin)
    if not(isempty(varargin{i}))
        if strcmp(varargin{i}, 'nosave')
            SAVE=0;
        elseif strcmp(varargin{i}, 'path')
            i=i+1;
            path=varargin{i};
        elseif strcmp(varargin{i}, 'StimNumber')
            i=i+1;
            StimNumber=varargin{i};
        elseif strcmp(varargin{i}, 'StimElectrode')
            i=i+1;
            StimElectrode=varargin{i};

        elseif strcmp(varargin{i}, 'ReadoutBranch1')
            i=i+1;
            ReadoutBranch{1}=varargin{i};
        elseif strcmp(varargin{i}, 'ReadoutBranch2')
            i=i+1;
            ReadoutBranch{2}=varargin{i};
        elseif strcmp(varargin{i}, 'ReadoutBranch3')
            i=i+1;
            ReadoutBranch{3}=varargin{i};
        elseif strcmp(varargin{i}, 'ReadoutBranch4')
            i=i+1;
            ReadoutBranch{4}=varargin{i};
            
        elseif strcmp(varargin{i}, 'FileName')
            i=i+1;
            FileName=varargin{i};
        else
            fprintf('unknown argument at pos %d\n', 1+i);
        end
    end
    i=i+1;
end



SelectedElcs        =   [];
scrsz               =   get(0,'ScreenSize');
pos{1}              =   [30 scrsz(4)/1 scrsz(4)/2 scrsz(3)/4];
pos{2}              =   [640 scrsz(4)/1 scrsz(4)/2 scrsz(3)/4];
pos{3}              =   [1250 scrsz(4)/1 scrsz(4)/2 scrsz(3)/4];
pos{4}              =   [30 scrsz(4)/25 scrsz(4)/2 scrsz(3)/4];
pos{5}              =   [640 scrsz(4)/25 scrsz(4)/2 scrsz(3)/4];
pos{6}              =   [1250 scrsz(4)/25 scrsz(4)/2 scrsz(3)/4];

for loop            =   1 : length(StimElectrode)
    
    Info.Exptype                    =   'Stim1Config';
    Info.Exptitle                   =   FileName;
    Info.Parameter.StimElectrode    =   StimElectrode(loop);
    Info.FileName.Map               =   [path 'configs/0_neuromap.m']; % [path sprintf('%03d.random_neuromap.m', loop-1)];
    Info.FileName.Trig              =   [path 'raw/' Info.Exptitle '.raw.trig'];
    Info.FileName.Raw               =   [path 'raw/' Info.Exptitle '.raw'];
    Info.FileName.TrigRawAve        =   [path 'raw/' Info.Exptitle '.averaged.traw'];
    Info.Parameter.NumberStim       =   StimNumber; % Number of stimulations
    Info.Parameter.ConfigNumber     =   length(StimElectrode);  % Number of configurations
    Info.Parameter.TriggerTimeZero  =   61; % look at the DAC;
    Info.Parameter.ConfigDuration   =   15; % [ms] length of triggered rec
    Info.Parameter.TriggerLength    =   300; % (15*20)
    Info.Map                        =   loadmapfile(Info.FileName.Map); % load Info.FileName.Map and plot elc locations in figure 1111
    Info.Trig                       =   loadtrigfile(Info.FileName.Trig);
    
    for branch      =   1 :length(ReadoutBranch);
        
        %   Axonal readout
        if strcmp(Info.Exptitle, FileName)
            targ.axon   =   ReadoutBranch{branch};
            targ.soma   =   StimElectrode(loop);
            targ.lim    =   ones(size(targ.axon))* 5.95;
            BLANK       =   0.35;
        end
        
        %   Extract triggered raw traces for electrodes of interest
        nstim           =   Info.Parameter.NumberStim;                                    % number of stim trials (get from extractTrigRawTrace)
        traces          =   zeros(length(targ.axon),Info.Parameter.TriggerLength);        % [elc x samp]
        traces_all      =   zeros(length(targ.axon),nstim,Info.Parameter.TriggerLength);  % [elc x nstim x samp]
        filled          =   zeros(1,length(targ.axon));                                   % set when trace for an electrode gets filled
        cnt             =   0;
        
        for elc         = targ.axon;
            cnt=cnt+1;
            disp(length(targ.axon)-cnt);
            if filled(cnt), continue, end
            [trc ep map]        = extractTrigRawTrace(Info,elc,'fulltrace','epoch', loop-1);
            disp(ep);
            for e=map.el'
                xx  = find(e==targ.axon);
                if ~isempty(xx)
                    chn                 = map.ch(find(map.el==e,1));
                    med                 = median(squeeze(trc(:,chn+1,:)));
                    traces(xx,:)        = med;
                    traces_all(xx,1:size(trc,1),:)  = squeeze(trc(:,chn+1,:));
                    filled(xx)          = 1;
                end
            end
        end
        
        %   Plot the trace
        figure('Position',pos{branch}, 'Name', sprintf([ 'Branch ' num2str(branch),'  electrode ' num2str(StimElectrode(loop))])), hold on;
        imagesc(traces);
        colorbar;
        colormap gray;
        caxis([-1 1]*33.33);
        title(Info.Exptitle);
        ylabel Electrode;
        xlabel Sample;
    end
    
    %   Select/Discard electrode
    reply = input('Do you want to save electrode? Y/N [Y]: ', 's');
    if reply == 'y';
        SelectedElcs(end+1) = StimElectrode(loop);
    end
    
    if SAVE
        SelectedElectrode = SelectedElcs;
        savefile = [path 'SelectedElectrodes/SelectedElectrode.mat'];
        save(savefile, 'SelectedElectrode')
    end
    close all;
end
out = SelectedElectrode;