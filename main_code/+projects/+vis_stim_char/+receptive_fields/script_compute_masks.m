%% format indices matrix
paraOutputMat = [];
paraOutputMat.params = [];

dirNames = projects.vis_stim_char.analysis.load_dir_names;
% marching sqr over grid
b = file.load_single_var(dirNames.common.params, 'param_March_Sqr_Over_Grid.mat');
idxColParamMat = 1;
idxInvalid = b.invalid;
paraOutputMat.params(:,idxColParamMat) = mats.set_orientation( b.dir_num,'col'); idxColParamMat = idxColParamMat + 1;
paraOutputMat.params(:,idxColParamMat) = mats.set_orientation( b.clus_num,'col'); idxColParamMat = idxColParamMat + 1;
paraOutputMat.params(:,idxColParamMat) = mats.set_orientation( b.index_total_cnt,'col'); idxColParamMat = idxColParamMat + 1;
paraOutputMat.params(:,idxColParamMat) =  mats.set_orientation( b.latency,'col'); idxColParamMat = idxColParamMat + 1;
paraOutputMat.params(:,idxColParamMat) =  mats.set_orientation( b.transience,'col'); idxColParamMat = idxColParamMat + 1;
paraOutputMat.params(:,idxColParamMat) =  normalize_values( mats.set_orientation( b.RF_area_um_sqr,'col'),[0 1]); idxColParamMat = idxColParamMat + 1;

% moving bar DS
b = file.load_single_var(dirNames.common.params, 'param_Moving_Bars_DS.mat');
paraOutputMat.params(:,idxColParamMat) = ...
    mats.set_orientation(b.ds_fr_slow_on, 'col');
idxColParamMat = idxColParamMat + 1;

b = file.load_single_var(dirNames.common.params, 'param_Speed_Test.mat');
paraOutputMat.params(:,idxColParamMat) = ...
    mats.set_orientation(b.index, 'col');
idxColParamMat = idxColParamMat + 1;

b = file.load_single_var(dirNames.common.params, 'param_Length_Test.mat');
paraOutputMat.params(:,idxColParamMat) = ...
    mats.set_orientation(b.index, 'col');
idxColParamMat = idxColParamMat + 1;

%% get normalized spike counts for each ds cell
dataOutAll = {};
nrmSpkCntAll = [];

for iDir =1:length(dirNames.dataDirLong) % loop through directories
    cd([dirNames.dataDirLong{iDir},'Matlab/']); % enter directory
    load ../analysed_data/moving_bar_ds/dataOut.mat;
    nrmSpkCntAll = [nrmSpkCntAll  dataOut.mean_norm_spk_cnt_pref_angle];
end

%% remove nan and zero values
[r c i]= find(isnan(paraOutputMat.params(:,:)))
rowIdxRem = unique([r' find(nrmSpkCntAll<0.35)]);%idxInvalid

rowIdxSave = find(~ismember(1:size(paraOutputMat.params,1),rowIdxRem));

% paraOutputMat.neur_names = paraOutputMat.neur_names(rowIdxSave);
paraOutputMat.params = paraOutputMat.params(unique(rowIdxSave),:);

headingNames = {'Dir Num' 'Cluster Num' 'Bias-Index'    'Latency'  ...
    'Transience' 'RF Area' 'DS-Index'    'Speed-Index'    'Length-Index'}

%%
    cpu.open_matlabpool(7);
    
%%
dirNames = projects.vis_stim_char.analysis.load_dir_names;
for expNo = 1:7
    cd([dirNames.dataDirLong{expNo},'Matlab/']); % e
    
    load ~/ln/vis_stim_hamster/data_analysis/cluster_vars/idxAssigns.mat
    load('~/ln/neurons_saved/paraOutputMat.mat')
    load(fullfile('../analysed_data/moving_bar_ds/dataOut.mat'));
    
    % rowIdxSave
        
    % get cluster numbers
    idxGlobalExp = find(paraOutputMat.params(:,1)==expNo )'; % idx for paraOutputMat for this group
    clusNumsDir = paraOutputMat.params(idxGlobalExp,2);
    
    %     % get local (for dir) idx to keep
    %     idxValid = find(ismember(idxGlobalExp,rowIdxSave));
    
    %
    %     idxGlobalExpValid = idxGlobalExp(idxValid);
    clusNumsValid = paraOutputMat.params(idxGlobalExp,2);
    cellTypeNo = idxAssigns{7}(idxGlobalExp);
    
    
    idxLocalInDir = find(ismember(dataOut.clus_num, clusNumsValid));
    
    
    LUT = [mats.set_orientation(idxGlobalExp,'col')...
        mats.set_orientation(clusNumsValid,'col')...
        mats.set_orientation(cellTypeNo,'col')...
        mats.set_orientation(idxLocalInDir,'col')];
    % [global idx | clus nums | cell type | localidx]
    
    load('../analysed_data/marching_sqr_over_grid/dataOut.mat')
    
    errorVal = [];
    widthVal = [];
    areaVal = [];
    

    mm = {};
    parfor i=1:size(LUT,1)
        mm{i} = projects.vis_stim_char.receptive_fields.get_interp_rf(i,LUT, dataOut, 9);
        %         progress_info(i,size(LUT,1));
    end
    recFldMasks = {};
    parfor i=1:size(LUT,1)
        recFldMasks{i} = create_mask(mm{i},'threshold_percent',33);
        %         progress_info(i,size(LUT,1));
    end
    
    
    %     save ../analysed_data/recFldMasks.mat recFldMasks
    recFldA = [];
    for iRF = 1:length(recFldMasks)
        recFldA(end+1)= length(find(recFldMasks{iRF}>0))/(size(recFldMasks{iRF},1)*size(recFldMasks{iRF},2));
        
    end
    save ../analysed_data/recFldA.mat recFldA
    !rm ../analysed_data/recFldMasks.mat
    progress_info(expNo, 7, 'Dir completed: ')
    fprintf('>>>>>>>> number masks = %d\n', length(recFldMasks));
end

%% compute diameters for RFs
dirNames = projects.vis_stim_char.analysis.load_dir_names;
A = [];
for expNo = 1:7
    cd([dirNames.dataDirLong{expNo},'Matlab/']); % e
    load ../analysed_data/recFldA.mat
    %     progress_info(expNo, 7)
    A(end+1:end+length(recFldA)) = recFldA;
    fprintf('%d\n',length(recFldA))
end

rfDiam = sqrt(4*A/pi());

save ~/ln/vis_stim_hamster/data_analysis/marching_sqr_over_grid/rfDiam.mat rfDiam
