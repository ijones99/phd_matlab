dirNameProf = '../analysed_data/profiles/';
idxFP = 2;
selIdxNeur = 1:6;
clusNumsM = idxFinalSel.keep;
for i=1:length(clusNumsM)
    
    currIdx = idxNeur.final_selection{clusNumsM(i)};
    currNeur = [];
    for k=1:6
        currNeur(k).ts = [ ];
    end
    currNeur = struct([]);
    currNeur(6).clus = [];
    currNeur(6).ts = [];
    neurM = [];
    
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
