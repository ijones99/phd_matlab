function MakeBlockConfigs(varargin)
% Milos Radivojevic 2013
%
%      MakeBlockConfigs(varargin)
%
%      'no_plot'         -    doesn't plot configuration
%      'config_path'     -    directory path
%      'stim_elc'        -    stimulation electrode (optional)
%      'el_up'           -    upper-left reference electrode (gives xmin & ymin)  
%      'el_down'         -    lower-right reference electrode (gives xmax & ymax)  
%      'x_overlap'       -    number of overlaping electrodes in x-axis
%      'y_overlap'       -    number of overlaping electrodes in y-axis
%      'x_block'         -    lenght of x  
%      'y_block'         -    lenght of y


STIM = 0;
PLOT = 1;

i=1;
while i<=length(varargin)
    if not(isempty(varargin{i}))
        if strcmp(varargin{i}, 'no_plot')
            PLOT=0;
        elseif strcmp(varargin{i}, 'stim_elc')
            i=i+1;
            STIM = 1;
            Stim_el=varargin{i};
        elseif strcmp(varargin{i}, 'config_path')
            i=i+1;
            BASE_DIR=varargin{i};
        elseif strcmp(varargin{i}, 'el_up')
            i=i+1;
            el_up=varargin{i};
        elseif strcmp(varargin{i}, 'el_down')
            i=i+1;
            el_down=varargin{i};
        elseif strcmp(varargin{i}, 'x_block')
            i=i+1;
            x_block=varargin{i};
        elseif strcmp(varargin{i}, 'y_block')
            i=i+1;
            y_block=varargin{i};
        elseif strcmp(varargin{i}, 'x_overlap')
            i=i+1;
            x_overlap=varargin{i};
        elseif strcmp(varargin{i}, 'y_overlap')
            i=i+1;
            y_overlap=varargin{i};
        else
            fprintf('unknown argument at pos %d\n', 1+i);
        end
    end
    i=i+1;
end

if STIM == 0;
    Stim_el = [];
end

[x,y] = el2position(el_up);
xmin = round(x);
ymin = round(y);

[x,y] = el2position(el_down);
xmax = round(x);
ymax = round(y);

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
    
    cmap=lines(length(scan_els));
end

for configs             =       1:length(scan_els);
    
    if configs > 1
        pause(2)
    end
    
    %   make neuropos file
    neuroposfile=[BASE_DIR sprintf('%03d.neuropos.nrk',  configs-1)];
    fid = fopen(neuroposfile, 'w');
    
    %   stimulation electrodes
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
    
    %   Reload & visualize configurations
    if PLOT
        if STIM
            %   plot stimulation sites
            ismember(STIM_EL, elidx);
            st = find(ismember(STIM_EL, Stim_el));
            stimulation_site(configs) = STIM_EL(st);
            plot(mposx(stimulation_site+1),mposy(stimulation_site+1),'sk', 'color', 'b');
        end
        %   plot recording sites
        al=find(ismember(electrodes, elidx));
        plot(mposx(electrodes(al)+1),mposy(electrodes(al)+1),'o', 'color', cmap(configs,:));
    end
end