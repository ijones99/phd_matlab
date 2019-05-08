function paraOutputMat = create_paraoutput_struct(...
    fileList, fileListIdx)

% paraOutputMat = CREATE_PARAOUTPUT_STRUCT(...
%     fileList, fileListIdx)

fileListIdx = analysis.visual_stim.get_filelist_idx_approved(fileList);

def = dirdefs();

paraOutputMat = {};
paraOutputMat.headings  = {};

for iIdx = 1:length(fileListIdx)
    paraOutputMat.neur_names{iIdx } = sprintf('%s/%s', fileList{fileListIdx(iIdx),1},...
        fileList{fileListIdx(iIdx),2});
    
    load(fullfile(def.neuronsSaved, paraOutputMat.neur_names{iIdx }  ));
    
    if iIdx==1
            paraOutputMat.headings = fields(neur.paramOut)';
    end
    
    for j=1:length(paraOutputMat.headings)
        paraOutputMat.params(iIdx,j ) = getfield(neur.paramOut,paraOutputMat.headings{j});
    end
end
paraOutputMat.neur_names = paraOutputMat.neur_names';

end