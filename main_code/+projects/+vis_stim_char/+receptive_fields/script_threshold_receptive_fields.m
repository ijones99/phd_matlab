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
dirNames = projects.vis_stim_char.analysis.load_dir_names;
expNo = 3;
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


%% load electrode positions
dirNameProf = '../analysed_data/profiles/';
filenameProf = sprintf('clus_merg_%05.0f', 1);
load(fullfile(dirNameProf, filenameProf));
xyCoord = [neurM(2 ).footprint];


%%

load('../analysed_data/marching_sqr_over_grid/dataOut.mat')


errorVal = [];
widthVal = [];
areaVal = [];


configMid.x = mean(unique(neurM(2).footprint.x));
configMid.y = mean(unique(neurM(2).footprint.y));

cMap = colors.colormap_7;
cpu.open_matlabpool(7);

mm = {};
parfor i=1:size(LUT,1)
    mm{i} = projects.vis_stim_char.receptive_fields.get_interp_rf(i,LUT, dataOut, 9);
    progress_info(i,size(LUT,1),'Get Mask interp RF > ');
end
maskIm = {};
parfor i=1:size(LUT,1)
    maskIm{i} = create_mask(mm{i},'threshold_percent',33);
    progress_info(i,size(LUT,1),'Create Mask: ');
end

h=figure
for i=1:length(unique(LUT(:,3)))

    subplot(2,4,i );
    plot(450+neurM(2).footprint.x-configMid.x,450+neurM(2).footprint.y-configMid.y,'ks','linewidth',.25,...
        'MarkerFaceColor',[.5 .5 .5],'MarkerEdgeColor','none'), axis equal
    hold on
end

upSampSz = size(mm{1},1);
for i=1:size(LUT,1)
    
    cellTypeNo = LUT(i,3);
    subplot(2,4,cellTypeNo )
    hold on
    
    %     mm = imOn%*pOn + imOff*pOff;
        
    %         h=figure,hold on
    %         subplot(1,2,1);
    %     imagesc(mm), hold on
    
    
    areaVal(i) = 0.9*0.9*length(find(maskIm{i}>0))/(size(maskIm{i},1)*size(maskIm{i},2));
    
    %         imagesc(maskIm{i}), hold on
    boundary = images.trace_outline(maskIm{i});
    plot(boundary(:,2)*900/upSampSz,boundary(:,1)*900/upSampSz,'color',cMap(cellTypeNo,:),'LineWidth',2);
    
    %     title(['clus num ',num2str(LUT(i,2))]);
    %     j = input('Enter >> ');
    
    
    axis equal
    
    xlim([0 900]);ylim([0 900]);
    i
    shg
end
shg
