figure, hold on;
 m = [6274	32	1804
     ]

fileNameManual = sprintf('st_%dn%d',m(1),m(2));
fileNumF = m(3);

stFelix = [];
stManual = [];
% felix ts
for i = 1:length(tsMatrix_felix)
    if tsMatrix_felix{i}.clus_num == fileNumF
        stFelix = tsMatrix_felix{i}.ts;
    end
end


% manual ts
for j = 1:length(tsMatrix)
    if strcmp(tsMatrix{j}.name,fileNameManual)
        stManual = tsMatrix{j}.ts*2e4;
    end
end

fprintf('num spikes felix-%d vs manual-%d\n',length(stFelix),length(stManual))
plot(stFelix);
plot(stManual,'r');

titleName= sprintf('Spiketimes for Manual %s vs Auto Sorter %d',fileNameManual, fileNumF);
plotDir = '../Figs/';
fileName = strrep(strrep(titleName,' ','_'),'.','_');
save.save_plot_to_file(plotDir, fileName, 'eps');
save.save_plot_to_file(plotDir, fileName, 'fig');