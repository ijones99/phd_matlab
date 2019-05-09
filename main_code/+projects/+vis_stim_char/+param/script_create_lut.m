% load data directories
dirName = projects.vis_stim_char.analysis.load_dir_names;
iCount = 0;

lutDirFileNames = [];
iCnt = 1;
for iDir = 1:length(dirName.dataDirLong) % loop through directories
    
    
    cd([dirName.dataDirLong{iDir},'Matlab/']); % enter directory
   
    script_load_data; load idxNeur ; load idxToMerge.mat; load idxFinalSel% load data
    
    % !cp /home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/04Dec2014/Matlab/script_get_footprints_v2.m .
    
    % Save selected clusters
    dirNameProf = '../analysed_data/profiles/';
    idxFP = 2;
    
    clusNumsM = idxFinalSel.keep;
    idxFinalSel.stim_info.idx_R = [barsRIdx barsLengthTestRIdx ....
        barsSpeedTestRIdx driftingLinearPatternRIdx ...
        marchingSqrOverGridRIdx marchingSqrRIdx];
    idxFinalSel.stim_info.names =  ['barsRIdx' 'barsLengthTestRIdx' ...
        'barsSpeedTestRIdx' 'driftingLinearPatternRIdx'...
        'marchingSqrOverGridRIdx' 'marchingSqrRIdx'];
 
    
    numStim = length(idxFinalSel.stim_info.idx_R);
    numR = length(configs.flist);
    selIdxNeur = 1:numR;
    for i=1:length(clusNumsM)
        
        currIdx = idxNeur.final_selection{clusNumsM(i)};
        currNeur = [];
        currNeur(1).ts = [ ];
        
        currNeur = struct([]);
        currNeur(numR).clus = [];
        currNeur(numR).ts = [];
        neurM =  struct([]);
        
       
        filenameProf = sprintf('clus_merg_%05.0f',clusNumsM(i));
            
        
        lutDirFileNames.dirNo(iCnt) =  iDir ;
        lutDirFileNames.dirName{iCnt} =  [dirName.dataDirLong{iDir},'profiles/'];

        lutDirFileNames.fileName{iCnt} =filenameProf;
        
        progress_info(i, length(clusNumsM))
        iCnt=iCnt+1;
    end
    progress_info(iDir,length(dirName.dataDirLong),'batch mode: ')
   
end
