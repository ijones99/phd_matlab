function get_electrode_list(directoryName)
% function get_electrode_list(directoryName,flistName)
%
initDir = pwd;

eval(strcat(['cd ',directoryName]));

%load flist
flist={};
flist_for_analysis

ntk=initialize_ntkstruct(flist,'hpf', 500, 'lpf', 3000);
[ntk2 ntk]=ntk_load(ntk, 200);

[B XI]=sort(ntk2.el_idx);
ch_idx=XI;

% hack, with this function "reextract_aligned_traces" crashes...to be fixed
ntk2.frame_no=[];
ntk2.frame_no=[1:length(ntk2.sig)];

% FIND ELECTRODES
% here we compute the matrix with the n closest electrodes for every electrode in the list

x = ntk2.x(XI);
y = ntk2.y(XI);
xx=ntk2.x(XI);
yy=ntk2.y(XI);
electrodes=B;

min_dist =[+Inf];
number_els = 4;
close_electrodes=[];
electrode_list=zeros(length(ntk2.x),number_els+1);

for i=1:length(ntk2.x)
    p1 = 1;
    for p2 = 2:length(ntk2.x)
        d = sqrt((x(p1)-x(p2))^2+(y(p1)-y(p2))^2);
        min_dist = [min_dist d];
     end

close_electrodes=[electrodes(p1)];

for j=1:number_els
    [val ind]=min(min_dist);
    close_electrodes=[close_electrodes   electrodes(ind)];
    min_dist(ind)=+Inf;
end

electrode_list(i,:)=close_electrodes;
close_electrodes=[];
min_dist=[];
min_dist =[+Inf];
x=xx([ i+1:end 1:i ]);
y=yy([ i+1:end 1:i ]);
electrodes=B([ i+1:end 1:i ]);
end

save electrode_list electrode_list

eval([strcat(['cd ',initDir])]);


end