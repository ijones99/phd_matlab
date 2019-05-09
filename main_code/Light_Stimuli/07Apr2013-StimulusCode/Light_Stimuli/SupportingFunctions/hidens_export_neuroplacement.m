function hidens_export_neuroplacement(neurons, varargin)

n_list=1:length(neurons);
c_sr=1;
tot_channels=126;
channel_f=1.4;             %
max_cost=100;
fname='';
method='maxpk';
folder='';
ts_pos=-1;
gridspace_um=5;
version=2;

i=1;
while i<=length(varargin)
    if not(isempty(varargin{i}))
        if strcmp(varargin{i}, 'sr')
            i=i+1;
            c_sr=varargin{i};    
        elseif strcmp(varargin{i}, 'neurons')
            i=i+1;
            n_list=varargin{i};    
        elseif strcmp(varargin{i}, 'filename')
            i=i+1;
            fname=varargin{i};    
        elseif strcmp(varargin{i}, 'folder')
            i=i+1;
            folder=varargin{i};    
        elseif strcmp(varargin{i}, 'channels')
            i=i+1;
            tot_channels=varargin{i};    
        elseif strcmp(varargin{i}, 'method')
            i=i+1;
            method=varargin{i};    
        elseif strcmp(varargin{i}, 'tspos')  %is used for background
            i=i+1;
            ts_pos=varargin{i};
        elseif strcmp(varargin{i}, 'version')  %is used for background
            i=i+1;
            version=varargin{i};
        else
            fprintf('unknown argument at pos %d\n', 1+i);
        end
    end
    i=i+1;
end

%some initializations
if isempty(fname)
    fname=['neurons' num2str(n_list, '-%d') '_date' date '.neuropos.nrk'];
end


channels_per_neuron=ceil(tot_channels*channel_f)/length(n_list);

%electrode selection
if strcmp(method, 'maxpk')
    npos=hidens_select_maxpk(neurons, n_list, channels_per_neuron, max_cost, c_sr);
elseif strcmp(method, 'interpolated')
    
    npos=cell(1,0);
    el=hidens_get_all_electrodes(version,1);

    for n=1:length(n_list)
        if ts_pos<0
            if isfield(neurons{n_list(n)}, 'loc')
                if isfield(neurons{n_list(n)}.loc, 'tspos')
                    ts_pos=neurons{n_list(n)}.template.pre+neurons{n_list(n)}.loc.tspos;
                    fprintf('using triangulation tspos for background\n');
                end
            end
        end
        if ts_pos<0
            fprintf('error: need a tspos for plotting background data\n');
            return
        end
        
        xmin=min(neurons{n_list(n)}.x);
        xmax=max(neurons{n_list(n)}.x);
        ymin=min(neurons{n_list(n)}.y);
        ymax=max(neurons{n_list(n)}.y);
        
       
        xlin=linspace(xmin,xmax,(xmax-xmin)/gridspace_um);
        ylin=linspace(ymin,ymax,(ymax-ymin)/gridspace_um);
        [XI,YI] = meshgrid(xlin,ylin);

        [idx dist]=get_closest_electrode(neurons{n_list(n)}.x,neurons{n_list(n)}.y);
        avg_elspacing=median(dist);

        %designing filter
        ifilter=fspecial('gaussian', ceil(avg_elspacing/gridspace_um)*3, avg_elspacing/gridspace_um/2); 

        z=neurons{n_list(n)}.template.data(round(ts_pos),:);

        ZI = griddata(neurons{n_list(n)}.x,neurons{n_list(n)}.y,z,XI,YI,'cubic');
        ZIexp = griddata(neurons{n_list(n)}.x,neurons{n_list(n)}.y,z,XI,YI,'nearest');

        ZIz=ZI;
        ZIz(isnan(ZI))=0;
        ZIboth=ZIz.*(1-isnan(ZI))+ZIexp.*isnan(ZI);
        ZSboth = ZIboth;
        %ZSboth = conv2(ZIboth,F,'same');
        if not(isempty(ifilter))
            ZSboth=filter2(ifilter,ZIboth);
            %TODO: get proper limits
        end
        ZSbothinside=ZSboth;
        ZSbothinside(isnan(ZI))=NaN;
        ZSbothinside(isnan(ZSbothinside))=0;
        
        sel=find(el.x>=xmin & el.x<=xmax & el.y>=ymin & el.y<=ymax);
        
        ampl=interp2(XI,YI,ZSbothinside, el.x(sel), el.y(sel));
        
        %[maxpk_v maxpk_i]=max(abs(ampl));
        maxpk_v=abs(ampl);
        cost=max_cost-maxpk_v/max(maxpk_v)*max_cost;
        [s six]=sort(cost);

        for eli=1:min([channels_per_neuron length(sel)])
            el_idx=six(eli);
            npos{end+1}.label=['maxpk_n' num2str(n_list(n)) '_e' num2str(eli)];
            npos{end}.x=el.x(sel(el_idx));
            npos{end}.y=el.y(sel(el_idx));
            npos{end}.cost=cost(six(eli));
            %if c_sr~=1
            %    npos{end}.c_sr=c_sr;
            %end
        end
        
    end
    
elseif strcmp(method, 'loc')
    npos=cell(1,0);
    el=hidens_get_all_electrodes(version,1);

    [idx dist]=get_closest_electrode(el.x(1:300),el.y(1:300));
    avg_elspacing=min(dist);
    
    %get pixelsize
    [idx dist]=get_closest_electrode(el.x(el.x(1)==el.x), el.y(el.x(1)==el.x));
    pixelY=min(dist);
    [idx dist]=get_closest_electrode(el.x(el.y(1)==el.y), el.y(el.y(1)==el.y));
    pixelX=min(dist)/2;  
    
    xmin=min(el.x);
    xmax=max(el.x);
    ymin=min(el.y);
    ymax=max(el.y);
    total_w=xmax-xmin;
    total_h=ymax-ymin;
    
    bx=11;

    %3spaced
    sx=3;
    sy=3;
    xx=floor(-50/sx):ceil(160/sx);
    yy=floor(-50/sy):ceil(160/sy);
    x3=[];
    y3=[];
    for ix=xx
        for iy=yy
            x3(end+1)=xmin+ix*sx*pixelX;
            y3(end+1)=ymin+(iy*sy+ix/bx*sy+mod(ix,2))*pixelY;
        end
    end 
    [idx dist]=get_closest_electrode(x3(1:10), y3(1:10));
    nsize3=min(dist);
    
    %2spaced
    sx=2;
    sy=2;
    xx=floor(-50/sx):ceil(160/sx);
    yy=floor(-50/sy):ceil(160/sy);
    x2=[];
    y2=[];
    for ix=xx
        for iy=yy
            x2(end+1)=xmin+ix*sx*pixelX;
            y2(end+1)=ymin+(iy*sy+ix/bx*sy+mod(ix,2))*pixelY;
        end
    end 
    [idx dist]=get_closest_electrode(x3(1:10), y3(1:10));
    nsize2=min(dist);

    
     for n=1:length(n_list)
         if isfield(neurons{n_list(n)}, 'loc')
             if isfield(neurons{n_list(n)}.loc, 'tail')
                locx=neurons{n_list(n)}.loc.tail.xs;
                locy=neurons{n_list(n)}.loc.tail.ys;
             	%2spaced
                rad2=avg_elspacing*2.5;
                sel=find(((x2-locx).^2+(y2-locy).^2)<rad2^2);
                for ii=1:length(sel)
                    npos{end+1}.label=sprintf('loc_n%d_2tail%d', n_list(n), ii);
                    npos{end}.x=x2(sel(ii));
                    npos{end}.y=y2(sel(ii));
                    npos{end}.dx=avg_elspacing*2.3;
                end
                %3spaced
                rad3=avg_elspacing*12;
                sel=find(((x3-locx).^2+(y3-locy).^2)<rad3^2);
                for ii=1:length(sel)
                    npos{end+1}.label=sprintf('loc_n%d_3tail%d', n_list(n), ii);
                    npos{end}.x=x3(sel(ii));
                    npos{end}.y=y3(sel(ii));
                    npos{end}.dx=avg_elspacing*3.3;
                end
                 
             end
             if isfield(neurons{n_list(n)}.loc, 'head')
                locx=neurons{n_list(n)}.loc.head.xs;
                locy=neurons{n_list(n)}.loc.head.ys;
                %1spaced
                rad1=avg_elspacing*2.5;
                sel=find(((el.x-locx).^2+(el.y-locy).^2)<rad1^2);
                for ii=1:length(sel)
                    npos{end+1}.label=sprintf('loc_n%d_1head%d', n_list(n), ii);
                    npos{end}.x=el.x(sel(ii));
                    npos{end}.y=el.y(sel(ii));
                    npos{end}.dx=avg_elspacing*1.1;
                end
             	%2spaced
                rad2=avg_elspacing*3;
                sel=find(((x2-locx).^2+(y2-locy).^2)<rad2^2);
                for ii=1:length(sel)
                    npos{end+1}.label=sprintf('loc_n%d_2head%d', n_list(n), ii);
                    npos{end}.x=x2(sel(ii));
                    npos{end}.y=y2(sel(ii));
                    npos{end}.dx=avg_elspacing*2.3;
                end
                %3spaced
                rad3=avg_elspacing*6;
                sel=find(((x3-locx).^2+(y3-locy).^2)<rad3^2);
                for ii=1:length(sel)
                    npos{end+1}.label=sprintf('loc_n%d_3head%d', n_list(n), ii);
                    npos{end}.x=x3(sel(ii));
                    npos{end}.y=y3(sel(ii));
                    npos{end}.dx=avg_elspacing*3.3;
                end
                 
             end
         end
         
     end
    
else 
    error('unknown electrode selection method');
end


%export to file
hidens_write_neuroplacement(fname, 'npos', npos, 'folder', folder);












