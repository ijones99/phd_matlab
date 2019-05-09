currDir = '/home/ijones/data_curr/analysed_data/T13_14_30_2_plus_others_2/01_Pre_Spikesorting';
fileCounter = [];

for i=1:length(elsInPatch)
    fileName = dir(fullfile(currDir,(strcat('*',num2str(elsInPatch{i}(1) ),'*mat'))));
    if size(fileName,1)==0
        
        fileCounter(end+1)=i;
    end
end
fileCounter