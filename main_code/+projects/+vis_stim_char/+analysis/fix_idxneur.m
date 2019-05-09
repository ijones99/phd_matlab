

if ~exist('idxNeur_orig.mat', 'file')
    !cp idxNeur.mat idxNeur_orig.mat
end

load idxToMerge;
idxNeur.merge = idxToMerge;
idxNeur.final_selection = [idxToMerge num2cell(idxNeur.not_duplicated')'];


idxFinalSel = [];
fieldNames = {'incomplete' 'keep' 'many_violations' 'strange'  'very_clean'}

for iFld = 1:length(fieldNames)
    eval(sprintf('idxFinalSel.%s = idxNeur.%s', fieldNames{iFld}, fieldNames{iFld}));
    idxNeur = rmfield(idxNeur, fieldNames{iFld});
end

%

idxFinalSel.readme = 'Indices for idxNeur.final_selection, which is the index for clusNum';


save('idxNeur.mat', 'idxNeur');
save('idxFinalSel.mat', 'idxFinalSel');




