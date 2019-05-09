fileNo = 1;
% flist = {};

% flist_for_white_noise
flistFileNameID = 'T11_10_23_13_white_noise_plus_others';
% flistFileNameID = 'T11_10_23_6_orig_stat_surr_med_plus_others';
% directory names

qualityDataSheetOutputDir = strcat('Figs/', flistFileNameID, '/QualityDataSheets/');
dirNameSt = strcat('../analysed_data/',flistFileNameID,'/03_Neuron_Selection/');
dirNameCl = strcat('../analysed_data/',flistFileNameID,'/02_Post_Spikesorting/');

% file types to open
fileNamePatternSt = fullfile(dirNameSt,'st_*mat');
fileNamePatternCl = fullfile(dirNameCl,'cl_*mat');

% obtain file names
fileNamesSt = dir(fileNamePatternSt); numStFiles = length(fileNamesSt);
fileNamesCl = dir(fileNamePatternCl); numClFiles = length(fileNamesCl);



% number of groups
% totalNumberOfGroups = length(sortedRedundantClusterGroups);

doElsArrangeByAmplitude = 0;

% get index number
elNumbers = 5161;
doSave = 1;
% noPca = 'no_pca_plot';
noPca = ''
pattern = 'st_*';
fileInds = [];
fileInds = get_file_inds_from_el_numbers(dirNameSt, pattern, elNumbers)
sortedRedundantClusterGroups{1} = fileInds;
totalNumberOfGroups = length(sortedRedundantClusterGroups);
% generate quality data sheets

for iGroup = 1:totalNumberOfGroups
    % set number of elements in the group
    numberElementsInGroup = min(length(sortedRedundantClusterGroups{iGroup}),10);

    % make directory
    if doSave, eval(['!mkdir ',fullfile(qualityDataSheetOutputDir,num2str(iGroup))]); end
    for iNeuronInds = fileInds%sortedRedundantClusterGroups{iGroup}(1:numberElementsInGroup)
        
        % load st file to get cluster name
        clusterName = fileNamesSt(iNeuronInds).name;
        clusterNameCore = strrep(strrep(clusterName,'.mat',''),'st_','');
        % get indices for electrode and cluster number
        idNumInds = regexp(clusterName, '\d+');
        idNumIndsAllPos = regexp(clusterName, '\d');
        
        % get numbers
        elNumber = (clusterName(idNumInds(1): idNumInds(1)+3));
        clusterNumber = (clusterName(idNumInds(2): idNumIndsAllPos(end)));
        
        % load cl file for data & rename to "spikes" & clear
        load(fullfile( dirNameCl, strcat('cl_',elNumber,'.mat')));
        eval(['spikes = cl_',elNumber,';']); eval(['clear cl_',elNumber,';']);
        %         randomize colors
        sizeColorPalette = size(spikes.info.kmeans.colors);
        spikes.info.kmeans.colors  = rand(sizeColorPalette(1), sizeColorPalette(2)); 
        % load st file for data & rename to "spikes" & clear
        load(fullfile( dirNameSt, strcat('st_',clusterNameCore,'.mat')));
        % get rearranged order of electrodes (arranged by amplitude)
        if doElsArrangeByAmplitude
            eval(['[elAmps rearrangedElsInds ] = sort( ', strrep(clusterName,'.mat',''), '.el_avg_amp, ''descend'');']);
        end
        eval(['clear st_',clusterNameCore,';']);
        
        % rearrange order of electrodes
        if doElsArrangeByAmplitude
            spikes.waveforms = spikes.waveforms(:,:,rearrangedElsInds );
            spikes.elidx = spikes.elidx(rearrangedElsInds);
            spikes.channel_nr = spikes.channel_nr(rearrangedElsInds );
        end
        %send spikes structure to be plotted; return figure handle
        % also send as arguments: ind #, file locations, cluster name, proc,p
        
        
        h = plot_cluster_characteristics2(spikes, ...
            clusterName, iNeuronInds, elNumber,clusterNumber, noPca )
        
        %     ,'testing_on'
        if doSave
            scrsz = get(0,'ScreenSize');
            
            for iPage =1:length(h)
                exportfig(h(iPage),fullfile(qualityDataSheetOutputDir,num2str(iGroup),strcat('Data-Quality-Sheet_', clusterNameCore,'_page', num2str(iPage))), ...
                    'fontmode','fixed', 'fontsize',8,'Color', 'rgb' );
            end
        end
        
%         close all
        
    end
end