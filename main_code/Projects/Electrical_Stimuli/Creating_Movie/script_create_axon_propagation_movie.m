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
clear all; Info.Exptype='StimScan';
Info.Exptitle='try18';
dirAllExp = '/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska';
dirExp = sprintf('%s/Testing_Axon_Prop_Movie',dirAllExp);

Info.Parameter.StimElectrode=8267;
Info.FileName.Spike            = [sprintf('%s/proc/',dirExp) Info.Exptitle '.spike'];
Info.FileName.SpikeForm        = [sprintf('%s/proc/',dirExp) Info.Exptitle '.spikeform'];
Info.FileName.Map              = [sprintf('%s/Configs/%s_neuromap.m',dirExp,Info.Exptitle)  ];
Info.FileName.Trig             = [sprintf('%s/proc/',dirExp) Info.Exptitle '.raw.trig'];
Info.FileName.Raw              = [sprintf('%s/proc/',dirExp) Info.Exptitle '.raw'];
Info.FileName.TrigRawAve       = [sprintf('%s/proc/',dirExp) Info.Exptitle '.averaged.traw'];

Info.Parameter.NumberStim=60; % tells cpp code to look at epochs for averaging
Info.Parameter.ConfigNumber=95; % random
Info.Parameter.TriggerTimeZero=61;% ?? [samples] stimulation center (time zero)
Info.Parameter.ConfigDuration=15; % [ms] length of triggered rec ORIG: 23
Info.Parameter.TriggerLength=20*Info.Parameter.ConfigDuration; % [samples] length of triggered (msec * 20 samples/msec)


%% %  use cpp file to average raw traces
%  High res DAC encoding (after March 2010)

Info_Parameter_NumberStim = Info.Parameter.NumberStim; % tells code to look at DAC channel to determine epoch changes ...
% (as opposed to counting num of stim)
cmd=['/usr/local/hierlemann/meabench/head/bin/cmos_postprocessing -a -o ' ...
    Info.FileName.TrigRawAve ' -r ' Info.FileName.Raw ' -s ' int2str(Info.Parameter.TriggerLength) ...
    ' -z ' int2str(Info.Parameter.TriggerTimeZero) ' -m ' Info.FileName.Map ' -c ' ...
    int2str(Info.Parameter.ConfigNumber) ' -n ' int2str(Info_Parameter_NumberStim)]
system(cmd);

%% load Info.Map info   and   mtraw data
%STep02
% %  if not created during the experiment, create Info.FileName.Map using Stim Expt tab in CmdGui
%  cmd=['el2fi_to_neuromap -i ' Info.Exptitle '.el2fi.nrk2 -o ' Info.FileName.Map]
%  system(cmd)

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

%%
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


%%   save movie frames
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
    fprintf('%3.0f\n', 100*i/numFrames)
    
end
meanAllFrames = mean(zAll,3);

%% calculate differential movie
zDiff = [];
hsize = [10 10];
sigma = 5;

figure, axis square

h = fspecial('disk',sigma)
zDiff = [];
for i=1:size(zAll,3)-1
   % take difference
   zDiff(:,:,end+1) = zAll(:,:,i) - zAll(:,:,i+1);
   % get median value
   zDiffRow = remove_dims(zDiff(:,:,end));
   medianZDiff= nanmedian(zDiffRow);
   % calibrate each image
   zDiff(:,:,end) = abs(zDiff(:,:,end) - medianZDiff);

   % filter frame
   zDiff(:,:,end) = imfilter(zDiff(:,:,end),h,'replicate');
   imagesc(zDiff(:,:,end));
   pause(0.1);

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

%%
clear target
% %%
% target = tgaus;
% target = ftraw;
target = mtraw;

spacingx=(max(ELC.X)-min(ELC.X(ELC.X>0)))/length(unique(ELC.X(ELC.X>0)))/4;
spacingy=(max(ELC.Y)-min(ELC.Y(ELC.Y>0)))/length(unique(ELC.Y(ELC.Y>0)))/2;
sx=min(ELC.X(ELC.X>0)):spacingx:max(ELC.X);
sy=min(ELC.Y(ELC.Y>0)):spacingy:max(ELC.Y);
[sx,sy]=meshgrid(sx,sy);



figure(22), close, figure(12)
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

%%
cnt=0;
i = Info.Parameter.TriggerTimeZero-1 + 10;
%%%   movie
SAVE    =    0 ; % print figures to file
FILL    =    1 ; % plot using 'fill' (HIGH QUALITY; longer to run)
PLOTMIN =    0 ; % write text at valleys
FILLALL =    0 ; % fill non-connected electrodes with average of connected neighbors
GAUS    =    0 ; % blur with a gaussian

ll      =   -35; %-45; % [uV]    -40;%-50 ; % cutoff   -50 [samples]  --- lower color bar limit
ul      =    10; % [uV]     12;% 15 ; % cutoff    15 [samples]   ---- upper color bar limit

clr1    =  mkpj(ul-ll+1,'J_DB');              % modified by me to add more red (perceptually balanced colormaps)
%clr1    =  mkpj(ul-ll+1,'JetI');             % perceptually balanced colormaps
%  colormap(flipud( lbmap(128,'RedBlue') ))   % colormaps for the colorblind


%%

i= 110 %  Numer of frames to compile

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
        xx       = find( (ELC.X(ok)-x).^2+(ELC.Y(ok)-y).^2 < rng^2 ); % get neighbor electrodes%%  Date: 14 Oct 2012    Chip 964     Stim elc:10036   Stim voltage: 140mv  MOSR: R1=100 R2=100
        
        clear all; Info.Exptype='StimScan';
        Info.Exptitle='el1658';
        Info.Parameter.StimElectrode=1658;
        Info.FileName.Spike            = ['/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/1164/data/24.January2013/stim_scan1658/170mv/spikes/' Info.Exptitle '.spike'];
        Info.FileName.SpikeForm        = ['/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/1164/data/24.January2013/stim_scan1658/170mv/spikes/spikeform/' Info.Exptitle '.spikeform'];
        Info.FileName.Map              = ['/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/1164/data/24.January2013/stim_scan1658/170mv/configs/random_neuromap.m'];
        Info.FileName.Trig             = ['/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/1164/data/24.January2013/stim_scan1658/170mv/raw/' Info.Exptitle '.raw.trig'];
        Info.FileName.Raw              = ['/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/1164/data/24.January2013/stim_scan1658/170mv/raw/' Info.Exptitle '.raw'];
        Info.FileName.TrigRawAve       = ['/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/1164/data/24.January2013/stim_scan1658/170mv/raw/' Info.Exptitle '.averaged.traw'];
        Info.Parameter.NumberStim=0; % tells cpp code to look at epochs for averaging
        Info.Parameter.ConfigNumber=95; % random
        Info.Parameter.TriggerTimeZero=61;% [samples] stimulation center (time zero)
        Info.Parameter.ConfigDuration=15; % [ms] length of triggered rec
        Info.Parameter.TriggerLength=300; % [samples] length of triggered re
        
        
        
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

id=find(ELC.X>0); % ignor dummy electrodes
z=griddata(ELC.X(id),ELC.Y(id),tar(id),sx,sy,'cubic');
imagesc(sx(1,:),sy(:,1),z);   axis([sx(1,[1 end]) sy([1 end],1)'])


hold on
plot(stim_x,stim_y,'w+','markersize',10,'linewidth',3)
hold off
set(gca,'Color',[1 1 1]*.6)
% title(['Time since stimulation: ' num2str((i-Info.Parameter.TriggerTimeZero)/20,'%3.2f') ' msec.  Sample: ' num2str(i,'%3.0f')])
title([Info.Exptitle ' ' num2str((i-Info.Parameter.TriggerTimeZero)/20,'%3.2f') ' msec.  Sample: ' num2str(i,'%3.0f')])

z=griddata(ELC.X(ok),ELC.Y(ok),min( target(ok,max([34 i-40]):i)'),sx,sy,'cubic');
% z=griddata(ELC.X(ok),ELC.Y(ok),min( target(ok,max([75 i-80]):i)'),sx,sy,'cubic');

imagesc(sx(1,:),sy(:,1),z);   axis([sx(1,[1 end]) sy([1 end],1)'])
%%
if 0  % % for overlay on image % % %
    im_m=max(max(im));
    imagesc(im-im_m+ll-1)
    axis equal
    axis ij
    %alpha(.55)
    
    clr0=gray(im_m);
    clr=[clr0; clr1];
    colormap(clr)/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/964/data/17Oct2012/stim_scan10036/150mv/movie
    caxis([-im_m+ll ul])
else
    colormap(clr1)
    caxis([ll ul])
end

%% Set the colorbar in order to increase the "resolution" ([-80 0])

colorbar
colormap(clr1)
caxis([ll ul])
caxis([-30 0])
%%


elc =        [8325        7609        6996        6180        5669        5258     5049        4944        4836        4833        4831        4932        4829        4827        4724 5772        5463        4841         4109        3904        3802        3701        3601        3602        3398        3399        3400        3402        3301        3302        3201        2999        2692        2587 2585        2481        2379        2380  2481        2380        2278        2176        2075       1769        1667        1565        1463        1464        1363        1364        1263        1265        1266        1267 1269        1168        1169        1170        1171        1172        1173        1175        1177 1269        1168        1169        1170        1172        1173        1175        1177        1178        1180        1181        1183        1081        1082        1083        1084 984         985         990 987         988         990        1094         993         995         893         894 387   388   390   391   290   189   292 387         388         389         390         391         290         191         396         500         705         807         910        1012        1216];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                      TRAJECTORIES OF AXONS                      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      END      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       MAKE CONFIGS FROM THE 'CLICKELECTRODE' SET START          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                  elc=clickelectrode                             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                  elc_with_neuron=elc                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% make neuropos file
% % if too many, randomly choose
%   neurons=elc_with_neuron;
%   rp=randperm(length(neurons));
%   elc_with_neuron=neurons(rp(1:150));
%neuroposfile=['/opt/cmosmea_external/configs/bakkum/' Info.Exptitle '.neuropos.nrk']

% % if too many, choose largest spikes
%   [a b]= sort(height(elc_with_neuron+1));
%   elc_with_neuron = elc_with_neuron(b(1:130));

neuroposfile=['/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/964/data/17Oct2012/axonal_integration/config/axon_config/' Info.Exptitle '.neuropos.nrk']
fid = fopen(neuroposfile, 'wt');
for i=1:length(elc_with_neuron)
    e=elc_with_neuron(i);
    [x y]=el2position(e);
    x = round(x);
    y = round(y);
    fprintf(fid, 'Neuron matlab%i: %i/%i, 10/10\n',i,x,y);
end
fclose(fid);

%% execute NeuroDishRouter

%ndr_exe='`which NeuroDishRouter`';
ndr_exe='`which NeuroDishRouter_new`';

[pathstr, name, ext] = fileparts(neuroposfile);
[tmp, name]          = fileparts(name);
fnames{1}            = [pathstr '/' name];
neurs_to_take{1}     = elc_with_neuron;

cmd=sprintf('%s -n -v 2 -l %s -s %s\n', ndr_exe, neuroposfile, [pathstr '/' name])
system(cmd);

%% reload & visualize configuration

for fn=1:length(fnames)
    fname=[fnames{fn} '.el2fi.nrk2'];
    fid=fopen(fname);
    elidx=[];
    tline = fgetl(fid);
    while ischar(tline)
        [tokens] = regexp(tline, 'el\((\d+)\)', 'tokens');
        elidx(end+1)=str2double(tokens{1});
        tline = fgetl(fid);
    end
    fclose(fid);
    
    [mposx mposy]=el2position([0:11015]);
    %els=hidens_get_all_electrodes(2);
    
    figure; % plot selected vs routed
    box on,    hold on;
    axis ij,   axis equal
    
    plot(mposx,mposy,'.','color',[1 1 1]*.8)
    plot(mposx(neurs_to_take{fn}+1),mposy(neurs_to_take{fn}+1),'sk')
    plot(mposx(elidx+1), mposy(elidx+1), 'rx');
    
end
%% Plotelectrodenumbers

%function electrodes = plotelectrodenumbers(fig)
% Douglas Bakkum 2010.03
% electrodes = PLOTELECTRODENUMBERS( FIGURE_NO )
% Writes electrode numbers on visible area of a figure.
% Returns the list of electrodes plotted.
%if nargin<1
%  fig=gcf;
%end
%figure(fig);


a=axis;
%e=[0:11015];
%e = [8735        8324        8223        8123        7716        7713        7512        7514        7106        6903    9961      6397        6093        6503 6911        7422        7626        5886        5682        5884        5780        5577        6895        6180        5975        5772        5668        5463    5049        4845        4849        4751        4647        4843        4945        5146        5450        5448        5446        5039        4836        4934    4932        4827        5133        5234        5743        5846        6153        6357        6562        4765        4460        3843        3534        3225    3019        2707        2399        2193        1986        1471        1675        1569        1669        1771        1973        2279        1366        1262    954         645        3904        3909        2692        1576        1363        1267        1170        1175        1284        1189        1089        1194     1096         792         388         391         189         191         396         602         809         804         598         593         898        1100    1304        1711        1812        1910        2010        2112        1806        1701        1798        1795        1898        2103        2308           2610        2916        3017        3221        2917        1692        1481      1375  1689]
elc=e
[x y]=el2position(e);

id=find( (x>a(1) & x<a(2) & y>a(3) & y<a(4)) );

clear txt
for i=1:length(id)
    txt{i}=int2str(e(id(i)));
end


hold on
plot(x(id),y(id),'s','color',[1 1 1]*.4)
text(x(id)+4,y(id),[txt],'fontsize',6,'color',[1 1 1]*.3)
hold off

electrodes = e(id);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       MAKE CONFIGS FROM THE 'CLICKELECTRODE' SET  END         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
clear target;


%% make movie

%  After creating image files, use ffmpeg
%
%  http://ubuntuforums.org/showthread.php?t=786095
%  "HOWTO: Install and use the latest FFmpeg and x264"
%
% %ffmpeg -i filename_%03d.jpg -vcodec libx264 -b 512k -bt 512k -r 25 -s vga -threads 0 -f mp4 filename.mp4
% cmd=['ffmpeg -y -i ' filename '_%03d.jpg -pass 1 -vcodec libx264 -vpre fastfirstpass -s vga -b 512k -bt 512k -threads 0 -f mp4 -an /dev/null && ffmpeg -i ' filename '_%03d.jpg -pass 2 -vcodec libx264 -vpre hq -b 512k -bt 512k -threads 0 -f mp4 ' filename '.mp4']

filename_i = ['/home/ijones/ln_roska_data/04Jun2013/analysed_data/movie/pics/' Info.Exptitle desc '_']
filename_o = ['/home/ijones/ln_roska_data/04Jun2013/analysed_data/movie/' Info.Exptitle desc '_']
%    filename_i = ['/local0/bakkumd/movies/pics/' Info.Exptitle '_v2_scat']
%    filename_o = ['/local0/bakkumd/movies/' Info.Exptitle '_v2_scat']
%   filename_o = ['/local0/bakkumd/movies/' Info.Exptitle '-median']
%  cmd=['ffmpeg -i ' filename_i '_%03d.jpg -vcodec libtheora -s vga -b 4096k -threads 0 -vframes ' num2str(cnt) ' -f ogg ' filename_o '.ogg']
%cmd=['ffmpeg -i ' filename_i '_%03d.jpg -vcodec libx264 -s vga -b 4096k -threads 0 -vframes ' num2str(cnt) ' -f mp4 ' filename_o '.mp4']
%cmd=['ffmpeg -r 10 -i ' filename_i '_%03d.jpg -vcodec libx264 -b 4096k -threads 0 -vframes ' num2str(cnt) ' -f mp4 ' filename_o '.mp4']

%  Jan's method to make movies:
%  mencoder "mf://*.png"                    -mf fps=10 -o   test.avi         -ovc lavc -lavcopts vcodec=msmpeg4v2:vbitrate=800
%  mencoder "mf://pics/110519-C_*.jpg"      -mf fps=10 -o   test.avi         -ovc lavc -lavcopts vcodec=msmpeg4v2:vbitrate=800
%cmd=['mencoder "mf://' filename_i '*.jpg" -mf fps=20 -o ' filename_o '.avi -ovc lavc -lavcopts vcodec=msmpeg4v2:vbitrate=800']
cmd=['/usr/local/hierlemann/mplayer/bin/mencoder "mf://' filename_i '*.png" -mf fps=20 -o ' filename_o ...
    '.avi -ovc lavc -lavcopts vcodec=msmpeg4v2:vbitrate=800']

system(cmd)

%   PLAY using     system('mplayer filename')


%%
%   ffmpeg -i ClumpSlowFast.mov -vcodec mpeg1video -s vga -b 4096k -r 2 ClumpSlow.mpg
%   ffmpeg -i ClumpSlowFast.moccv -r 2 -f image2 Clump-pics/images%05d.png
%   ffmpeg -i Clump-pics/images%05d.png -vcodec mpeg1video -s vga -b 4096k -vframes 28 ClumpFast.mpg
%   cat ClumpSlow.mpg ClumpFast.mpg > ClumpSlowFast.mpg
%   ffmpeg -i ClumpSlowFast.mov -vcodec libx264 -s vga -b 4096k -threads 0 -f mp4 ClumpSlowFast.mp4
%   ffmpeg -i ClumpSlowFast.mpg -vcodec libx264 -s vga -b 4096k -threads 0 -f mp4 ClumpSlow.mp4
%
% ffmpeg -i ClumpSlowFast.mov -vcodec libx264 -s vga -b 4096k -threads 0 -f mp4 ClumpSlowFast.mp4

% resize
%    cmd=' find . -name "110516-C_*.jpg" | xargs -i convert -scale 50% {} ./resized/{} '

%% put into format to send to others for analysis

clear data
data.traces = mtraw;
data.x      = zeros(size(ELC.X));
data.y      = zeros(size(ELC.X));
data.x(ok)  = ELC.X(ok);            % use only connected electrodes
data.y(ok)  = ELC.Y(ok);

if 0,
    save([Info.Exptitle '-' Info.Exptype '-DataForCSD.mat'],'data')
end

%% create neuropos file for electrodes over an axon



z=griddata(ELC.X(ok),ELC.Y(ok),min( target(ok,Info.Parameter.TriggerTimeZero+15:end)' ),sx,sy);
imagesc(sx(1,:),sy(:,1),z);   axis([sx(1,[1 end]) sy([1 end],1)'])




% 091120-B
elc_with_neuron=[5441 5544 5545 5546 5753 5650 5754 5858 5859 6170 6168 6477 6783 6684 6993 7198 7401 6992 6995 7097 7714 7405 7710 8223 8221 8220 8421 8422 8323 8619 8515 8514];

%091123-A,B,D,E (from D) axon 1 (horizontal)
elc_with_neuron=[7039 7142 7144 7247 7657     8079 7774 8081 7879 7778 7881 7885 7867 8094 7888 8097 8510 8511 8516 8518 5420 8422 8426 8529 8636 8637 8742  8639 8849 8750 8649 8651 8653 8770 8567];
start_s=65; start_t=(start_s-Info.Parameter.TriggerTimeZero)*.05;

%091206-D
elc_with_neuron=[8027 7823 7822 7209 6902 6595 6391 6084 5880 5777 5677 5268 5267 5062 4960 4756 4451 4348 4349 3942 3941 3634 3632 3117 3119     2806 2703 2498 2188 2290 2091 ];
start_s=35; start_t=(start_s-Info.Parameter.TriggerTimeZero)*.05;
stimsites=[Info.Parameter.StimElectrode 4396 8562 8178 ];

%091227-Dtest (named 091227-C)
elc_with_neuron=[2057];
stimsites=[Info.Parameter.StimElectrode  9135 6991 ];

%091227-D
elc_with_neuron=[4950 4951 4851 4541 4134 3929 3522 3317 3114 3115 3012 3011 2601 2298 1990 1888 1682 1884 1469 1468 1568 1567 1666 1764 1763 1762 1962 1960 1857 2161 2057     1755 1453 1353 1456 1457 1356 1358 1359 1565 1667 1973 1872 1977 2181 2182 2387 2593 2798 2900 3005 3003 3007];
stimsites=[3007 6991 2057];

%100109-B,C
elc_with_neuron=[2057 2056 2666 3012 5779];
stimsites=[9637 3545 4585 3583 10819];

%101012-A3
% dap   rawH< -60mV
% dap   rawH<-200mV
% sap spikeH<-200mV
dap_60 =[         76          41          19         142         230         364         567         857         957         978        1157        1286        1579        1871        1923        2121        2072        2205        2127        2535        2508        2510        2548        2600        2753        2917        3002        3208        3334        3417        3434        3564        3521        3508        3646        3729        3957        3966        3988        4161        4265        4644        5072        5046        5172        5264        5261        5243        5368        5362        5644        5543        5873        5860        5863        6686        6727        6903        7034        7106        7430        7472        7611        7736        8041        8019        8120        8337        8978        9091        9079        9280        9380        9572        9654        9883       10294       10685       10683];
dap_200=[         41         229         261         856        1769        1922        2071        2102        2025        2507        2509        2497        3207        3461        3405        3728        3885        4643        4943        5161        5441        5771        5757        5862        6685        6931        7328        7508        8019        8018        8875        8989        9279        9379      10191    ];
sap_200=[         376         494         632         640         935        1128        1048        1681        1867        1967        2033        2036        2251        2450        2563        2599        3011        3259        3309        3444        3471        3698        3873        3813        4058        4087        4102        4442        4624        4686        4902        4914        5012        5185        5466        5603        5515        5679        5865        6124        6207        6200        6269        6500        6470        6876        7254        7463        7403        7607        7811        7968        7987        8135        8416        8796        8914        8992        9115        9477        9649        9839       10074       10163       10328       10446       10460       10509       10511       10666       10694       10737       10674       10831       10856];
elc_with_neuron=unique([dap_200 sap_200]);
stimsites=[3124];


%101121
elc_with_neuron=[1520 2495 2636 5191 10586 10686 8802 9262];
stimsites=[3224];


%101122
elc_with_neuron=[928 1134 1865 1968 1869 1668 4333 5240 4256 4456 4659 6281 6970 10042 6031 4310 3018 269 3882 514];
stimsites=[1867];

%110312
elc_with_neuron=[9808 9616 9830 10521 10933 10732 10124 10136 10640 10435];
stimsites=[10019];




[x y]=el2position(elc_with_neuron);
figure
%plot(x,y,'.')
scatter(x,y,15,1:length(x),'filled')
set(gca,'YDir','reverse','Color',[1 1 1]*.6)
hold on
[x y]=el2position(stimsites);
plot(x,y,'k+','markersize',10)
hold off
box off
axis equal


neuroposfile=['/home/bakkumd/Data/configs/bakkum/neuroposFromMlab/' Info.Exptitle '.neuropos.nrk']
fid = fopen(neuroposfile, 'wt');

for i=1:length(elc_with_neuron)
    e=elc_with_neuron(i);
    [x y]=el2position(e);
    fprintf(fid, 'Neuron matlab%i: %i/%i, 10/10\n',i,x,y);
end
for i=1:length(stimsites)
    e=stimsites(i);
    [x y]=el2position(e);
    fprintf(fid, 'Neuron matlab%i: %i/%i, 10/10, stim\n',i+1,x,y);
end

fclose(fid);


%%
%%
%%
%%
% ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%%
%%
%%
%%
%%
%%
%%  plot block and non-block on same figure and save
%   comparing C to D

%   mm=0;
mm=mm+1;
mtraw_multi{mm}=ftraw;



%%  Do for comparison of N data sets
N=2;
%set(gcf,'Position',[1 257 300*N+300 500])
%set(gcf,'Position',[1 257 1200 500])
%%
%figure(111)
%set(gcf,'visible','off');
SAVE= 0 ;
ll = -50; % cutoff
ul = 15;  % cutoff
cnt = 0;
for i=100:210%size(mtraw,2)
    disp(i)
    
    
    subplot(1,N,1)
    %z=griddata(ELC.X(:),ELC.Y(:),tgaus_non(:,i),sx,sy);
    %z=griddata(ELC.X(:),ELC.Y(:),mtraw_multi{1}(:,i),sx,sy);
    z=griddata(ELC.X(ok),ELC.Y(ok),mtraw_multi{1}(ok,i)',sx,sy);
    imagesc(sx(1,:),sy(:,1),z)
    %    scatter(ELC.X(ok),ELC.Y(ok),75,mtraw_block1(ok,i),'filled');
    set(gca,'YDir','reverse')
    caxis([ll ul])
    axis equal
    hold on; plot(stim_x,stim_y,'k+','markersize',4);  hold off
    set(gca,'Color',[1 1 1]*.6)
    box off
    %axis([sx(1,[1 end]) sy([1 end],1)'])
    title(['090409   ' num2str((i-Info.Parameter.TriggerTimeZero)/20,'%3.2f') ' msec.  Sample: ' num2str(i,'%3.0f')])
    
    colorbar
    
    for n=2:N
        subplot(1,N,n)
        %z=griddata(ELC.X(:),ELC.Y(:),tgaus_blk(:,i),sx,sy);
        %z=griddata(ELC.X(:),ELC.Y(:),mtraw_multi{n}(:,i),sx,sy);
        z=griddata(ELC.X(ok),ELC.Y(ok),min( mtraw_multi{n}(ok,max([28 i-40]):i)' ),sx,sy);
        imagesc(sx(1,:),sy(:,1),z)
        %    scatter(ELC.X(ok),ELC.Y(ok),75,mtraw_block2(ok,i),'filled');
        set(gca,'YDir','reverse')
        caxis([ll ul])
        axis equal
        hold on; plot(stim_x,stim_y,'k+','markersize',4);  hold off
        set(gca,'Color',[1 1 1]*.6)
        box off
        %axis([sx(1,[1 end]) sy([1 end],1)'])
        %title(['+blockers'])
        title(['090409'])
        
        colorbar
        
    end
    
    
    
    %     subplot(1,4,3)
    %     %z=griddata(ELC.X(:),ELC.Y(:),tgaus_blk(:,i),sx,sy);
    %     z=griddata(ELC.X(:),ELC.Y(:),mtraw_3(:,i),sx,sy);
    %     imagesc(sx(1,:),sy(:,1),z)
    % %    scatter(ELC.X(ok),ELC.Y(ok),75,mtraw_block3(ok,i),'filled');
    %     set(gca,'YDir','reverse')
    %     caxis([ll ul])
    %     axis equal
    %     hold on; plot(stim_x,stim_y,'k+','markersize',4);  hold off
    %     set(gca,'Color',[1 1 1]*.6)
    %     box off
    %     %axis([sx(1,[1 end]) sy([1 end],1)'])
    %     %title(['+blockers'])
    %     title(['091123-D'])
    %
    %     subplot(1,4,4)
    %     %z=griddata(ELC.X(:),ELC.Y(:),tgaus_blk(:,i),sx,sy);
    %     z=griddata(ELC.X(:),ELC.Y(:),mtraw_4(:,i),sx,sy);
    %     imagesc(sx(1,:),sy(:,1),z)
    % %    scatter(ELC.X(ok),ELC.Y(ok),75,mtraw_block4(ok,i),'filled');
    %     set(gca,'YDir','reverse')
    %     caxis([ll ul])
    %     axis equal
    %     hold on; plot(stim_x,stim_y,'k+','markersize',4);  hold off
    %     set(gca,'Color',[1 1 1]*.6)
    %     box off
    %     %axis([sx(1,[1 end]) sy([1 end],1)'])
    %     %title(['+blockers'])
    %     title(['091123-E'])
    
    
    
    
    
    drawnow
    pause(.005)
    
    if SAVE
        if      cnt<10  filename = ['/home/bakkumd/Data/movies/pics/multi' Info.Exptitle '_00',int2str(cnt),'.jpg'];
        elseif  cnt<100 filename = ['/home/bakkumd/Data/movies/pics/multi' Info.Exptitle '_0',int2str(cnt),'.jpg'];
        else            filename = ['/home/bakkumd/Data/movies/pics/multi' Info.Exptitle '_',int2str(cnt),'.jpg'];
        end
        cnt=cnt+1;
        set(gcf,'inverthardcopy','off')
        %print('-djpeg','-r300',filename)
        print('-djpeg','-r256',filename)
    end
    
end




%%   %%    %%    OLD CODE   %%%     %%%    %%%%%%


%% try a median filter
% subtract median value over window of xx samples for each sample
wn=10;
ftraw=zeros(size(mtraw));
for k=wn+1:size(mtraw,2)-wn-1
    ftraw(:,k)=mtraw(:,k)-median(mtraw(:,k-wn:k+wn)')';
end



%% try salpa to remove artifact
% %sraw=zeros(size(mtraw));
% sraw=mtraw;
% N=10;    % window to fit polynomial [samples]
% hold off
% %for N=5:15
% deg=3;   % polynomial order
% lim=Info.Parameter.TriggerLength; % [samples] limit of polynomial fit after starting
% start=-2*lim;
% for c=ok%1:size(mtraw,1)
% %for i=N+1:Info.Parameter.TriggerLength-N-1
% for i=N+1:Info.Parameter.TriggerLength-N-1
%     if( i>=start && i-start<=lim )
%         x=i-N:i+N;
%         y=mtraw(c,x);
%         p = polyfit(x,y,deg);
%         f = polyval(p,x);
%         if i==start
%             sraw(c,i-N:i)=mtraw(c,i-N:i)-f(1:N+1);
%         else
%             sraw(c,i)=mtraw(c,i)-f(N+1);
%         end
%         %disp(int2str(i))
%     end
%     if( sum(abs(mtraw(c,i-10:i)))==0 && mtraw(c,i+1)~=0 )
%         start=i;%+N;
%         %disp(['start ' int2str(i)])
%     end
%
%
% end
% disp(int2str(c))
% end
% %plot(sraw(c,:)','color',[1 1 1]*N/20); hold on
% %end

% %% try a median filter
% % subtract median value over window of xx samples for each sample
% wn=10;
% ftraw=zeros(size(mtraw));
% for k=wn+1:size(mtraw,2)-wn-1
%     ftraw(:,k)=mtraw(:,k)-median(mtraw(:,k-wn:k+wn)')';
% %     [mn y]=min(abs(mtraw(:,k-wn:k+wn))');
% %     os=zeros(size(mtraw,1),1);
% %     for l=1:size(mtraw,1)
% %         os(l)=(mtraw(l,y(l)+k-wn-1));
% %     end
% %     ftraw(:,k)=mtraw(:,k)-os;
% end
% %ftraw(:,1:25)=0; % zero first artifact
% plot(([1:Info.Parameter.TriggerLength]-Info.Parameter.TriggerTimeZero)*.05,ftraw')
%   plot(ftraw')


% %% temporal gaussian
% clear target tgaus
% target=mtraw;
% % target=ftraw;
% tgaus=zeros(size(target));
% tgaus=gaussianblur1d(target',1)';
% clear target


%%
%%







% mtraw_1   = ftraw;
% mtraw_2   = ftraw;
% mtraw_3   = ftraw;
% mtraw_4   = ftraw;
%
%
% mtraw_block   = mtraw;
% mtraw_block   = ftraw;
%
% mtraw_nonblock = mtraw;
% mtraw_nonblock = ftraw;
%
% % target=mtraw_block;
% % tgaus_blk=target;
% % tgaus_blk=zeros(size(target));
% % tgaus_blk=gaussianblur1d(target',1)';
% % clear target
% %
% % target=mtraw_nonblock;
% % tgaus_non=target;
% % tgaus_non=zeros(size(target));
% % tgaus_non=gaussianblur1d(target',1)';
% % clear target
%
%
% set(gcf,'Position',[1 257 671*1.4 400])
% %%
% %figure(111)
% %set(gcf,'visible','off');
% SAVE= 1 ;
% ll = -50; % cutoff
% ul = 15;  % cutoff
% cnt = 0;
% for i=30:290%size(mtraw,2)
%     disp(i)
%
%
%     subplot(1,2,1)
%     %z=griddata(ELC.X(:),ELC.Y(:),tgaus_non(:,i),sx,sy);
%     z=griddata(ELC.X(:),ELC.Y(:),mtraw_nonblock(:,i),sx,sy);
% %    imagesc(sx(1,:),sy(:,1),z)
%     scatter(ELC.X(ok),ELC.Y(ok),75,mtraw_nonblock(ok,i),'filled'); set(gca,'YDir','reverse')
%
%
%     caxis([ll ul])
%     axis equal
%     hold on; plot(stim_x,stim_y,'k+','markersize',4);  hold off
%     set(gca,'Color',[1 1 1]*.6)
%     box off
%     %axis([sx(1,[1 end]) sy([1 end],1)'])
%     title(['091119-C   ' num2str((i-Info.Parameter.TriggerTimeZero)/20,'%3.2f') ' msec.  Sample: ' num2str(i,'%3.0f')])
%
%     subplot(1,2,2)
%     %z=griddata(ELC.X(:),ELC.Y(:),tgaus_blk(:,i),sx,sy);
%     z=griddata(ELC.X(:),ELC.Y(:),mtraw_block(:,i),sx,sy);
% %    imagesc(sx(1,:),sy(:,1),z)
%     scatter(ELC.X(ok),ELC.Y(ok),75,mtraw_block(ok,i),'filled'); set(gca,'YDir','reverse')
%     caxis([ll ul])
%     axis equal
%     hold on; plot(stim_x,stim_y,'k+','markersize',4);  hold off
%     set(gca,'Color',[1 1 1]*.6)
%     box off
%     %axis([sx(1,[1 end]) sy([1 end],1)'])
%     %title(['+blockers'])
%     title(['091120-E'])
%
%     drawnow
%     pause(.005)
%
%    if SAVE
%     if      cnt<10  filename = ['/home/bakkumd/Data/Desktop/movieframes/dual' Info.Exptitle '_00',int2str(cnt),'.jpg'];
%     elseif  cnt<100 filename = ['/home/bakkumd/Data/Desktop/movieframes/dual' Info.Exptitle '_0',int2str(cnt),'.jpg'];
%     else          filename = ['/home/bakkumd/Data/Desktop/movieframes/dual' Info.Exptitle '_',int2str(cnt),'.jpg'];
%     end
%     cnt=cnt+1;
%     set(gcf,'inverthardcopy','off')
%     print('-djpeg','-r300',filename)
%    end
%
% end





%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%    EXPERIMENT INFORMATION BELOW   %%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% Stim Scan
%
%
% analysis of 090409  A,B,C,D,E,F,G
% analysis of 090411  A,B,C,D,E,G,H,I
% and more...

% standard block-scan with one stim electrode (## stim per config @ #Hz, #
% configs per trial unless server crashed).  stimulation no longer
% effective after certain time. also, in G, maybe wash out moved cell,
% since not so many stim were used prior to lack of response?
%
% can see artifact range from this data...
% - need to smooth artifact to see response close to stim electrode.
%
% need to double check spike occurances, to prove dAPs are not secondary
% (may also be OK to use blocked control, once verified there)
%

clear all
pack



%%  Date: 24 january 2013    Chip 1164     Stim elc:3547   Stim voltage: 200mv  MOSR: R1=220 R2=220  v3 (close to electrolysis)

clear all; Info.Exptype='StimScan';
Info.Exptitle='el3547';
Info.Parameter.StimElectrode=3547;
Info.FileName.Spike            = ['/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/1164/data/24.January2013/stim_scan3547/200mv/spikes/' Info.Exptitle '.spike'];
Info.FileName.SpikeForm        = ['/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/1164/data/24.January2013/stim_scan3547/200mv/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Map              = ['/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/1164/data/24.January2013/stim_scan3547/200mv/configs/random_neuromap.m'];
Info.FileName.Trig             = ['/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/1164/data/24.January2013/stim_scan3547/200mv/raw/' Info.Exptitle '.raw.trig'];
Info.FileName.Raw              = ['/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/1164/data/24.January2013/stim_scan3547/200mv/raw/' Info.Exptitle '.raw'];
Info.FileName.TrigRawAve       = ['/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/1164/data/24.January2013/stim_scan3547/200mv/raw/' Info.Exptitle '.averaged.traw'];
Info.Parameter.NumberStim=0; % tells cpp code to look at epochs for averaging
Info.Parameter.ConfigNumber=95; % random
Info.Parameter.TriggerTimeZero=61;% [samples] stimulation center (time zero)
Info.Parameter.ConfigDuration=15; % [ms] length of triggered rec
Info.Parameter.TriggerLength=300; % [samples] length of triggered re
%%  Date: 24 january 2013    Chip 1164     Stim elc:1495   Stim voltage: 200mv  MOSR: R1=220 R2=220  v3 (close to electrolysis)

clear all; Info.Exptype='StimScan';
Info.Exptitle='el1495';
Info.Parameter.StimElectrode=1495;
Info.FileName.Spike            = ['/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/1164/data/24.January2013/stim_scan1495/200mv/spikes/' Info.Exptitle '.spike'];
Info.FileName.SpikeForm        = ['/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/1164/data/24.January2013/stim_scan1495/200mv/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Map              = ['/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/1164/data/24.January2013/stim_scan1495/200mv/configs/random_neuromap.m'];
Info.FileName.Trig             = ['/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/1164/data/24.January2013/stim_scan1495/200mv/raw/' Info.Exptitle '.raw.trig'];
Info.FileName.Raw              = ['/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/1164/data/24.January2013/stim_scan1495/200mv/raw/' Info.Exptitle '.raw'];
Info.FileName.TrigRawAve       = ['/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/1164/data/24.January2013/stim_scan1495/200mv/raw/' Info.Exptitle '.averaged.traw'];
Info.Parameter.NumberStim=0; % tells cpp code to look at epochs for averaging
Info.Parameter.ConfigNumber=95; % random
Info.Parameter.TriggerTimeZero=61;% [samples] stimulation center (time zero)
Info.Parameter.ConfigDuration=15; % [ms] length of triggered rec
Info.Parameter.TriggerLength=300; % [samples] length of triggered re
%%  Date: 24 january 2013    Chip 1164     Stim elc:1658   Stim voltage: 170mv  MOSR: R1=220 R2=220  v3 (close to electrolysis)

clear all; Info.Exptype='StimScan';
Info.Exptitle='el1658';
Info.Parameter.StimElectrode=1658;
Info.FileName.Spike            = ['/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/1164/data/24.January2013/stim_scan1658/170mv/spikes/' Info.Exptitle '.spike'];
Info.FileName.SpikeForm        = ['/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/1164/data/24.January2013/stim_scan1658/170mv/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Map              = ['/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/1164/data/24.January2013/stim_scan1658/170mv/configs/random_neuromap.m'];
Info.FileName.Trig             = ['/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/1164/data/24.January2013/stim_scan1658/170mv/raw/' Info.Exptitle '.raw.trig'];
Info.FileName.Raw              = ['/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/1164/data/24.January2013/stim_scan1658/170mv/raw/' Info.Exptitle '.raw'];
Info.FileName.TrigRawAve       = ['/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/1164/data/24.January2013/stim_scan1658/170mv/raw/' Info.Exptitle '.averaged.traw'];
Info.Parameter.NumberStim=0; % tells cpp code to look at epochs for averaging
Info.Parameter.ConfigNumber=95; % random
Info.Parameter.TriggerTimeZero=61;% [samples] stimulation center (time zero)
Info.Parameter.ConfigDuration=15; % [ms] length of triggered rec
Info.Parameter.TriggerLength=300; % [samples] length of triggered re
%%  Date: 24 january 2013    Chip 1164     Stim elc:1658   Stim voltage: 100mv  MOSR: R1=220 R2=220  v3 (close to electrolysis)

clear all; Info.Exptype='StimScan';
Info.Exptitle='el1658';
Info.Parameter.StimElectrode=1658;
Info.FileName.Spike            = ['/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/1164/data/24.January2013/stim_scan1658/100mv/spikes/' Info.Exptitle '.spike'];
Info.FileName.SpikeForm        = ['/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/1164/data/24.January2013/stim_scan1658/100mv/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Map              = ['/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/1164/data/24.January2013/stim_scan1658/100mv/configs/random_neuromap.m'];
Info.FileName.Trig             = ['/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/1164/data/24.January2013/stim_scan1658/100mv/raw/' Info.Exptitle '.raw.trig'];
Info.FileName.Raw              = ['/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/1164/data/24.January2013/stim_scan1658/100mv/raw/' Info.Exptitle '.raw'];
Info.FileName.TrigRawAve       = ['/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/1164/data/24.January2013/stim_scan1658/100mv/raw/' Info.Exptitle '.averaged.traw'];
Info.Parameter.NumberStim=0; % tells cpp code to look at epochs for averaging
Info.Parameter.ConfigNumber=95; % random
Info.Parameter.TriggerTimeZero=61;% [samples] stimulation center (time zero)
Info.Parameter.ConfigDuration=15; % [ms] length of triggered rec
Info.Parameter.TriggerLength=300; % [samples] length of triggered re

