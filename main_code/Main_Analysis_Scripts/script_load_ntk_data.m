    
flist = {};
%flist{end+1} = 'Trace_id1035_2013-06-14T16_44_46_3.stream.ntk';
%flist{end+1} = 'Trace_id1035_2013-06-14T16_44_46_1.stream.ntk'; 
% flist_ds_cell_search_001;
flist{end+1} = '../proc/Trace_id65535_2014-03-19T10_48_29_0.stream.ntk'; 
%%
chunkSize = 2e4%*20%0000*3000%2e4*60*4;
ntk=initialize_ntkstruct(flist{1},'hpf', 500, 'lpf', 3000);
% ntk=initialize_ntkstruct(flist{1} );

%%
[ntk2 ntk]=ntk_load(ntk, chunkSize, 'images_v1', 'digibits');
% [ntk2 ntk]=ntk_load(ntk, chunkSize, 'images_v1', 'digibits','keep_only', 1);
%% plot data
figure, hold on
x = [1/20:1/20:length(ntk2.sig(:,18))/20];
plot(x,ntk2.sig(:,18));
% plot((ntk2.dac1-512)*5+100,'-c'); hold on
% plot((ntk2.dac2-512)*5+100,'-k','Color', [0.4 0.4 0.4]);

%% plot light timestamps
imageFrames = ntk2.images.frameno;
figure
plot((imageFrames))
%%
dataStream = ntk2.dac1;
figure, 
plot((1:length(dataStream))/(2e4),dataStream)
% hold on
% plot((1:length(dataStream))/(2e4),ntk2.sig')

