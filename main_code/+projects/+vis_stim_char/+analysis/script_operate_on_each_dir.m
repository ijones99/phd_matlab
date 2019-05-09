% load data directories
dirName = projects.vis_stim_char.analysis.load_dir_names;
% for iDir = 1:length(dirName.dataDirLong)
%      !rm ../analysed_data/profiles/*merg*
% end

for iDir = 1:length(dirName.dataDirLong) % loop through directories
    
    clearvars -except iDir dirName
    
    cd([dirName.dataDirLong{iDir},'Matlab/']); % enter directory
    clearvars -except dirName iDir param_BiasIndex % clear vars
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
    save idxFinalSel.mat idxFinalSel
    
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
        
        for j=1:length(currIdx)
            % load data from each neuron to be mergeds
            filenameProf = sprintf('clus_%05.0f', clusNum(currIdx(j)));
            load(fullfile(dirNameProf, filenameProf))
            % cycle through each stimulus
            if length(currIdx) == 1
                neurM = neur;
            else
                for k=selIdxNeur
                    currNeur(k).clus(end+1) = neur(k).clus;
                    if ~isempty(neur(k).ts )
                        currNeur(k).ts = sort([currNeur(k).ts neur(k).ts ]);
                        
                        if isfield( currNeur(k),'footprint')
                            if isempty(currNeur(k).footprint)
                                currNeur(k).footprint = neur(k).footprint;
                            end
                        else
                            currNeur(k).footprint = neur(k).footprint;
                        end
                    end
                end
                neurM = currNeur;
            end
        end
        
        filenameProf = sprintf('clus_merg_%05.0f',clusNumsM(i));
        if ~exist(dirNameProf,'file')
            mkdir(dirNameProf)
        end
        save(fullfile(dirNameProf, filenameProf),'neurM')
        progress_info(i, length(clusNumsM))
    end
    progress_info(iDir,length(dirName.dataDirLong),'batch mode: ')
end
