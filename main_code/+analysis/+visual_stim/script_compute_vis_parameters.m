%% compute parameters
pathDef = dirdefs();%expName = '17Jun2014';
dirSettings = 'settings/'
expName = get_dir_date
fileNames = filenames.get_filenames('*.mat', fullfile(pathDef.neuronsSaved,expName))
runNo = input('run no: ');
eval(sprintf('load wnCheckBrdPosData_%02.0f',runNo))
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
        umsStart = strfind(fileNames(i).name,'ums')+3;
        umsStop = strfind(fileNames(i).name,'auto')-2;
        neur.info.ums_clus_name = fileNames(i).name(umsStart:umsStop);
        % find xy location
        idxWnCheckBrdPosData = cells.cell_find_str_in_field(...
            wnCheckBrdPosData, 'fileName', neur.info.ums_clus_name);
        neur.info.rfRelCtr = wnCheckBrdPosData{idxWnCheckBrdPosData}.rfRelCtr;
        if ~doDebug
            spotsSettings = file.load_single_var(dirSettings, 'stimFrameInfo_spots.mat');
            barsSettings = file.load_single_var(dirSettings,...
                'stimFrameInfo_movingBar_2Reps.mat');
            neur = response_params_calc.compute_vis_stim_parameters2(neur,...
                spotsSettings, barsSettings,'bar_offset', 300,'plot','save_plot');%,
            %set headings
            if doSetHeadings && i==1
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
            paraOutputMat.params(idx,j) = getfield(neur.paramOut,fieldNames{j});
        end
        junk = input('press enter')
        
        progress_info(  i,length(fileNames));
        close all
    catch
        
    end
end

fileNameOut = sprintf('paraOutputMat_%s.mat', strrep(num2str(datenum(now)),'.','_'));
save(fullfile(pathDef.neuronsSaved,fileNameOut),'paraOutputMat');
save('paraOutputMat','paraOutputMat');
%