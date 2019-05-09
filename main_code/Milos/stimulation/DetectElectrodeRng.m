function out = DetectElectrodeRng(varargin)
% Milos Radivojevic 2013
%
%      MakeConfig(varargin)
%
%      'nosave'          -    doesn't save electrodes
%      'path'            -    directory path
%      'FileName'        -    name of the trig file
%      'StimElectrode'   -    stimulation electriode(s)
%      'VoltageRange'    -    range of voltages used for each electrode (example: [100:20:400])
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
        elseif strcmp(varargin{i}, 'VoltageRange')
            i=i+1;
            voltage=varargin{i};
        elseif strcmp(varargin{i}, 'FileName')
            i=i+1;
            FileName=varargin{i};
        else
            fprintf('unknown argument at pos %d\n', 1+i);
        end
    end
    i=i+1;
end

scrsz               =   get(0,'ScreenSize');
pos{1}              =   [30 scrsz(4)/1 scrsz(4)/2 scrsz(3)/4];
pos{2}              =   [640 scrsz(4)/1 scrsz(4)/2 scrsz(3)/4];
pos{3}              =   [1250 scrsz(4)/1 scrsz(4)/2 scrsz(3)/4];
pos{4}              =   [30 scrsz(4)/25 scrsz(4)/2 scrsz(3)/4];
pos{5}              =   [640 scrsz(4)/25 scrsz(4)/2 scrsz(3)/4];
pos{6}              =   [1250 scrsz(4)/25 scrsz(4)/2 scrsz(3)/4];
all                 =   zeros(length(StimElectrode),length(voltage));

for loop            =   1 : length(StimElectrode)
    
    Info.Exptype                    =   'Stim1Config';
    Info.Exptitle                   =   FileName;
    Info.Parameter.StimElectrode    =   StimElectrode(loop);
    Info.FileName.Map               =   [path 'configs/0_neuromap.m'];      % [path sprintf('%03d.random_neuromap.m', loop-1)];
    Info.FileName.Trig              =   [path 'raw/' Info.Exptitle '.raw.trig'];
    Info.FileName.Raw               =   [path 'raw/' Info.Exptitle '.raw'];
    Info.FileName.TrigRawAve        =   [path 'raw/' Info.Exptitle '.averaged.traw'];
    Info.Parameter.NumberStim       =   StimNumber;                         % Number of stimulations
    Info.Parameter.ConfigNumber     =   length(StimElectrode);              % Number of configurations
    Info.Parameter.TriggerTimeZero  =   61;                                 % look at the DAC;
    Info.Parameter.ConfigDuration   =   15;                                 % [ms] length of triggered rec
    Info.Parameter.TriggerLength    =   300;                                % (15*20)
    Info.Map                        =   loadmapfile(Info.FileName.Map);     % load Info.FileName.Map and plot elc locations in figure 1111
    Info.Trig                       =   loadtrigfile(Info.FileName.Trig);
    
    trc=extractTrigRawTrace(Info, NaN, 'fulltrace', 'epoch',loop-1, 'digi');
    
    if loop==1
        figure, hold on;
        plot(squeeze(trc(:,127,:))');
        waitforbuttonpress;
    end
    close all;
    
    A=squeeze(trc(:,127,:))';
    voltrng = sort(unique(max(A)));
    
    for rng =  1: length(voltrng)
        
        for branch      =   1 :length(ReadoutBranch);
            
            %   Axonal readout
            if strcmp(Info.Exptitle, FileName)
                targ.axon   =   ReadoutBranch{branch};
                targ.soma   =   StimElectrode(loop);
                targ.lim    =   ones(size(targ.axon))* 5.95;
                BLANK       =   0.35;
            end
            
            %         for rng =  1: length(voltrng)
            
            %   Extract triggered raw traces for electrodes of interest
            trc=extractTrigRawTrace(Info, NaN, 'fulltrace', 'epoch',loop-1, 'digi');
            
            nstim       = Info.Parameter.NumberStim;                                    % number of stim trials (get from extractTrigRawTrace)
            traces      = zeros(length(targ.axon),Info.Parameter.TriggerLength);        % [elc x samp]
            traces_all  = zeros(length(targ.axon),nstim,Info.Parameter.TriggerLength);  % [elc x nstim x samp]
            filled      = zeros(1,length(targ.axon));                                   % set when trace for an electrode gets filled
            cnt = 0;
            
            A=squeeze(trc(:,127,:))';
            B=max(A);
            %             Vtrials = find(B==voltrng(rng));
            Vtrials = find(trc(:,127,59)==voltrng(rng));
            
            for elc         = targ.axon;
                cnt=cnt+1;
                disp(length(targ.axon)-cnt);
                if filled(cnt), continue, end
                [trc ep map]        = extractTrigRawTrace(Info,elc,'fulltrace','epoch', loop-1, 'bandpass');
                disp(ep);
                for e=map.el'
                    xx  = find(e==targ.axon);
                    if ~isempty(xx)
                        chn                 = map.ch(find(map.el==e,1));
                        med                 = median(squeeze(trc(Vtrials,chn+1,:)));
                        traces(xx,:)        = med;
                        traces_all(xx,1:size(trc(Vtrials),1),:)  = squeeze(trc(Vtrials,chn+1,:));
                        filled(xx)          = 1;
                    end
                end
            end
            
            %   Plot the trace
            figure('Position',pos{branch}, 'Name', sprintf([ 'Branch ' num2str(branch),'  electrode ' num2str(StimElectrode(loop)), '  voltage ' num2str(voltage(rng)) ])), hold on;
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
            all(loop,rng) = StimElectrode(loop);
        end
        %         v = genvarname(sprintf(['ElsVolt' num2str(voltage(rng)) ]));
        %         eval([v ' = nonzeros(all(:,a))']);
        
        if SAVE
            SelectedElectrodes = all;
            savefile = [path 'SelectedElectrodes/SelectedElectrodes.mat'];
            save(savefile, 'SelectedElectrodes')
        end
        close all;
    end
end

figure('Name', 'config');
paper_w = 1070;
paper_h = 1090;
set(gcf,'Position',[1700 150 paper_w paper_h])
set(gcf,'PaperPosition',[0 0 [paper_w paper_h]/70/3])
set(gcf,'PaperSize',[paper_w paper_h]/85/3)
axes('Position',[.08  .053  .833 .907]);
[mposx mposy]=el2position([0:11015]);
box on,    hold on;
axis ij,   axis equal
plot(mposx,mposy,'.','color',[1 1 1]*.93);

colours = colormap(hot(length(voltage)+1));
hold on;

for ii=1:length(StimElectrode)
    plot(mposx(StimElectrode(ii)+1),mposy(StimElectrode(ii)+1),'sk','LineWidth',1, 'MarkerEdgeColor', [1 1 1]*.9, 'MarkerFaceColor', [1 1 1]*.97, 'MarkerSize',20);
end

for a = 1 : length(voltage)
    v = nonzeros(SelectedElectrodes(:,length(voltage)-(a-1))');
    colormap(jet);
    for i=1:length(v)
        plot(mposx(v(i)+1),mposy(v(i)+1),'sk','LineWidth',1, 'MarkerEdgeColor', [1 1 1]*.9, 'MarkerFaceColor', colours(a,:), 'MarkerSize',10);
    end
end

out = SelectedElectrodes;