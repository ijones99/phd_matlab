%% get configurations
make_flist_select('flist_finding_axon.m');

%% load flist
flist={};
flist_finding_axon


%%
figure;

plot_recording_blocks(flist,'Experiment 1', 'nolegend')

%% somatic electrodes



%% all parameters

thr_f=6;
pretime=30;paramex
posttime=30;
siz=3600000;

%% loop through ntks
% axonal_els_elidx
clear axonal_neuron
for ii=1%:length(axon_els.el_idx)
    axonal_neuron{ii}.ts=[];
    axonal_neuron{ii}.ts_pos=[];
    axonal_neuron{ii}.trace=[];
    axonal_neuron{ii}.fname={};
    axonal_neuron{ii}.ts_fidx=[];
end

%% load electrodes near init segment
elsToScan = load('elsToScan.nrconfig.mat');
initSegEls = elsToScan.configList(1).selectedElectrodes;


%% test for non-corrupted ntk files
noncorruptedInds = 1:length(flist);
haveAllInitSegEls = zeros(length(flist),6);

for fl_ind=1:length(flist)
    
    try
    ntk=initialize_ntkstruct(flist{fl_ind});
    [ntk2dum ntk]=ntk_load(ntk, 2e4*60*5);
    if size(ntk2dum.sig,1) == 1
        noncorruptedInds(fl_ind) = NaN;
    end
    
    % test for whether init seg els are in config
    [C,ia,ib] = intersect(ntk2dum.el_idx,initSegEls) ;
    
    haveAllInitSegEls(fl_ind,[ib]) = C;
    catch
        noncorruptedInds(fl_ind) = NaN;
    end
end
%%
noncorruptedIndsOrig = noncorruptedInds;
% find inds of files that don't have all els
[dontHaveElsInds, junk] = find(haveAllInitSegEls==0);
dontHaveElsInds = unique(dontHaveElsInds);

noncorruptedInds(dontHaveElsInds) = NaN;

%% modify flist
flistNew = {};
for i= noncorruptedInds
    flistNew{end+1} = flist{i};
    
    
end
flist = flistNew;


%%
for fl_ind=noncorruptedInds
    
    %% load selected el
    
    ntk=initialize_ntkstruct(flist{fl_ind});
    [ntk2dum ntk]=ntk_load(ntk, 1000);
    
    
    %% load the data
    % hier suchen (mit spec electrode)
    electrodeToThreshold = 6372;
    localInd=find(ntk2dum.el_idx==electrodeToThreshold);
    selected_ch=ntk2dum.channel_nr(localInd);
    ntk=initialize_ntkstruct(flist{fl_ind});
    [ntk2 ntk]=ntk_load(ntk, siz, 'keep_only',selected_ch);
    % ntk2=detect_valid_channels(ntk2,1);
    selected_el
    %%  detect events
    
    allevents=simple_event_cut(ntk2, thr_f, pretime, posttime);
    
    %% distribute events to axonal electrodes
    
    
    for ii=1:length(electrodeToThreshold)
        
        
        ch_ind=find(ntk2.el_idx==electrodeToThreshold(ii));
        if ~isempty(ch_ind)
            spikes_ind=find(allevents.ch==ch_ind);
            axonal_neuron{ii}.ts=[axonal_neuron{ii}.ts double(ntk2.frame_no(allevents.ts(spikes_ind)))];
            axonal_neuron{ii}.ts_pos=[axonal_neuron{ii}.ts_pos allevents.ts_pos(spikes_ind)];
            axonal_neuron{ii}.trace=[axonal_neuron{ii}.trace allevents.trace(:,spikes_ind)];
            
            % make sure how to add finfo & f_idx
            if ~isempty(spikes_ind)
                file_index=length(axonal_neuron{ii}.fname)+1;
                axonal_neuron{ii}.fname{file_index}=ntk2.fname;
                axonal_neuron{ii}.finfo{file_index}.timestamp=ntk2.timestamp;
                axonal_neuron{ii}.finfo{file_index}.first_frame_no=ntk2.frame_no(1);
                axonal_neuron{ii}.finfo{file_index}.last_frame_no=ntk2.frame_no(end);
                axonal_neuron{ii}.ts_fidx=[axonal_neuron{ii}.ts_fidx file_index*ones(size(spikes_ind))];
            end
        end
        
    end
    
end

%% SAVE!!
save axonal_els.mat  axonal_neuron

% save computed_results/axonal_els axonal_neuron axonal_els_elidx
% load computed_results/axonal_els

%% here I should add an aditional clustering step!


%% define event_params

event_param.pre2=20;
event_param.post2=200;   % particularly large post2!

event_param.tlen2=event_param.pre2+event_param.post2;
event_param.pre1=floor(event_param.pre2*3/4);
event_param.post1=floor(event_param.post2*2/3);
event_param.tlen1=event_param.pre1+event_param.post1;

event_param.margin=20;
% event_param.t_min_isi=30;
% event_param.realign_pre=8;
% event_param.realign_post=8; %2;
% event_param.cut_tshift=4;

for i=1:length(axonal_neuron)
    axonal_neuron{i}.event_param=event_param;
end


%% re_extract traces
%%

out1=hidens_extract_traces(axonal_neuron,'chunk', 5000000)



%%
figure;plot_neurons(out1,'noels','notext')
pkpk=max(out1{1}.template.data)-min(out1{1}.template.data);
figure;plot(pkpk)
figure;plot_values_on_els(out1{1},pkpk)

%%
out1 = out1realign;
figure;plot_neurons(out1,'noels','notext')
pkpk=max(out1{1}.template.data)-min(out1{1}.template.data);
figure;plot(pkpk)
figure;plot_values_on_els(out1{1},pkpk)
%%


out2=trim_electrodes(out1{1},'xlim',[590 650],'ylim',[800 900])
figure;plot_neurons(out2,'noels','notext','dotraces_gray')

out3=trim_electrodes(out1{1},'xlim',[1030 1100],'ylim',[430 510])
figure;plot_neurons(out3,'noels','notext','dotraces_gray')

out4=trim_electrodes(out1{1}, 'include', electrodeToThreshold)
[clustered T]=pca_cluster_neuron(out4,'active_only','best_n',1,'do_plot')
out_clean=remove_bad_ts(out1{1},find(T==1))

figure;plot_neurons(out_clean,'noels','notext')
pkpk=max(out_clean.template.data)-min(out_clean.template.data);
figure;plot(pkpk)
figure;plot_values_on_els(out1{1},pkpk)


% save computed_results/axons_1_6 out1
% clear out1
% out2=hidens_extract_traces(axonal_neuron(7:12),'chunk', 5000000)
% save computed_results/axons_7_12 out2
% clear out2
% out3=hidens_extract_traces(axonal_neuron(13:18),'chunk', 5000000)
% save computed_results/axons_13_18 out3
% clear out3


%% visualize
% out2=recalc_active_els(out)
%%
figure('position',[100 200 1000 1000]);
% open template_plotter
for i=1:length(out1)
    clf
    plot_neurons(out1{i},'noels')
    title(['Neuron ' int2str(i)])
    %     xlim([0 800])
    %     ylim([0 800])
    pause
end

%%
load computed_results/axon_neurs_1_10.mat
els=select_electrodes_in_range(230,300,100,150)
N2=trim_electrodes(out1{2},'include',els.el_idx)
figure;
plot_neurons(N2,'noels','dotraces_gray')


%%
plot_neurons(out2,'neurons',10,'separate_subplots','nopos','notext')



%% OLD

%% define event_params

event_param.pre2=10;
event_param.post2=30;   % particularly large post2!

event_param.tlen2=event_param.pre2+event_param.post2;
event_param.pre1=floor(event_param.pre2*3/4);
event_param.post1=floor(event_param.post2*2/3);
event_param.tlen1=event_param.pre1+event_param.post1;

event_param.margin=20;
event_param.t_min_isi=30;
event_param.realign_pre=8;
event_param.realign_post=8; %2;
event_param.cut_tshift=4;

%%


thr_f=4.5;
% thr_f=7;

[demixed_events nr]=event_cut(ntk2, thr_f, event_param,'do_plot');
demixed_events2=event_align(demixed_events, event_param,'method','corr');  %realign events

figure;plot(demixed_events.trace)


%% store definite struct



def_neur{1}.ts=[def_neur{1}.ts demixed_events2.ts];
def_neur{1}.ts_pos=[def_neur{1}.ts_pos demixed_events2.ts_pos];
def_neur{1}.ts_fidx=[def_neur{1}.ts_fidx fl_ind*ones(size(demixed_events2.ts))];
def_neur{1}.fname{fl_ind}=ntk2.fname;
% def_neur{1}.finfo{fl_ind}=ntk2.fname;

def_neur{1}.finfo{fl_ind}.first_frame_no=ntk2.frame_no(1);
def_neur{1}.finfo{1}.last_frame_no=ntk2.frame_no(end);

def_neur{1}.finfo{1}.timestamp=ntk2.timestamp;


end

%%
def_neur{1}.event_param=event_param;
new_neur=hidens_extract_traces(def_neur)



%%






%%

PCA_sorter(ntk2, 1, 5, 30, 30, 1)