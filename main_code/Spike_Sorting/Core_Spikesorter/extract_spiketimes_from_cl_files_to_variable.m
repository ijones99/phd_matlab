function spikeTimesAllNeurons = extract_spiketimes_from_cl_files_to_variable( flistName, elConfigInfo, varargin)

% function extract_spiketimes_from_cl_files

idNameStartLocation = strfind(flistName{1},'T');idNameStartLocation(1)=[];
flistFileNameID = flistName{1}(idNameStartLocation:end-11);
selFileInds = [];
selElNos = [];
doFelixCluster = 0;
ntkIdx = [];
i=1;
spikeTimesAllNeurons = {};
while i<=length(varargin)
    if not(isempty(varargin{i}))
        
        if strcmp(varargin{i},'add_dir_suffix')
            flistFileNameID = strcat(flistName{1}(idNameStartLocation:end-11),varargin{i+1});
        elseif strcmp(varargin{i},'sel_inds')
            selFileInds = varargin{i+1};
        elseif strcmp(varargin{i},'sel_els')
            selElNos = varargin{i+1};
        elseif strcmp(varargin{i},'felix_cluster')
            doFelixCluster=1;
        elseif strcmp(varargin{i},'input_ntk_elidx')
            ntkIdx = varargin{i+1};
        elseif strcmp(varargin{i},'specify_dir_name')
            flistFileNameID = varargin{i+1};
        else
            
        end
    end
    i=i+1;
end

% analyzed data directory
analyzedDataDir = strcat('../analysed_data/');

% input data directory
inputDir = strcat('../analysed_data/', flistFileNameID ,'/02_Post_Spikesorting/');

% output data directory
outputDir = strcat('../analysed_data/', flistFileNameID,'/03_Neuron_Selection/');

% proc dir
procDir = strcat('../analysed_data/', flistFileNameID,'/');

% make sure dir exists
if ~exist(outputDir)
    eval(['!mkdir ',  outputDir]);
end

% file types to open
fileNamePattern = 'cl*mat';

% obtain file names
fileNames = dir(fullfile(inputDir,fileNamePattern));

%
iNeurList = 1;

% get file indices to read
if ~isempty(selElNos) % if not empty
    selFileInds = [];
    for iSelElNos = 1:length(selElNos)
        selFileInds(iSelElNos) = get_file_inds_from_el_numbers(inputDir, ...
            fileNamePattern, selElNos(iSelElNos)) ;
    end
    
else
    selFileInds = 1:length(fileNames);
    
end

% load(fullfile(procDir,'frameno.mat'));

% start from file number as specified
textprogressbar('extracting timestamps')
elNumbersInSt = get_el_numbers_from_dir(outputDir, 'st_*','unique');
for i=selFileInds
    
    
    inputFileName = fileNames(i).name;
    
    electrodeIsProcessed = 0;
    baseZeros = '0000';
    for j=1:length(elNumbersInSt)
        existingNumbers = strcat(baseZeros, num2str(elNumbersInSt(j)));
        existingNumbers = existingNumbers(end-3:end);
        if strfind(inputFileName,existingNumbers)
            electrodeIsProcessed = 1;
            
        end
        
    end
    
    if ~electrodeIsProcessed
               
        try
            % load file
            %     fileNames(i).name;
            inputFileName = fileNames(i).name;
            load(fullfile(inputDir,inputFileName));
            
            % struct name for struct that is read into this function
            periodLoc = strfind(inputFileName,'.');
            inputStructName = inputFileName(1:periodLoc-1);
            
            coreOutputStructName = strrep(inputStructName,'cl', 'st');
            outputStructName = coreOutputStructName ;
            
            % temporary name for structure
            workingStruct = eval([inputStructName]);
            
            % find labels for good neurons
            if doFelixCluster
            indGoodNeurLabels = find(workingStruct.labels(:,2)==2);
            else
                indGoodNeurLabels = find(workingStruct.labels(:,2)~=4);
            end
            goodNeurLabelValues = workingStruct.labels(indGoodNeurLabels,1);
            
            % go through labels and put spiketimes into cell
            for iLabels = 1:length(goodNeurLabelValues)
                
                % get indices for this label
                indSpikeTimes = find(workingStruct.assigns == goodNeurLabelValues(iLabels));
                spikeTimes = workingStruct.spiketimes(indSpikeTimes);
                
                
                % get mean amplitude for main electrode
                avgWaveformMainEl = single(mean(workingStruct.waveforms(indSpikeTimes,:,1)));
                avgWaveformAllEls = single(mean(workingStruct.waveforms(indSpikeTimes,:,:)));
                
                % assign value to structure
                main_el_avg_amp = max(avgWaveformMainEl) - min(avgWaveformMainEl);
                el_avg_amp = squeeze(max(avgWaveformAllEls) - min(avgWaveformMainEl))';
                
                % create matrix name
                outputStructName = strcat(coreOutputStructName,'n', ...
                    num2str(goodNeurLabelValues(iLabels)));
                
                % save file for each spiketrain
                outputFileName = strcat(outputStructName,'.mat');
                
                % assign output name to matrix
                eval([outputStructName,'.ts=spikeTimes;']);
                eval([outputStructName,'.main_el_avg_amp=main_el_avg_amp;']);
                eval([outputStructName,'.el_avg_amp=el_avg_amp;']);
                eval([outputStructName,'.elidx_sorted=', inputStructName ,'.elidx;']);
                %                 eval([outputStructName,'.elidx=ntkIdx;']);
                
                eval([outputStructName,'.channel_nr_sorted=', inputStructName ,'.channel_nr;']);
                eval([outputStructName,'.file_switch_ts=', inputStructName ,'.file_switch_ts;']);
%                 eval([outputStructName,'.frameno=frameno;']);
                neurIndList{iNeurList} = outputStructName;
                iNeurList = iNeurList+1;
                eval(sprintf('spikeTimesAllNeurons{end+1} = %s;', outputStructName ));
%                 save(fullfile(outputDir,outputFileName),outputStructName);
            end
        end
        %     fprintf('File %d of %d done\n', i , length(fileNames));
        eval(['clear ', inputStructName]);
        
    end
    %     100*find(i==selFileInds)/length(selFileInds)
    textprogressbar(100*find(i==selFileInds)/length(selFileInds))
end
save(fullfile(outputDir,'spikeTimesAllNeurons.mat'),'spikeTimesAllNeurons');
textprogressbar('end')
%save a list of all the neurons
% save(fullfile(analyzedDataDir,flistFileNameID,'neuronIndList.mat'), 'neurIndList' );
end