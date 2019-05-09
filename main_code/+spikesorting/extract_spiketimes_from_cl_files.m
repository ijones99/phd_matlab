function extract_spiketimes_from_cl_files( varargin)

% function EXTRACT_SPIKETIMES_FROM_CL_FILES
%
% varargin:
%   'input_file_info_cell':
%       fileInfoCell.runNo
%                   .flist
%                   .flistName
%                   .stimType

selFileInds = [];
selElNos = [];
doFelixCluster = 0;
ntkIdx = [];
i=1;
fileInfoCell = {};
forceFileOverwrite = 0;
while i<=length(varargin)
    if not(isempty(varargin{i}))
        
        
        if strcmp(varargin{i},'sel_inds')
            selFileInds = varargin{i+1};
        elseif strcmp(varargin{i},'sel_els')
            selElNos = varargin{i+1};
        elseif strcmp(varargin{i},'felix_cluster')
            doFelixCluster=1;
        elseif strcmp(varargin{i},'input_ntk_elidx')
            ntkIdx = varargin{i+1};
        elseif strcmp(varargin{i},'input_file_info_cell')
            fileInfoCell = varargin{i+1};
        elseif strcmp(varargin{i},'force')
            
            forceFileOverwrite = 1;
        else
            
        end
    end
    i=i+1;
end
if isempty(fileInfoCell)
    runNo = input('Enter run no >> ');
    [stimNames  stimNamesIdx] = stimulus.select_stim_type;
    flistName = sprintf('flist_%s_n_%02d',stimNames{stimNamesIdx}, runNo);
    flist = make_flist_select([flistName,'.m']);
    suffixName = strrep(flistName,'flist','');
else
   runNo = fileInfoCell.runNo;
   flist = fileInfoCell.flist;
   stimNames = fileInfoCell.stimType;
   flistName = sprintf('flist_%s_n_%02d',stimNames, runNo);
   suffixName = strrep(flistName,'flist','');
    
end

flistFileNameID = get_flist_file_id(flist, suffixName)

% analyzed data directory
analyzedDataDir = strcat('../analysed_data/');

% input data directory
inputDir = strcat('../analysed_data/', flistFileNameID ,'/02_Post_Spikesorting/');

% output data directory
outputDir = strcat('../analysed_data/', flistFileNameID,'/03_Neuron_Selection/');

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

% start from file number as specified
textprogressbar('extracting timestamps')
elNumbersInSt = get_el_numbers_from_dir(outputDir, 'st_*','unique');
for i=selFileInds
    
    
    inputFileName = fileNames(i).name;
    
    electrodeIsProcessed = 0;
    if ~forceFileOverwrite
        baseZeros = '0000';
        for j=1:length(elNumbersInSt)
            existingNumbers = strcat(baseZeros, num2str(elNumbersInSt(j)));
            existingNumbers = existingNumbers(end-3:end);
            if strfind(inputFileName,existingNumbers)
                electrodeIsProcessed = 1;
                
            end
            
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
                %                 eval([outputStructName,'.elidx=', inputStructName ,'.elidx;']);
%                 eval([outputStructName,'.elidx=ntkIdx;']);
                eval([outputStructName,'.elidx=', inputStructName ,'.elidx;']);
                if doFelixCluster
                    
                    %                     eval([outputStructName,'.channel_nr=', inputStructName ,'.channel_nr;']);
                    %                     eval([outputStructName,'.file_switch_ts=', inputStructName ,'.file_switch_ts;']);
                else
                    eval([outputStructName,'.channel_nr=', inputStructName ,'.channel_nr;']);
                    eval([outputStructName,'.file_switch_ts=', inputStructName ,'.file_switch_ts;']);
                end
                neurIndList{iNeurList} = outputStructName;
                iNeurList = iNeurList+1;
                save(fullfile(outputDir,outputFileName),outputStructName);
            end
        end
        %     fprintf('File %d of %d done\n', i , length(fileNames));
        eval(['clear ', inputStructName]);
        
    end
    %     100*find(i==selFileInds)/length(selFileInds)
    textprogressbar(100*find(i==selFileInds)/length(selFileInds))
end
textprogressbar('end')
%save a list of all the neurons
% save(fullfile(analyzedDataDir,flistFileNameID,'neuronIndList.mat'), 'neurIndList' );
end