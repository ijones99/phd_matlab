%% compute parameters
load profDataRec
pathDef = dirdefs();%expName = '17Jun2014';
dirSettings = '../Matlab/settings/'
expName = get_dir_date
fileNames = filenames.get_filenames('*.mat', fullfile(pathDef.neuronsSaved,expName))
runNo = input('run no: ');
reviewMode = input('review? [1/0]');
% eval(sprintf('load wnCheckBrdPosData_%02.0f',runNo))
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

for i=1:length(fileNames)
    try
        clear neur
        
        load(fullfile(pathDef.neuronsSaved,expName,fileNames(i).name));
        
        % find xy location
        try
            neur.info.rfRelCtr = profDataRec{i}.rfRelCtrFit;
        catch
            neur.info.rfRelCtr = profDataRec{i}.rfRelCtr;
        end
        if ~doDebug
            spotsSettings = file.load_single_var(dirSettings, 'stimFrameInfo_spots.mat');
            barsSettings = file.load_single_var(dirSettings,...
                'stimFrameInfo_movingBar_2Reps.mat');
            neur = response_params_calc.compute_vis_stim_parameters2(neur,...
                spotsSettings, barsSettings,'save_plot','plot');%
            %set headings
            if i==1
                fieldNames = fields(neur.paramOut);
                paraOutputMat.headings = fieldNames;
            end
            save(fullfile(pathDef.neuronsSaved,expName,fileNames(i).name),'neur');
        end
        % save data to matrix for excel
        paraOutputMat.neur_names{end+1,1} = fullfile(expName,fileNames(i).name);
        fieldNames = fields(neur.paramOut);
        paramData = [];
        idx = length(paraOutputMat.neur_names);
        for j = 1:length(fieldNames)
            currField = getfield(neur.paramOut,fieldNames{j});
            if ischar(currField)
                if strcmp(currField,'on')
                paraOutputMat.params(idx,j) = 1;
                elseif strcmp(currField,'off')
                    paraOutputMat.params(idx,j) = 0;
                end
            end
        end
        if reviewMode
            junk = input('press enter');
        end
        save(fullfile(pathDef.neuronsSaved,expName,fileNames(i).name),'neur');
        progress_info(  i,length(fileNames));
        close all
    catch
        warning(sprintf('Failed for idx %d, cluster %d', i, neur.info.auto_clus_no));
        if reviewMode
            junk = input('press enter');
        end
    end
end

fileNameOut = sprintf('paraOutputMat_%s.mat', strrep(num2str(datenum(now)),'.','_'));
save(fullfile(pathDef.neuronsSaved,fileNameOut),'paraOutputMat');
save('paraOutputMat','paraOutputMat');
%