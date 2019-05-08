%% compute parameters
pathDef = dirdefs();%expName = '17Jun2014';
dirSettings = 'settings/'

runNo = 1;
% % init
doInitParaOut = input('init paraOut?','s' );
if doInitParaOut == 'y'
    paraOutputMat = [];
    paraOutputMat.headings = {};
    paraOutputMat.neur_names = {};
    paraOutputMat.params = zeros(1,5);
end
doSetHeadings = 1;
doDebug = 0;

dirNames = filenames.get_dirnames(fullfile(pathDef.neuronsSaved));

numFiles = 0;
for iDir = 1:length(dirNames)
    expName = dirNames{iDir};
    fileNames = filenames.get_filenames('*.mat', fullfile(pathDef.neuronsSaved,expName));
    numFiles = length(fileNames)+numFiles;
end

fileCtr = 0;
for iDir = 1:length(dirNames)
    expName = dirNames{iDir};
    fileNames = filenames.get_filenames('*.mat', fullfile(pathDef.neuronsSaved,expName));
    for i=1:length(fileNames)
        try
            clear neur
            load(fullfile(pathDef.neuronsSaved,expName,fileNames(i).name));
            
            if doSetHeadings && i==1
                fieldNames = fields(neur.paramOut);
                paraOutputMat.headings = fieldNames;
            end
            
            % save data to matrix for excel
            paraOutputMat.neur_names{end+1,1} = fullfile(expName,fileNames(i).name);
            fieldNames = fields(neur.paramOut);
            paramData = [];
            idx = length(paraOutputMat.neur_names);
            for j = 1:length(fieldNames)
                paraOutputMat.params(idx,j) = getfield(neur.paramOut,fieldNames{j});
            end

%             progress_info(  fileCtr,numFiles);
            texts.print_dots(100*fileCtr/numFiles,20);
            fileCtr = fileCtr+1;
            close all
        catch
            
        end
    end
end
fileNameOut = sprintf('paraOutputMat_%s.mat', strrep(num2str(datenum(now)),'.','_'));
save(fullfile(pathDef.neuronsSaved,fileNameOut),'paraOutputMat');
% save('paraOutputMat','paraOutputMat');
%