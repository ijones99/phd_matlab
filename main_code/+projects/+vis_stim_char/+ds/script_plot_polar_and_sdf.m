load ~/ln/vis_stim_hamster/data_analysis/cluster_vars/idxAssigns.mat
load('~/ln/neurons_saved/paraOutputMat.mat')
load(fullfile('../analysed_data/moving_bar_ds/dataOut.mat'));
% rowIdxSave

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
expNo = 4;
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



%% find ON-OFF DS

% ON-OFF DS = 7; ON DS = 2
idxLUT = find(LUT(:,3) ==7)

%% plot polar
doSubplot = 0;
h=figure;
figs.scale(h, 60,90)
subplotDims=[3, 3]
for i=1:length(idxLUT)
    if doSubplot
        subplots.subplot_tight(subplotDims(1),subplotDims(2),i,0.03)
    end
    
    idxCurr = find(dataOut.clus_num==LUT(idxLUT(i),2));
    
    [h1 maxSpikecount prefAngle ] = plot_polar_for_ds([0:45:350], ...
        dataOut.on_max_fr(idxCurr,:),'vector_sum','line_style','r')
    %     fprintf('%4.1f\n',max(dataOut.on_max_fr(idxCurr,:)))
    
    hold on;
    
    %     [prefAngleRound,I] = geometry.get_closest_value_in_vector(prefAngle, [0:45:350]);
    
%     plot_polar_for_ds([0:45:350], ...
%         dataOut.off_max_fr(idxCurr,:),'vector_sum','line_style','k')
%    hold on
    
    %     title(sprintf('clus %d',LUT(i,2)))
    title(num2str(prefAngle));
 
end

%% plot spike density function
h=figure; hold on
figs.scale(h, 60,90)
subplotDims=[3, 3];

% load stim params
stimFrameInfo = file.load_single_var('settings/',...
    'stimFrameInfo_Moving_Bars_ON_OFF.mat');

offsetsUnique = unique(stimFrameInfo.offset );
rgbsUnique = unique(stimFrameInfo.rgb);
lengthsUnique = unique(stimFrameInfo.length);
widthsUnique = unique(stimFrameInfo.width);
speedsUnique = unique(stimFrameInfo.speed);
anglesUnique = unique(stimFrameInfo.angle);

for i=1:length(idxLUT)
    subplots.subplot_tight(subplotDims(1),subplotDims(2),i,0.03);
    hold on
    idxCurr = find(dataOut.clus_num==LUT(idxLUT(i),2))
%     offsetsCurr = paramOut.closest_offset{idxCurr}(:,3);
     for iOffset = 1:length(offsetsUnique)
        for iRgb = 2%1:length(rgbsUnique)
            for iLength = 1%:length(lengthsUnique)
                for iWidth = 1%:length(widthsUnique)
                    for iSpeed = 1%1:length(speedsUnique)
                        for iAngle = 1:length(anglesUnique)
                            x = dataOut.edges;
                            y = dataOut.mean_fr_vs_time{idxCurr}{iOffset, iRgb, iLength, iWidth, iSpeed, iAngle};
                            plot(y,'k');
                        end
                    end
                end
            end
        end
        
    end
    

end
%%
sigma = 0.025; % sigma for smoothing
binWidth = 0.025; % bin width

for i=1:length(segments)
    [psthSegment{i} edges ] = get_psth_2(segments{i}, startTime, stopTime, binWidth);
    frSegment(i,:) = conv_gaussian_with_spike_train(psthSegment{i}, sigma, binWidth);
end




