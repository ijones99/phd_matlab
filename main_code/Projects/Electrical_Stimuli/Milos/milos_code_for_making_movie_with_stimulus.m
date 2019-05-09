%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                      TRAJECTORIES OF AXONS                      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     START     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%   clickelectrode through movie frames

% figure
figure(26) %
paper_w = 1070;
paper_h = 1090;
set(gcf,'Position',[1700 150 paper_w paper_h])
set(gcf,'PaperPosition',[0 0 [paper_w paper_h]/70/3])

% set(gcf,'PaperSize',[paper_w paper_h]/70/3)
set(gcf,'PaperSize',[paper_w paper_h]/70/3)
axes('Position',[.1  .15  .8 .8]);
% colorbar
fontsize = 4;
    
% stim electrode
elc_with_neuron=10661

cnt=0;
i = Info.Parameter.TriggerTimeZero-1 + 10;
%%%   movie
SAVE    =    0 ; % print figures to file
FILL    =    0 ; % plot using 'fill' (HIGH QUALITY; longer to run)
PLOTMIN =    0 ; % write text at valleys
FILLALL =    1 ; % fill non-connected electrodes with average of connected neighbors
GAUS    =    0 ; % blur with a gaussian

ll      =   -20; %-45; % [uV]    -40;%-50 ; % cutoff   -50 [samples]  --- lower color bar limit
ul      =    5; % [uV]     12;% 15 ; % cutoff    15 [samples]   ---- upper color bar limit



% electrode sizes.  default v2 is type "M Pt3um default" 8.2x5.8um
elc_dimx = 16.2-1; % um
elc_dimy = 19.588; % um  % from unique(diff(ELC.Y))
rng  =   25; % [um]     range around non-connected electrodes used to average value for that electrode

    
clr1    =  mkpj(ul-ll+1,'J_DB');              % modified by me to add more red (perceptually balanced colormaps)

% while i<=size(mtraw,2) 
  for i=100:300

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
            [x y]    = el2position(j-1); %0
            if x==-1, continue; end % dummy electrode
            xx       = find( (ELC.X(ok)-x).^2+(ELC.Y(ok)-y).^2 < rng^2 ); % get neighbor electrodes
            tar(j,:) = mean( tar(ok(xx),:) );
        end
    end
    
    % Smooth with a gaussian-like function
    if GAUS
        gaus_rng = 25; % [um] - corresponds to 1st neighboring ring of electrodes
        for j=0:11015 
            [x y]    = el2position(j);
            if x==-1, continue; end % dummy electrode
            d_sq     = (ELC.X-x).^2+(ELC.Y-y).^2;
            xx       = find( d_sq < gaus_rng^2  &  d_sq > 0); % get neighbor electrodes
            tar(j+1,:) = ( mean( tar(xx,:) ) + tar(j+1,:) )/2;
        end
    end
        
        
    % Plot
    if FILL      
        % FILL in electrodes
        %  figure
        for j=0:11015%ok-1,   
            [x y]=el2position(j);  
            if x==-1; continue, end % dummy electrode
            cc = clr1(round(tar(j+1))-ll+1,:);
            %cc = round(tar(j+1))-ll+1;
            h=fill([ -elc_dimx -elc_dimx  elc_dimx  elc_dimx ]/2+x, [ -elc_dimy elc_dimy elc_dimy -elc_dimy]/2+y, cc, 'edgecolor', 'none' , 'linewidth', 1); 
            %set(h,'facealpha',.5)
            hold on
        end
        
    else
        % IMAGESC to plot quickly
        %z=griddata(ELC.X(ok),ELC.Y(ok),target(ok,i),sx,sy,'cubic'); 
        id=find(ELC.X>0); % ignor dummy electrodes
        z=griddata(ELC.X(id),ELC.Y(id),tar(id),sx,sy,'cubic');          
        imagesc(sx(1,:),sy(:,1),z);   axis([sx(1,[1 end]) sy([1 end],1)'])


    end
    
    
    if 0  % % for overlay on image % % %
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
        colormap(clr1)
        caxis([ll ul])
    end



    hold on
    plot(stim_x,stim_y,'w+','markersize',10,'linewidth',3)
    hold off
    set(gca,'Color',[1 1 1]*.6)
    % title(['Time since stimulation: ' num2str((i-Info.Parameter.TriggerTimeZero)/20,'%3.2f') ' msec.  Sample: ' num2str(i,'%3.0f')])
    title([Info.Exptitle ' ' num2str((i-Info.Parameter.TriggerTimeZero)/20,'%3.2f') ' msec.  Sample: ' num2str(i,'%3.0f')])
    
    % old_bar = findobj('tag','Colorbar'); delete(old_bar);
    cb = colorbar('location','southoutside');
        set(get(cb,'xlabel'),'String', 'Voltage [uV]','FontSize',fontsize,'FontWeight','bold');
        %cpos=get(cb,'Position');
        %cpos(4)=cpos(4)/3; % Halve the thickness
        %cpos(2)=cpos(2)+cpos(4)*2;
        cpos=[.125 .085 .75 .02];
        set(cb,'Position',cpos);

    box on
    axis equal ij
    axis([100 2000 50 2150])
    set(gca,'xTickLabel',{})
    %xlabel 'Position [um]'
    ylabel 'Position [um]'
    
   if SAVE
       figure_fontsize(fontsize,'bold')
       %text(1610,2110,'Douglas James Bakkum ','fontweight','bold','fontsize',3)

    desc = '';
    if FILL,     desc = [desc '-scatter']; end
    if FILLALL,  desc = [desc '-fillall']; end
    if GAUS,     desc = [desc '-gaus'];    end

    filename=sprintf('/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/1190/data/stim_scan/26May2013/3298_1100mv/movie/pics/%s%s_%03d',Info.Exptitle,desc,cnt);
    cnt=cnt+1;
    set(gcf,'inverthardcopy','off')
    set(gcf,'color','w')
    print('-dpng','-r600',[filename '.png']) 
   end
    
    drawnow
    %pause%(.005)
    if PLOTMIN, pause; end
     plotelectrodenumbers('notext', 'box');

     hold on
     axis ij equal
     [x y] =el2position(elc_with_neuron);
     scatter(x,y,30,'c','filled')
     
   
     clickelectrode 

     elc_with_neuron=ans

  end


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                      TRAJECTORIES OF AXONS                      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      END      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elc_with_neuron  = []
elc_to_stimulate = []


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       MAKE CONFIGS FROM THE 'CLICKELECTRODE' SET START          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                  elc_with_neuron  = []                          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                  elc_to_stimulate = []                          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% make neuropos file 
% % if too many, randomly choose
%   neurons=elc_with_neuron;
%   rp=randperm(length(neurons));
%   elc_with_neuron=neurons(rp(1:150));
%neuroposfile=['/opt/cmosmea_external/configs/bakkum/' Info.Exptitle '.neuropos.nrk']

% % if too many, choose largest spikes
%   [a b]= sort(height(elc_with_neuron+1));
%   elc_with_neuron = elc_with_neuron(b(1:130));

neuroposfile=['/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/1202/data/stim_scan/26May2013/10661_505mv/axonal_recordings/axonal_config2/antidromic_10661' Info.Exptitle '.neuropos.nrk']
fid = fopen(neuroposfile, 'wt');
for i=1:length(elc_with_neuron)
    e=elc_with_neuron(i);
    [x y]=el2position(e);
    x = round(x);
    y = round(y);
    fprintf(fid, 'Neuron matlab%i: %i/%i, 10/10\n',i,x,y);
end
fclose(fid);

%% make neuropos file 
% % if too many, randomly choose
  
  neurons=elc_with_neuron;
  rp=randperm(length(neurons));
  maximumElNumber = min(126, length(neurons) );
  elc_with_neuron=neurons(rp(1:maximumElNumber));
  neuroposfile=['/opt/cmosmea_external/configs/bakkum/' Info.Exptitle '.neuropos.nrk']

% % if too many, choose largest spikes
%   [a b]= sort(height(elc_with_neuron+1));
%   elc_with_neuron = elc_with_neuron(b(1:130));

neuroposfile=['/home/milosra/bel.svn/hima_internal/cmosmea_recordings/trunk/milosra/1202/data/stim_scan/26May2013/10661_505mv/axonal_recordings/axonal_config2/antidromic_10661' Info.Exptitle '.neuropos.nrk']
fid = fopen(neuroposfile, 'wt');

% normal electrodes without stimulation request
for i=1:length(elc_with_neuron)
    e=elc_with_neuron(i);
    [x y]=el2position(e);
    x = round(x);
    y = round(y);
    fprintf(fid, 'Neuron matlab%i: %i/%i, 10/10\n',i,x,y);        
end

% stimulation electrodes
for i=1:length(elc_to_stimulate)
    e=elc_to_stimulate(i);
    [x y]=el2position(e);
    x = round(x);
    y = round(y);
    fprintf(fid, 'Neuron matlab%i: %i/%i, 10/10, stim\n',i,x,y);
end
fclose(fid);


%% execute NeuroDishRouter
    
ndr_exe='`which NeuroDishRouter`';

[pathstr, name, ext] = fileparts(neuroposfile);
[tmp, name]          = fileparts(name);
fnames{1}            = [pathstr '/' name];
neurs_to_take{1}     = elc_with_neuron;

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
    box on,    hold on;
    axis ij,   axis equal

    plot(mposx,mposy,'.','color',[1 1 1]*.8)
    plot(mposx(neurs_to_take{fn}+1),mposy(neurs_to_take{fn}+1),'sk')
    plot(mposx(elidx+1), mposy(elidx+1), 'rx');
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       MAKE CONFIGS FROM THE 'CLICKELECTRODE' SET  END         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
