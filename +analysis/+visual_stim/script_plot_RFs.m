

doDebug = 0;
prefDiam = [];
fittedDiam= [];
for i=16:length(fileNames)
 
        clear neur
        
        
        load(fullfile(pathDef.neuronsSaved,expName,fileNames(i).name));
        figure, imagesc(neur.info.staImAdj)
        neur.info.clusNum
        neur.spt
        num = input('sel_num>> ')
   
end