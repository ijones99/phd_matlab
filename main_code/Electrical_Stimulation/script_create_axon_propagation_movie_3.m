% - - - - - - - - - - - %
%% analysis_StimScan.m %%
%      Douglas Bakkum, modified by Milos
%      2008-2012
%
%   EXPERIMENT INFO IS AT THE BOTTOM OF THE PAGE
%   (so can more quickly navigate scripts)
%
%%% %% %% %% %% %% %% %% %% %% %% %% %%  %%   %%     %%    %%   %%  %  % %
%%  Settings
clear all; Info.Exptype='Neur07';
Info.Exptitle='neur07';
dirAllExp = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska';
dirExp = sprintf('%s/20Jun2013',dirAllExp);

Info.Parameter.StimElectrode=5791;

Info.FileName.Spike            = [sprintf('%s/proc/',dirExp) Info.Exptitle '.spike'];
Info.FileName.SpikeForm        = [sprintf('%s/proc/',dirExp) Info.Exptitle '.spikeform'];
Info.FileName.Map              = [sprintf('%s/Configs/%s_neuromap.m',dirExp,Info.Exptitle)  ];
Info.FileName.Trig             = [sprintf('%s/proc/',dirExp) Info.Exptitle '.raw.trig'];
Info.FileName.Raw              = [sprintf('%s/proc/',dirExp) Info.Exptitle '.raw'];
Info.FileName.TrigRawAve       = [sprintf('%s/proc/',dirExp) Info.Exptitle '.averaged.traw'];
% dirNameCmosPostProcess = '/home/ijones/Binaries/';
dirNameCmosPostProcess = '/usr/local/hierlemann/meabench/head/bin/';
Info.Parameter.NumberStim=1200; % tells cpp code to look at epochs for averaging
Info.Parameter.ConfigNumber=1; % random
Info.Parameter.TriggerTimeZero=61;% ?? [samples] stimulation center (time zero)
Info.Parameter.ConfigDuration=15; % [ms] length of triggered rec ORIG: 23
Info.Parameter.TriggerLength=20*Info.Parameter.ConfigDuration; % [samples] length of triggered (msec * 20 samples/msec)


% %  use cpp file to average raw traces
%  High res DAC encoding (after March 2010)

Info_Parameter_NumberStim = Info.Parameter.NumberStim; % tells code to look at DAC channel to determine epoch changes ...
% (as opposed to counting num of stim)

cmd=[dirNameCmosPostProcess 'cmos_postprocessing -a -o ' ...
    Info.FileName.TrigRawAve ' -r ' Info.FileName.Raw ' -s ' int2str(Info.Parameter.TriggerLength) ...
    ' -z ' int2str(Info.Parameter.TriggerTimeZero) ' -m ' Info.FileName.Map ' -c ' ...
    int2str(Info.Parameter.ConfigNumber) ' -n ' int2str(Info_Parameter_NumberStim)]
system(cmd);

% load Info.Map info   and   mtraw data
%STep02
% %  if not created during the experiment, create Info.FileName.Map using Stim Expt tab in CmdGui
%  cmd=['el2fi_to_neuromap -i ' Info.Exptitle '.el2fi.nrk2 -o ' Info.FileName.Map]
%  system(cmd)
%%
load global_cmos
Info.Map = loadmapfile(Info.FileName.Map,1111); % load Info.FileName.Map and plot elc locations in figure 1111

% position = [0 680 560 420];
position = [1685 450 560 420];
set(0,'DefaultFigurePosition',position);
%%%%% mtraw in digi units ???     normal settings give 0.762uV/digi in Meabench

clear mtraw
mtraw=load(Info.FileName.TrigRawAve,'-ascii');  % !!!! no gain applied !!! USE:   11.7/16 * 1000/958.558; % 11.7mV/8-bit (3V range); meabench uses 12-bit (mcs convention) -- 16=2^12 / 2^8; 1000 to put into uV; 958 is standard CMOS gain (A1-30, A2-30 A3-bypass)
% [samples; 12 bit (meabench default)]
mtraw = mtraw(:,1:Info.Parameter.TriggerLength) * GAIN;          % CONVERT to uV
[stim_x stim_y] = el2position(Info.Parameter.StimElectrode);

% remove artifact electrodes
elc_to_skip = []; % elc_to_skip = [8471 8477]
if ~isempty(elc_to_skip)
    mtraw(elc_to_skip+1,:) = 0;
    disp 'Removed artifact electrodes'
end

% cmos_postprocessing file removes non connected electrodes (sets values to zero), so can extract these here:
zz=find(sum(abs(mtraw(:,50:end))')==0);
ok=find(sum(abs(mtraw(:,50:end))')~=0);

figure
plot(([1:Info.Parameter.TriggerLength]-Info.Parameter.TriggerTimeZero)*.05,mtraw')
title(Info.Exptitle)

%
clear target
target = mtraw;

spacingx=(max(ELC.X)-min(ELC.X(ELC.X>0)))/length(unique(ELC.X(ELC.X>0)))/4;
spacingy=(max(ELC.Y)-min(ELC.Y(ELC.Y>0)))/length(unique(ELC.Y(ELC.Y>0)))/2;
sx=min(ELC.X(ELC.X>0)):spacingx:max(ELC.X);
sy=min(ELC.Y(ELC.Y>0)):spacingy:max(ELC.Y);
[sx,sy]=meshgrid(sx,sy);

figure(22), close, figure(22)
paper_w = 670;
paper_h = 690;
set(gcf,'Position',[1700 150 paper_w paper_h])
set(gcf,'PaperPosition',[0 0 [paper_w paper_h]/70/3])
% set(gcf,'PaperSize',[paper_w paper_h]/70/3)
set(gcf,'PaperSize',[paper_w paper_h]/70/3)
axes('Position',[.1  .15  .8 .8]);
%colorbar
fontsize = 4;


% electrode sizes.  default v2 is type "M Pt3um default" 8.2x5.8um
elc_dimx = 16.2-1; % um
elc_dimy = 19.588; % um  % from unique(diff(ELC.Y))
rng  =   25; % [um]     range around non-connected electrodes used to average value for that electrode


%   save movie frames
% figure(22)
zAll = [];
cnt=0;
i = Info.Parameter.TriggerTimeZero-1 + 10;
%%%   movie
PLOTINWINDOW = 0;
SAVE    =    0 ; % print figures to file
FILL    =    0 ; % plot using 'fill' (HIGH QUALITY; longer to run)
PLOTMIN =    0 ; % write text at valleys
FILLALL =    0 ; % fill non-connected electrodes with average of connected neighbors
GAUS    =    0 ; % blur with a gaussian

ll      =   -50; %-45; % [uV]    -40;%-50 ; % cutoff   -50 [samples]  --- lower color bar limit
ul      =    50; % [uV]     12;% 15 ; % cutoff    15 [samples]   ---- upper color bar limit

clr1    =  mkpj(ul-ll+1,'J_DB');              % modified by me to add more red (perceptually balanced colormaps)
%clr1    =  mkpj(ul-ll+1,'JetI');             % perceptually balanced colormaps
%  colormap(flipud( lbmap(128,'RedBlue') ))   % colormaps for the colorblind

numFrames = size(mtraw,2)-1;
while i<=size(mtraw,2)-1
    
    cla
    i=i+1;
    disp(i)
    
    hold off
    %tar=min(target(ok,Info.Parameter.TriggerTimeZero+30:end)');
    %tar=target(ok,i);
    tar=target(:,i);
    tar(tar<ll)=ll;
    tar(tar>ul)=ul;
    
    % fill non-connected elc with average of connected neighbors
    if FILLALL
        for j=zz
            [x y]    = el2position(j-1); %0
            if x==-1, continue; end % dummy electrode
            xx       = find( (ELC.X(ok)-x).^2+(ELC.Y(ok)-y).^2 < rng^2 ); % get neighbor electrodes
            tar(j,:) = mean( tar(ok(xx),:) );
        end
    end
    
    % Smooth with a gaussian-like function
    if GAUS
        gaus_rng = 25; % [um] - corresponds to 1st neighboring ring of electrodes
        for j=0:11015
            [x y]    = el2position(j);
            if x==-1, continue; end % dummy electrode
            d_sq     = (ELC.X-x).^2+(ELC.Y-y).^2;
            xx       = find( d_sq < gaus_rng^2  &  d_sq > 0); % get neighbor electrodes
            tar(j+1,:) = ( mean( tar(xx,:) ) + tar(j+1,:) )/2;
        end
    end
    
    
    % Plot
    if FILL
        % FILL in electrodes
        %  figure
        for j=0:11015%ok-1,
            [x y]=el2position(j);
            if x==-1; continue, end % dummy electrode
            cc = clr1(round(tar(j+1))-ll+1,:);
            %cc = round(tar(j+1))-ll+1;
            h=fill([ -elc_dimx -elc_dimx  elc_dimx  elc_dimx ]/2+x, [ -elc_dimy elc_dimy elc_dimy -elc_dimy]/2+y, cc, 'edgecolor', 'none' , 'linewidth', 1);
            %set(h,'facealpha',.5)
            hold on
        end
        
    else
        % IMAGESC to plot quickly
        %z=griddata(ELC.X(ok),ELC.Y(ok),target(ok,i),sx,sy,'cubic');
        id=find(ELC.X>0); % ignor dummy electrodes
        z=griddata(ELC.X(id),ELC.Y(id),tar(id),sx,sy,'cubic');
        
        if PLOTINWINDOW
            imagesc(sx(1,:),sy(:,1),z);   axis([sx(1,[1 end]) sy([1 end],1)'])
        end
        
    end
    
    if 0  % % for overlay on image % % %
        im_m=max(max(im));
        imagesc(im-im_m+ll-1)
        axis equal
        axis ij
        %alpha(.55)
        
        clr0=gray(im_m);
        clr=[clr0; clr1];
        colormap(clr)
        caxis([-im_m+ll ul])
    else
        if PLOTINWINDOW
            colormap(clr1)
            caxis([ll ul])
        end
    end
    
    hold on
    plot(stim_x,stim_y,'w+','markersize',10,'linewidth',3)
    hold off
    if PLOTINWINDOW
        set(gca,'Color',[1 1 1]*.6)
        title([Info.Exptitle ' ' num2str((i-Info.Parameter.TriggerTimeZero)/20,'%3.2f') ' msec.  Sample: ' num2str(i,'%3.0f')])
        
        cb = colorbar('location','southoutside');
        set(get(cb,'xlabel'),'String', 'Voltage [uV]','FontSize',fontsize,'FontWeight','bold');
        cpos=[.125 .085 .75 .02];
        set(cb,'Position',cpos);
        
        box on
        axis equal ij
        axis([100 2000 50 2150])
        set(gca,'xTickLabel',{})
        %xlabel 'Position [um]'
        ylabel 'Position [um]'
    end
    if SAVE
        figure_fontsize(fontsize,'bold')
        %text(1610,2110,'Douglas James Bakkum ','fontweight','bold','fontsize',3)
        
        desc = '';
        if FILL,     desc = [desc '-scatter']; end
        if FILLALL,  desc = [desc '-fillall']; end
        if GAUS,     desc = [desc '-gaus'];    end
        
        filename=sprintf('/home/ijones/ln_roska_data/04Jun2013/analysed_data/movie/pics/%s%s_%03d',...
            Info.Exptitle,desc,cnt);
        cnt=cnt+1;
        set(gcf,'inverthardcopy','off')
        set(gcf,'color','w')
        print('-dpng','-r600',[filename '.png'])
    end
    if PLOTINWINDOW
        drawnow
    end
    %pause%(.005)
    if PLOTMIN, pause; end
    zAll(:,:,end+1) = z;
    fprintf('%3.1f percent done\n', 100*i/numFrames)
    
end
meanAllFrames = mean(zAll,3);
%% plot normal movie

figure, axis equal
for i=1:size(zAll,3)-1
    imagesc(zAll(:,:,i))
    pause(0.1)
end


%% calculate differential movie
zDiff = [];
hsize = [2 2];
sigma = 4;

% h = fspecial('disk',sigma)
h = fspecial('gaussian',9,1.5);
zDiff = [];

for i=1:71
    zDiff(:,:,end+1) = zAll(:,:,i+1) - zAll(:,:,i);
end
% zDiffFilt = imfilter(zDiff,h,'same');
zDiffFilt = medfilt2(zDiff,[3 3]);
%%
figure, axis equal
for i=1:71%size(zAll,3)-1
    % take difference
    currFrame = medfilt2(zDiff(:,:,i),[5 5]);
    
    currFrame = (currFrame) ;
    
    imagesc(currFrame);
    colormap(jet)
    drawnow
    %     pause(0.1);
    
    zDiff(:,:,end+1) = currFrame;
    hFr = getframe(gcf);
    i   
    imwrite(hFr.cdata,sprintf('neur05propagation%4.0f', i),'jpeg')
    
end

%%
maxZDiff = sum((zDiff),3);


h = fspecial('unsharp');
% maxZDiff = imfilter(maxZDiff, h, 'replicate');
figure
imagesc(maxZDiff )
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                      TRAJECTORIES OF AXONS                      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     START     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



