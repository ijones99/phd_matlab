% function gen_sequence_with_fix_electrodes(fname, fix_els, scan_params)

% I realized that this is possible with Neurodishrouter. Maybe still Do
% that once, but not now...!

%% Script
    
%% electrodes
version=2;
all_els=hidens_get_all_electrodes(version);

%%
%params:

sel_els=[]; % electrodes to use, with high priority
% sel_els=axonal_els_elidx;

axonal_els_elidx=10:15;

% xmin=1310;
% xmax=1893;
% 
% ymin=1440;
% ymax=2086;
xmin = min(all_els.x);
xmax = max(all_els.x);
ymin = min(all_els.y);
ymax = max(all_els.y);
% blocks
x_block=6;
y_block=16;

% not implemented yet!!:
x_step=1;
y_step=1;

x_overlap=2;
y_overlap=1;

%% hard params

x_dist=16.2;
y_dist=19.588;
b=2;    %um buffer

xmin=max([xmin min(all_els.x)]);
ymin=max([ymin min(all_els.y)]);

xmax=min([xmax max(all_els.x)]);
ymax=min([ymax max(all_els.y)]);

%%

% how many blocks?

n_x_blocks=ceil((xmax-xmin)/((x_block+1-x_overlap-1)*x_dist));
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
%         plot_electrode_map()
    end
end

%% nice visualization

cmap=lines(length(scan_els))
figure;
hold on

plot(all_els.x,all_els.y,'b.','Markersize',3);
xlabel('\mum');ylabel('\mum');

axis ij;axis equal;hold on;

for i=1:length(scan_els)
    h(i)=plot(scan_els{i}.x,scan_els{i}.y,'o','Markersize',3,'Color',cmap(i,:));
%     hl{i}=['(' num2str(i) ') Gain: ' num2str(scan_els{i}.gain, '%.1f')];
    rectangle('Position',[min(scan_els{i}.x),min(scan_els{i}.y),max(scan_els{i}.x)-min(scan_els{i}.x),...
        max(scan_els{i}.y)-min(scan_els{i}.y)],'LineWidth',1,'LineStyle','--','EdgeColor',cmap(i,:));
    text(mean(scan_els{i}.x),mean(scan_els{i}.y),num2str(i),'FontSize',12,'Color',cmap(i,:));
end

%% write neuropos files:

req_electrodes=1;
fnames= []
for i=1:length(scan_els)
    if i<10
        fnames{i}=['scan_config_00' int2str(i)];
    elseif i>9 && i<100
        fnames{i}=['scan_config_0' int2str(i)];
    elseif i>100
        fnames{i}=['scan_config_' int2str(i)];
    end
end

for fn=1:3%length(fnames)
    npos_multiloc={};
    % axonal els
    for n=1:length(axonal_els_elidx)
        npos_multiloc{end+1}.label=sprintf('axonal%d', n);
        npos_multiloc{end}.x=all_els.x(find(all_els.el_idx==axonal_els_elidx(n)));
        npos_multiloc{end}.y=all_els.y(find(all_els.el_idx==axonal_els_elidx(n)));
        npos_multiloc{end}.cost=0;
        npos_multiloc{end}.elcnt=req_electrodes;
%     npos_multiloc{end}.multiloc=1;
    end
    % block els -> check in 
    for n=1:length(scan_els{fn}.x)
        npos_multiloc{end+1}.label=sprintf('block%d', n);
        npos_multiloc{end}.x=scan_els{fn}.x(n);
        npos_multiloc{end}.y=scan_els{fn}.y(n);
        npos_multiloc{end}.cost=50;
        npos_multiloc{end}.elcnt=req_electrodes;
%     npos_multiloc{end}.multiloc=1;
    end
    
    
    hidens_write_neuroplacement([fnames{fn} '.neuropos.nrk'], 'npos', npos_multiloc, 'size', 20);
end

%% routing

experiment='axon_scan3';

nr_exe='NeuroDishRouter';
for fn=1:length(fnames)
    fprintf('running: %s -n -v 2 -l %s -s %s\n', nr_exe, [pwd '/../Configs/matlab_specs/' fnames{fn} '.neuropos.nrk'], [pwd '/../Configs/' experiment '/' fnames{fn}]);
    unix(sprintf('%s -n -v 2 -l %s -s %s\n', nr_exe, [pwd '/../Configs/matlab_specs/' fnames{fn} '.neuropos.nrk'], [pwd '/../Configs/' experiment '/' fnames{fn}]));
end


%% check

x=all_els.x(axonal_els_elidx+1);
y=all_els.y(axonal_els_elidx+1);

for fn=1:2%length(fnames)

    fname=['../Configs/' experiment '/' fnames{fn} '.el2fi.nrk2'];
    fid=fopen(fname);
    elidx=[];
    tline = fgetl(fid);
    while ischar(tline)
        [tokens] = regexp(tline, 'el\((\d+)\)', 'tokens');
        elidx(end+1)=str2double(tokens{1});
        tline = fgetl(fid);
    end
    fclose(fid);

    
    figure; % plot selected vs routed
    hold on
    axis ij;axis equal;
    l{1}=plot(x,y,'b.');
    l{1}=plot(scan_els{fn}.x,scan_els{fn}.y,'k.');
    
    l{2}=plot(all_els.x(elidx+1), all_els.y(elidx+1), 'ro');
%     xlim([xmin xmax])
% %     ylim([ymin ymax])
    
end