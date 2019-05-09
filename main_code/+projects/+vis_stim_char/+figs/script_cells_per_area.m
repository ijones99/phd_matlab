dirNames = projects.vis_stim_char.analysis.load_dir_names;
% plot # spikes per stim
% stim change timestamps
load stimChangeTsAll

% file info
dirNameProf = '../analysed_data/profiles/';
fileNamesProf = filenames.list_file_names('clus*merg*.mat',dirNameProf);

load(fullfile(dirNameProf, fileNamesProf(1).name));
  
xSpc = mode(diff(unique(neurM(1).footprint.x)));
ySpc = mode(diff(unique(neurM(1).footprint.y)));

l = mean([xSpc ySpc*2])/2;

areaOut= geometry.area.hex(l/1000);
totalArea = length(neurM(1).footprint.x)*areaOut;

for iDir =1:length(dirNames.dataDirLong) % loop through directories
    cd([dirNames.dataDirLong{iDir},'Matlab/']); % enter directory
    dirNameProf = '../analysed_data/profiles/';
    fileNamesProf = filenames.list_file_names('clus*merg*.mat',dirNameProf);
    cellCnt(iDir) = length(fileNamesProf);
    
end

% plot cell density
cellDensity = cellCnt/totalArea;
figure, bar(cellDensity,'EdgeColor','w','LineWidth',2,'FaceColor',[1 1 1]*0.5)

title('RGC Density')
xlabel('Experiment Number')
ylabel('Density (cells/mm^2)')

figs.format_for_pub( 'journal_name','frontiers')
dirName = dirNames.common.figs;
fileName = 'RGC_Density';
xlim([0 8])
figs.save_for_pub(fullfile(dirName,fileName))

% plot cell number
figure, bar(cellCnt,'EdgeColor','w','LineWidth',2,'FaceColor',[1 1 1]*0.5)

title('RGC Count')
xlabel('Experiment Number')
ylabel('cells')

figs.format_for_pub( 'journal_name','frontiers')
dirName = dirNames.common.figs;
fileName = 'RGC_Cell_Count';
xlim([0 8])
figs.save_for_pub(fullfile(dirName,fileName))

