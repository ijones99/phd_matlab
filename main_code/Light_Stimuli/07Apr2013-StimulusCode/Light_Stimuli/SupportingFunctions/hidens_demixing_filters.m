

%build  Matched Filter Receiver Bank
n_list=1:10;   %valid neurons, separate against those


for i=n_list
    nnn.neurons{i}.template=get_template(nnn.neurons{i}, nnn.neurons{i}.event_param.pre2, nnn.neurons{i}.event_param.post2);
end


[mindist xmin ymin xmax ymax pkpkmax maxidx]=get_plot_param(nnn.neurons, n_list);

el_idx_x=zeros(1,maxidx);
el_idx_y=zeros(1,maxidx);
el_idx_any=zeros(1,maxidx);
for i=n_list
    el_idx_any(nnn.neurons{i}.el_idx)=1;
    el_idx_x(nnn.neurons{i}.el_idx)=nnn.neurons{i}.x;
    el_idx_y(nnn.neurons{i}.el_idx)=nnn.neurons{i}.y;
end

el_idx_any=find(el_idx_any>0);
el_idx_x=el_idx_x(el_idx_any);
el_idx_y=el_idx_y(el_idx_any);

tl=size(nnn.neurons{n_list(1)}.template.data,1);  %template length
pl=2*tl;  %padded template length
al=length(n_list)*pl;    %appended templates length
tc=length(el_idx_any);    %total channels

%get indices for each neuron
els_idx_i=cell(0,0);
for i=1:length(n_list)
    [els_idx_i{i} sj]=find(nnn.neurons{n_list(i)}.el_idx(ones(1,length(el_idx_any)),:)==el_idx_any(ones(1,size(nnn.neurons{n_list(i)}.el_idx,2)),:)');
    %[bbb sidx]=sort(si); els_idx_i{i}=els_idx_i{i}(sidx);
end

%build appended templates & remove DC from templates
appened_templates=zeros([al tc length(n_list)]);
%appened_templates_pern=zeros(tc.*tl,length(n_list));
templates=zeros([ tl tc length(n_list)]);
m_norm=0;
m_norm_cnt=0;
for i=1:length(n_list)
    templates(:,els_idx_i{i},i)=nnn.neurons{n_list(i)}.template.data-ones(tl,1)*mean(nnn.neurons{n_list(i)}.template.data);
    for n=1:length(n_list)
        appened_templates((1:tl)+(i-1)*pl,els_idx_i{i},n)=templates(:,els_idx_i{i},i);
    end
    %appened_templates_pern(:,i)=reshape(appened_templates((1:tl)+(i-1)*pl+(pl-tl)/2,:),1,[]);
    for c=1:length(els_idx_i{i})
        m_norm=m_norm+norm(templates(:,els_idx_i{i}(c)),i);
        m_norm_cnt=m_norm_cnt+1;
    end
end
m_norm=m_norm/m_norm_cnt;

%construct overlap test signal
% shift=-tl/2:2:tl/2;
% nr_s=length(shift);
% n_ts=zeros(nr_s*pl*(length(n_list)-1)*length(n_list)/2,length(n_list));
% ol_testsig=zeros(nr_s*pl*(length(n_list)-1)*length(n_list)/2,tc);
% pos_n=0;
% for i=1:length(n_list)
%     for j=(i+1):length(n_list)
%         for s=1:nr_s
%             n_ts((1:tl)+(pos_n)*pl+(pl-tl)/2,i)=1;
%             n_ts((1:tl)+(pos_n)*pl+(pl-tl)/2+shift(s),j)=1;
%             ol_testsig((1:tl)+(pos_n)*pl+(pl-tl)/2,els_idx_i{i})=ol_testsig((1:tl)+(pos_n)*pl+(pl-tl)/2,els_idx_i{i})+nnn.neurons{n_list(i)}.template;
%             ol_testsig((1:tl)+(pos_n)*pl+(pl-tl)/2+shift(s),els_idx_i{j})=ol_testsig((1:tl)+(pos_n)*pl+(pl-tl)/2+shift(s),els_idx_i{j})+nnn.neurons{n_list(j)}.template;
%             pos_n=pos_n+1;
%         end
%     end
% end





%now, filter with templates, once for each neuron
filtered_templates=zeros([pl tc length(n_list) length(n_list)]);
peak_resp=zeros([tc length(n_list) length(n_list)]);
for i=1:length(n_list)
    for j=1:length(n_list)
        for c=1:tc
           filtered_templates(:,c,i,j)=filter(templates(end:-1:1,c,j),1,[templates(:,c,i) ;zeros(tl,1)]);
           peak_resp(c,i,j)=max(filtered_templates(:,c,i,j));
        end
    end
    for c=1:tc
        appened_templates(:,c,i)=filter(templates(end:-1:1,c,i),1,appened_templates(:,c,i));
    end
end

% maxout=zeros(tc,length(n_list)-1);
% maxout_n=zeros(tc,length(n_list)-1);
% for ti=1:length(n_list)-1
%     maxout(:,ti)=max(filtered_templates((1:tl)+ti*pl+(pl-tl)/2,:));
%     for c=1:length(els_idx_i{1})
%         norm(appened_templates((1:tl)+ti*pl+(pl-tl)/2,c))
%         maxout_n(c,ti)=maxout(c,ti)./max([norm(appened_templates((1:tl)+ti*pl+(pl-tl)/2,c)) m_norm]);
%     end
% end


%filtered_templates_pern=zeros(tc.*tl,length(n_list));
%for i=1:length(n_list)
%    filtered_templates_pern(:,i)=reshape(filtered_templates((1:tl)+(i-1)*pl+(pl-tl)/2,:),1,[]);
%end



%end


%%%filtering
 %r=normxcorr2_mex(nnn.neurons{1}.template(:,c)-mean(nnn.neurons{1}.template(:,c)), appened_templates(:,els_idx_i{1}(c)), 'same');
 %filtered_templates(:,c)=r;
 %r=xcorr(appened_templates(:,els_idx_i{1}(c)), nnn.neurons{1}.template(:,c)-mean(nnn.neurons{1}.template(:,c)));
 %filtered_templates(:,c)=r(((end/2+0.5):end)-tl/2);
 %r=xcorr(appened_templates(:,els_idx_i{1}(c)), nnn.neurons{1}.template(:,c)-mean(nnn.neurons{1}.template(:,c)));
 %filtered_templates(:,els_idx_i{i}(c),i)=filter(templates(end:-1:1,els_idx_i{i}(c),i),1,appened_templates(:,els_idx_i{i}(c)));
 %r=zeros(1,al);
 %for x=1:al-tl
 %    r(x+tl/2)=norm(appened_templates(x:(x+tl-1),els_idx_i{1}(c))-nnn.neurons{1}.template(:,c));
 %end
 %filtered_templates(:,c)=r;

 %filter overlap test
 %r=xcorr(ol_testsig(:,els_idx_i{1}(c)), nnn.neurons{1}.template(:,c)-mean(nnn.neurons{1}.template(:,c)));
 %oltest_filt(:,c)=r(((end/2+0.5):end)-tl/2);
















