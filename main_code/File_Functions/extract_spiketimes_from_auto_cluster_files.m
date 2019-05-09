function extract_spiketimes_from_auto_cluster_files( flistFileNameID, inputDir, ...
    varargin)

% function extract_spiketimes_from_cl_files


selFileInds = [];
selElNos = [];
doFelixCluster = 1;
ntkIdx = [];
i=1;
while i<=length(varargin)
    if not(isempty(varargin{i}))
        
        if strcmp(varargin{i},'sel_inds')
            selFileInds = varargin{i+1};
        elseif strcmp(varargin{i},'sel_els')
            selElNos = varargin{i+1};
        elseif strcmp(varargin{i},'input_ntk_elidx')
            ntkIdx = varargin{i+1};
        else
            
        end
    end
    i=i+1;
end

% analyzed data directory
analyzedDataDir = strcat('../analysed_data/');

% output data directory
outputDir = strcat('../analysed_data/', flistFileNameID,'/03_Neuron_Selection/');

% make sure dir exists
if ~exist(outputDir)
    eval(['!mkdir ',  outputDir]);
end

% file types to open
fileNamePattern = '*Export4UMS2000*.mat';

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
            
          
            % output structure (el number) name
            baseZeros = '0000';
            groupNum = strcat(baseZeros,num2str(i)); groupNum = groupNum(end-3:end);
            coreOutputStructName = strcat('st_', groupNum);
                        
            % temporary name for structure
            workingStruct = localSorting.spikes;
            
            % find labels for good neurons
         
            indGoodNeurLabels = find(workingStruct.labels(:,2)==2);
          
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
                %                 eval([outputStructName,'.elidx=', inputStructName ,'.elidx;']);
                eval([outputStructName,'.elidx=localSorting.el_idx;']);
                eval([outputStructName,'.inds_for_sorting_els=localSorting.clustered_source'';']);
                %  eval([outputStructName,'.channel_nr=', inputStructName ,'.channel_nr;']);
                %  eval([outputStructName,'.file_switch_ts=', inputStructName ,'.file_switch_ts;']);
                
                neurIndList{iNeurList} = outputStructName;
                iNeurList = iNeurList+1;
                save(fullfile(outputDir,outputFileName),outputStructName);
            end
        end
        %     fprintf('File %d of %d done\n', i , length(fileNames));
        clear localSortings
        
    end
    %     100*find(i==selFileInds)/length(selFileInds)
    textprogressbar(100*find(i==selFileInds)/length(selFileInds))
end
textprogressbar('end')
%save a list of all the neurons
% save(fullfile(analyzedDataDir,flistFileNameID,'neuronIndList.mat'), 'neurIndList' );
end