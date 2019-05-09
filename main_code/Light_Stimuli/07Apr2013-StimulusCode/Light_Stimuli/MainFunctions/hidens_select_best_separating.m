%all combinations
comb=nchoosek(n_list,2);
allcomb=[floor((0:(length(n_list)^2-1))/length(n_list))'  mod(0:(length(n_list)^2-1),length(n_list))']+1;


%play around with mahal
%plot separation of first neurons to the others
%mdist_v1n=zeros(length(nnn.el_idx{1}),3);

norm_noise=sqrt(mean(cell2mat(nnn.thr_base)).^2*tl);
norm_norm=zeros(tc,length(comb)); %normalized euclidian distance for each pair
scaled_norm_norm=zeros(tc,length(comb)); %normalized euclidian distance for each pair where singals are scaled to suppress amplitude effects
%FIXME: event. take 1 (instead of 0) for not defined channels
for n=1:length(comb)
%         %S=cov([nnn.neurons{n}.trace{c}]');
%         %Sinv=inv(S);
%         %mdist_v1n(c,n-1)=sqrt((nnn.neurons{1}.template(:,c)'-nnn.neurons{n}.template(:,c)')*Sinv*(nnn.neurons{1}.template(:,c)'-nnn.neurons{n}.template(:,c)')');
    def_n1=zeros(1,tc);
    def_n2=zeros(1,tc);
    def_n1(els_idx_i{comb(n,1)})=1;
    def_n2(els_idx_i{comb(n,2)})=1;
    
    for c=1:tc
        if def_n1(c) && def_n2(c)
            norm_norm(c,n)=norm(templates(:,c,comb(n,1))-templates(:,c,comb(n,2)))/norm_noise;
            scaled_norm_norm(c,n)=norm(templates(:,c,comb(n,1))/max(templates(:,c,comb(n,1)))-templates(:,c,comb(n,2))/max(templates(:,c,comb(n,2))))/norm_noise;
         elseif def_n1(c)
             norm_norm(c,n)=abs(max([norm(templates(:,c,comb(n,1))) norm_noise])-norm_noise)/norm_noise;
         elseif def_n2(c)
             norm_norm(c,n)=abs(max([norm(templates(:,c,comb(n,2))) norm_noise])-norm_noise)/norm_noise;
        end
    end
end

responce_diff=zeros(tc,length(allcomb));
for n=1:size(allcomb,1)
    for c=1:tc
        %FIXME: take cross talk filters into account
        responce_diff(c,n)=peak_resp(c,allcomb(n,1),allcomb(n,1))-peak_resp(c,allcomb(n,2),allcomb(n,1));
    end
end

%what about using pca to find els with large seperability?



%noramlize distance measures so that the best per electrode gain is 1
norm_norm=norm_norm/max(norm_norm(:));
responce_diff=responce_diff/max(responce_diff(:));
scaled_norm_norm=scaled_norm_norm/max(scaled_norm_norm(:));

% select electrodes only based on template distances
%
% select electrodes stepwise, could redo the optimization later
% in every step, select the electrode that increases seperatability most

% some parameters:
monitor_n_list=[1 2 3 4];          %monitor these neurons, i.e. build filteer banks for these
%include_electrodes=el_idx_any;   %allowed electrodes - all
include_electrodes=nnn.el_idx{1};   %allowed electrodes
desired_distance=2.5;                %max gain is 1 on the best electrode 
maximum_electrodes=35;
minumum_electrodes=length(monitor_n_list);

[include_electrodes_idx sj]=find(include_electrodes(ones(1,length(el_idx_any)),:)==el_idx_any(ones(1,length(include_electrodes)),:)');

%function used in sum that is maximized
opti_mf=@(x) sigmf(x,[desired_distance/5 desired_distance])+1-exp(-x/desired_distance);

used_distances_comb=zeros(1,length(comb));
for i=monitor_n_list
    [fi fj]=find(comb==i);
    used_distances_comb(fi)=1;
end

used_distances_resp=zeros(1,length(allcomb));
for i=monitor_n_list
    [fi fj]=find(allcomb==i);
    used_distances_resp(fi)=1;
end
for i=1:length(used_distances_resp)
    if allcomb(i,1)==allcomb(i,2)
        used_distances_resp(i)=0;
    end
end

%which measures to use:
%measure=norm_norm;
%measure=responce_diff;
measure=0.3*scaled_norm_norm + 0.7*norm_norm;

used_distances=used_distances_comb;
%used_distances=used_distances_resp;

%sum that we maximize
%FIXME: using norm now, however could also use more shape based measure,
%i.e. differences in filter responce
opti_sum=@(x) sum(opti_mf(sum(measure(x,used_distances==1))));

%electrodes selected
ch_list=[];
done=0;
while not(done)
    ncost=zeros(1,length(include_electrodes_idx));
    for c=1:length(include_electrodes_idx)
        new_chlist=[ch_list include_electrodes_idx(c)];
        ncost(c)=opti_sum(new_chlist);
    end
    [v idx]=max(ncost);
    ch_list=[ch_list include_electrodes_idx(idx)];
    fprintf('added electrode %d, optisum is %.3f\n', include_electrodes(idx), v);
    include_electrodes_idx(idx)=[];
    include_electrodes(idx)=[];
    disp(sum(measure(ch_list,used_distances==1)))
    
    if length(ch_list)>=maximum_electrodes
        done=1;
    end
    
end

return


% from here on its just plotting and the actual filtering


gridspace_um=5;
xlin=linspace(xmin,xmax,(xmax-xmin)/gridspace_um);
ylin=linspace(ymin,ymax,(ymax-ymin)/gridspace_um);
[XI,YI] = meshgrid(xlin,ylin);

for i=1:length(comb)
     figure
    ZI = griddata(el_idx_x,el_idx_y,measure(:,i),XI,YI);
    imagesc(xlin,ylin,ZI); 
    axis ij
    axis equal
    hold on;
    plot(el_idx_x,el_idx_y,'ro');
    plot(el_idx_x(ch_list),el_idx_y(ch_list),'gx');
    title([num2str(comb(i,1)) '/' num2str(comb(i,2))])
end

%ch_list=ch_list(1:6);

selected_els=el_idx_any(ch_list);

%filter signals
[selected_els_idx sj]=find(selected_els(ones(1,length(ntk2.el_idx)),:)==ntk2.el_idx(ones(1,length(selected_els)),:)');
filtered_ntk=zeros([size(ntk2.sig,1) length(selected_els_idx) length(n_list)]);

for e=1:length(selected_els_idx)
    %figure
    for n=1:length(n_list)
        filtered_ntk(:,e,n)=filter(templates(end:-1:1,ch_list(e),n),1,ntk2.sig(:,selected_els_idx(e)));
        %subplot(length(n_list),1,n)
        %plot(filtered_ntk(:,e,n))
        %title(['neuron ' num2str(n_list(n)) ', electrode ' num2str(selected_els(e))])
    end
end





nmixedsig=awgn(reshape(appened_templates([1:end 1:end 1:end 1:end 1:end 1:end 1:end 1:end 1:end 1:end],ch_list,:),10*al,[]),4,'measured')';
[A,W] = fastica(nmixedsig, 'numOfIC', 4, 'g', 'pow3', 'stabilization', 'on');
plot((W*nmixedsig)')

%event reshuffle W

mixedsig=reshape(filtered_ntk(:,:,:),size(filtered_ntk,1),[])';
icaout=(W*mixedsig)';
plot(icaout(:,1))


%
to_plot=[1 2 3 4];
sel_neurons=[1 2 3 4];

x.sig=icaout(:,to_plot);
x.thr_base=ones(1,size(x.sig,2));
x.thr_base(3)=1.4;
y=simple_event_cut(x, 4, 10, 20);
[val shift]=max(y.trace);
y.ts_max=y.ts+shift-1;



lcolor=lines(length(nnn.neurons));


figure
hold on
offset=10;

for i=1:length(sel_neurons)
    plot((0:(size(icaout,1)-1))/ntk2.sr, icaout(:,to_plot(i))+offset*(i-1),'k')
    plot(y.ts_max(find(y.ch==i))/ntk2.sr, icaout(y.ts_max(find(y.ch==i)),to_plot(i))+offset*(i-1), 'v', 'Color', lcolor(sel_neurons(i),:));
end



%%plotting all
subplot(2,3,[1 4])
hold on
for j=1:60
    plot(ntk2.x(j), ntk2.y(j),  '.', 'Color', [0.7 0.7 0.7]);
    text(ntk2.x(j),ntk2.y(j),num2str(j), 'HorizontalAlignment', 'Left', 'VerticalAlignment', 'Bottom', 'FontSize', 6, 'Color', [0.7 0.7 0.7]);
end
axis equal
axis ij
plot(el_idx_x(ch_list), el_idx_y(ch_list), 'ko');
lcolor=lines(length(nnn.neurons));

c=[55 43 57 22];
i=1; plot(ntk2.x(c(i)), ntk2.y(c(i)), '.', 'Color', lcolor(sel_neurons(i),:));
i=2; plot(ntk2.x(c(i)), ntk2.y(c(i)), '.', 'Color', lcolor(sel_neurons(i),:));
i=3; plot(ntk2.x(c(i)), ntk2.y(c(i)), '.', 'Color', lcolor(sel_neurons(i),:));

subplot(2,3,[2 3])
hold on
offset=250;
for i=1:length(c)
    plot((0:(size(ntk2.sig,1)-1))/ntk2.sr, ntk2.sig(:,c(i))+offset*(i-1),'k')
    for n=1:length(sel_neurons)
        [v vminpos]=min(nnn.neurons{sel_neurons(n)}.template(:,c(i)));
        plot((nnn.neurons{sel_neurons(n)}.ts{1}(find(nnn.neurons{sel_neurons(n)}.ts{1}<size(ntk2.sig,1)))+vminpos-1)/ntk2.sr, ntk2.sig(nnn.neurons{sel_neurons(n)}.ts{1}(find(nnn.neurons{sel_neurons(n)}.ts{1}<size(ntk2.sig,1)))+vminpos-1,c(i))+offset*(i-1), '^', 'Color', lcolor(sel_neurons(n),:))
        plot((y.ts_max(find(y.ch==n))-tl/2)/ntk2.sr, ntk2.sig(y.ts_max(find(y.ch==n))-tl/2,c(i))+offset*(i-1), '.', 'Color', lcolor(sel_neurons(n),:));
    end
end


x.sig=icaout(:,to_plot);
x.thr_base=ones(1,size(x.sig,2));
y=simple_event_cut(x, 4, 10, 20);
[val shift]=max(y.trace);
y.ts_max=y.ts+shift'-1;
lcolor=lines(length(nnn.neurons));

subplot(2,3,[5 6])
hold on
offset=10;
for i=1:length(sel_neurons)
    plot((0:(size(icaout,1)-1))/ntk2.sr, icaout(:,to_plot(i))+offset*(i-1),'k')
    plot(y.ts_max(find(y.ch==i))/ntk2.sr, icaout(y.ts_max(find(y.ch==i)),to_plot(i))+offset*(i-1), 'v', 'Color', lcolor(sel_neurons(i),:));
end




% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % here I tried with building a per neuron ranking and the an iterative
% % select, ica for W, evaluate...
% %from the derived separation distance, get ranking of electrodes
% additive_sep_norm=zeros(1,length(nnn.el_idx{1}));
% for i=1:3
%     additive_sep_norm=additive_sep_norm+norm_norm(:,i)'/max(norm_norm(:,i));
% end
% additive_sep_norm=additive_sep_norm/3;
% 
% [b c_idx]=sort(additive_sep_norm);
% %limit to topmost x electrodes
% top_x=min([30 length(nnn.el_idx{1})]);
% presel=c_idx(end:-1:end-top_x+1);
% 
% %now, run the electrode sel algo interativly to build electrode importance
% %list
% nr_of_electrodes=6;
% ch_list=[];
% for i=1:nr_of_electrodes
%     %estimate for every cahnnel how much it is going to improve the
%     %filterbank
%     performace=zeros(1, length(presel));
%     found_one=0;
%     for c=1:length(presel)
%         if presel(c)>=0
%             new_channel_list=[ch_list presel(c)];
%             mixedsig=filtered_templates(:,new_channel_list)';
%             W=ica_select_first(mixedsig, 4, pl);
%             if not(isempty(W))
%                 filter_bank_out=(W*mixedsig)';
%                 %figure
%                 %plot(filter_bank_out)
% 
%                 %estimate performace
%                 maxin=max(filter_bank_out(1:pl));
%                 maxout=max(filter_bank_out(pl+1:end));
%                 maxrel=maxin/maxout;
%                 %title(['performance: ' num2str(maxrel)])
%                 performace(c)=maxrel;
%                 found_one=1;
%             else
%                 performace(c)=0;
%             end
%             %input('continue')
%         end
%     end
%     if found_one
%         [maxp maxpidx]=max(performace);
%         ch_list=[ch_list presel(maxpidx)];
%         fprintf('adding channel %d to the list (performance: %f\n', presel(maxpidx), maxp);
%         presel(maxpidx)=-1;
%     end
% end
% 



















