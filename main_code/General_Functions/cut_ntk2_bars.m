function y=cut_ntk2_bars(ntk2,siz)

% FIND WHEN LIGHT THE STIMULUS START AND WHEN IT FINISHES
bar=ntk2.images.frameno;
bar(length(bar):siz)=max(bar);
[b, m, n] = unique(bar,'first');

ind1=[];
for i=1:length(b);
    a=find(bar==b(i));
    if length(a)>10000;
       mov_bar=bar(a(10)); 
       ind1=[ind1 mov_bar];
    end
end

idx=[];
for i=1:length(ind1)
    ind2=find(bar==ind1(i));
    a=min(ind2);
    b=max(ind2);
    c=[a,b];
    idx=[idx c];
end
idx(2:17)=idx(2:17)+860 % 860 frames, projector delay
% parpin is ~45 ms before the real imaged is shown  45ms=860frames
% from ms to frames 25ms/0.05us  from frames to ms 500frames/20000sr*1000

% DEIFNE IDX TO CUT NTK2
orig_idx=idx;
on=2:2:16;
off=3:2:17;
%idx_d=[idx(off)-idx(on)];
idx(on)=idx(on)-20000;
idx(off)=idx(off)+20000;
idx_diff(1)=1;
idx_diff(2:9)=[idx(off)-idx(on)];
idx_diff=cumsum(idx_diff);
idx_d=[idx(off)-idx(on)];

if idx(17)>siz
idx(17)=siz-1;
end


%CUT TEMP
temp=ntk2.temp;
ntk2.temp=[];
for i=1:length(on)
ntk2.temp=[ntk2.temp; temp((idx(on(i)):idx(off(i))))];
end

% CUT DC
dc=ntk2.dc;
ntk2.dc=[];
for i=1:length(on)
ntk2.dc=[ntk2.dc; dc((idx(on(i)):idx(off(i))))];
end

%frame_no=ntk2.frame_no;
%ntk2.frame_no=[];
%for i=1:length(on)
%ntk2.frame_no=[ntk2.frame_no frame_no((idx(on(i)):idx(off(i))))];
%end

%CUT NTK.SIG WHEN LIGHT IS ON/OFF
sig=ntk2.sig;
ntk2.sig=[];
for i=1:length(on)
ntk2.sig=[ntk2.sig; sig((idx(on(i)):idx(off(i))),:)];
end

%FRAME NUMBER CHENGED FROM 1:LENGTH CUT SIG
ntk2.frame_no=[];
ntk2.frame_no=[1:length(ntk2.sig)];
ntk2;
sum(idx_d)


ntk2.idx_diff=idx_diff; %idx_light_after_cutting (1s before and after the stimulus)
ntk2.idx_d=idx_d; %idx_light_interval (1s before and after the stimulus)
ntk2.orig_idx=orig_idx; %original_light_ts
ntk2.on=on; %idx_light_on
ntk2.off=off; %idx_light_off


y=ntk2;


