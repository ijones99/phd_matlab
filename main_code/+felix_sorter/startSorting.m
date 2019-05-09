function startSorting(expName, runName, elNumbers, sortGroupNumber)
    % STARTSORTING(expName, runName, elNumbers, sortGroupNumber)
    % this file is a modification of the sorting script that was thought to
    % yield a fast estimation of where DS cells are. In this file though
    % the sorting can be restricted to certain electrode Numbers allowing
    % to sort several configurations at the same time as long as they share
    % said electrode numbers.
    expPath = ana.michele.dsCellScanSorting.dataPath(expName);
    if ~exist(expPath, 'file')
        error('The specified experiment directory does not exist! (%s)', expPath);
    end
%     ana.michele.dsCellScanSorting.extractStimEpochs(expName, sortGroupNumber);
    cd(fullfile(expPath, 'Matlab'));
    confs = load('configurations.mat');
    confs = confs.configurations;
    cidxRange = 1:length(confs.configs);
    
    sps = 20000; % samples per second
    hpf = 300;
    lpf = 7000;
    forder = 4;
    name = 'dirtySort';
    tstart = tic;
    
    %% MAIN SORTING LOOP
    parfor cii = 1:length(cidxRange)
        cidx = cidxRange(cii);
        outputPath = fullfile(expPath, 'Matlab', 'DirtySortings', sprintf('Config%03d', cidx));
       
        if ~exist(outputPath, 'file');
            mkdir(outputPath);
        end
        c = confs.configs(cidx);
        ntk_filelist = confs.flist(c.flistidx);
        % system(['ls -lah ../proc/' ntk_filelist{1}]) This function does a
        % "supposedly" quick spike sorting of the ntk files given in
        % ntk_filelist and uses hardcoded stimulus information to estimate
        % the direction selectivity index of the neurons found. Results are
        % stored in outputPath
        cputimes = []; ti=1; tstart = tic;

        fprintf('Init...\n')
        cutleft = 10;
        Tf = 45;

        nFiles = length(ntk_filelist);
        bufferLengthPerFileInMin = 1;
        bufferLengthPerFileInSamples = bufferLengthPerFileInMin*60*sps;
        % The individual files should not contain much more samples then
        % estimated in this way!

        % get number of channels
        nSamplesPerFiles = zeros(1, nFiles);   

        % Load the whole data of all ntk files
        siz = bufferLengthPerFileInSamples*2;
        fprintf('Loading raw data...\n')
        
        for i=1:nFiles
            ntk=initialize_ntkstruct(ntk_filelist{i}, 'nofilters');
            [high_density_data ntk] = ntk_load(ntk, siz, 'images_v1');
            [a subElIdx] = intersect(high_density_data.el_idx, elNumbers);
            assert(length(a)==length(elNumbers), 'Invalid configuration!');
            X_ = high_density_data.sig(:, subElIdx);
            nC = size(X_, 2);
            if i==1
                % init data matrix
                X = zeros(nFiles*bufferLengthPerFileInSamples, nC);
                FR = zeros(nFiles*bufferLengthPerFileInSamples, 1);
            end
            nSamplesPerFiles(i) = size(X_,1);
            assert(nSamplesPerFiles(i) < siz, 'The file was longer than allowed! Only use this script for short files that contain the DS cell finding stimuli!');
            X (sum(nSamplesPerFiles(1:i-1))+1:sum(nSamplesPerFiles(1:i)),:) = X_;
            FR(sum(nSamplesPerFiles(1:i-1))+1:sum(nSamplesPerFiles(1:i)),1) = high_density_data.images.frameno;
        end
        X = X(1:sum(nSamplesPerFiles),:);
        FR = FR(1:sum(nSamplesPerFiles),:);
        stim_epochs = ana.michele.epochsFromFrameNo(FR);
        % filter the data and build DataSourceObject
        cputimes(ti) = toc(tstart); ti=ti+1; tstart = tic;
        fprintf('Prefiltering data...\n')
        hd = mysort.mea.filter_design(hpf, lpf, sps, forder);
        X = filtfilthd(hd, X);
        electrodePositions = [high_density_data.x(subElIdx)' high_density_data.y(subElIdx)']; 
        electrodeNumbers = high_density_data.el_idx(subElIdx)';  
        fprintf('------------------------ %d ------------------------\n', cii');
    
        % Make groupings of electrodes to be sorted independently
        [groupsidx nGroupsPerElectrode] = mysort.mea.constructLocalElectrodeGroups(electrodePositions(:,1), electrodePositions(:,2));
        % replace electrode indices with electrode numbers
        groups = {};
        for ii=1:length(groupsidx)
            groups{ii} = electrodeNumbers(groupsidx{ii});
        end    
        groupFile = fullfile(fullfile(outputPath, 'groupFile.mat'));
        save(groupFile, 'groups', 'electrodeNumbers', 'electrodePositions', 'nGroupsPerElectrode', 'groupsidx');
        
        % sort the groups
        cputimes(ti) = toc(tstart); ti=ti+1; tstart = tic;
        P = struct();
        P.spikeDetection.method = '-';
        P.spikeDetection.thr = 4.2;
        P.artefactDetection.use = 0;
        P.botm.run = 0;
        P.spikeCutting.maxSpikes = 200000; % This is crucial for computation time

        P.noiseEstimation.minLength = 300000; % This also effects computation time
        P.noiseEstimation.minDistFromSpikes = 80;

        P.spikeAlignment.initAlignment = '-';   
        P.spikeAlignment.maxSpikes = 30000;
        P.clustering.maxSpikes = 30000;
        P.clustering.meanShiftBandWidth = sqrt(1.8*6);
        P.mergeTemplates.merge = 1;
        P.mergeTemplates.upsampleFactor = 3;
        P.mergeTemplates.atCorrelation = .93; % DONT SET THIS TOO LOW! USE OTHER ELECTRODES ON FULL FOOTPRINT TO MERGE 
        P.mergeTemplates.ifMaxRelDistSmallerPercent = 30;
        % Prepare data
        bUseParallelComputation = 0;
        if bUseParallelComputation
            XX = {};
            for ii=1:length(groupsidx)
                XX{ii} = X(:, groupsidx{ii});
            end
            cputimes(ti) = toc(tstart); ti=ti+1; tstart = tic;
%             parfor ii=1:length(groupsidx)
            for ii=1:length(groupsidx)

                elIdx = groupsidx{ii};
                DS = mysort.ds.Matrix(XX{ii}, sps, name, electrodePositions(elIdx,:), electrodeNumbers(elIdx));        
                [S P_] = ana.sort(DS, fullfile(outputPath, ['group' sprintf('%03d', ii)]), runName, P);
            end
        else
            for ii=1:length(groupsidx)
                elIdx = groupsidx{ii};
                DS = mysort.ds.Matrix(X(:, groupsidx{ii}), sps, name, electrodePositions(elIdx,:), electrodeNumbers(elIdx));        
                [S P_] = ana.sort(DS, fullfile(outputPath, ['group' sprintf('%03d', ii)]), runName, P);
            end 
        end
        clear XX DS S;
        DSFull = mysort.ds.Matrix(X, sps, name, electrodePositions, electrodeNumbers);    

        % Re-Estimate templates on all electrodes of that config after
        % sorting
        cputimes(ti) = toc(tstart); ti=ti+1; tstart = tic;
        disp('Estimating Templates...');
        MES = DSFull.MultiElectrode.toStruct();
        for ii=1:length(groupsidx)
            matchingFile  = fullfile(fullfile(outputPath, ['group' sprintf('%03d', ii)]), [runName '.100botm_matching.mat']);
            sortingFile  = fullfile(fullfile(outputPath, ['group' sprintf('%03d', ii)]), [runName '.110clusters_meanshift_merged.mat']);
            templateFile = fullfile(fullfile(outputPath, ['group' sprintf('%03d', ii)]), [runName '_templates.mat']);
            S = load(sortingFile);
            M = load(matchingFile);
            units = unique(S.clusteringMerged.ids);
            wfs = zeros(Tf, size(DSFull,2), length(units));
            nSourceSpikesPerTemplateAndChannel = [];
            for uidx = 1:length(units)
                fprintf('.');
                tsIdx = find(S.clusteringMerged.ids == units(uidx));
                tsIdx = tsIdx(1:min(300, end));
                wfs_ = DSFull.getWaveform(round(M.clusteringMatched.ts(tsIdx)), cutleft, Tf);
                wfs(:,:,uidx) = mysort.wf.v2t(median(wfs_,1), size(DSFull,2));
                nSourceSpikesPerTemplateAndChannel(uidx, 1:size(DSFull,2)) = size(wfs_,1);
            end
            elGroupIndices = groupsidx{ii};
            save(templateFile, 'wfs', 'cutleft', 'MES', 'elGroupIndices', 'nSourceSpikesPerTemplateAndChannel'); 
            fprintf('.\n');
        end
    end

    %% Process all local sortings into a final sorting
    for cii = 1:length(cidxRange) %4:4%
        cidx = cidxRange(cii);
        
        outputPath = fullfile(expPath, 'Matlab', 'DirtySortings', sprintf('Config%03d', cidx));
        groupFile = fullfile(fullfile(outputPath, 'groupFile.mat'));
        load(groupFile, 'groups', 'electrodeNumbers', 'electrodePositions', 'nGroupsPerElectrode', 'groupsidx');   
        
        % cputimes(ti) = toc(tstart); ti=ti+1; tstart = tic;
        disp('Postprocessing...');
        [gdf_merged T_merged localSorting localSortingID] =...
            ana.processLocalSortings(outputPath, runName, groups, groupsidx);
        units = unique(gdf_merged(:,1));
        nU = length(units)
        assert(length(localSorting) == nU, 'must be identical');
        assert(length(localSortingID) == nU, 'must be identical');
        assert(size(T_merged,3) == nU, 'must be identical');
        save(fullfile(outputPath, [runName '_results.mat']), 'gdf_merged', 'T_merged', 'localSorting', 'localSortingID');
        
        % cputimes(ti) = toc(tstart); fprintf('Loading: %.3f\nFiltering:
        % %.3f\nDataInit: %.3f\nSorting: %.3f\nEst Templates:
        % %.3f\nPostproc: %.3f\n', cputimes); ttime(cidx) = sum(cputimes);
    end
    


