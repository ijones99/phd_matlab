function plot_quality_datasheet_from_cluster_name(flist, suffixName, clusterNameCore, varargin )
clusterNameCore = strrep(clusterNameCore,' ',''); %remove spaces
fileNo = 1;
doSave = 1;
subDir = '';
doPlotPCA = 1;
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp(varargin{i},'sub_dir')
            subDir = varargin{i+1};
            
        elseif strcmp(varargin{i},'no_pca_plot')
            doPlotPCA = 0;
            
        elseif strcmp(varargin{i},'file_save')
            doSave = varargin{i+1};
        end
    end
end

% filename id
idNameStartLocation = strfind(flist{1},'T');idNameStartLocation(1)=[];
idNameEndLocation = strfind(flist{1},'.stream.ntk')-1;
flistFileNameID = strcat(flist{1}(idNameStartLocation:idNameEndLocation),suffixName);

% directory names
if strcmp(subDir,'')
    qualityDataSheetOutputDir = strcat('../Figs/', flistFileNameID, '/QualityDataSheets/');
else
    qualityDataSheetOutputDir = strcat('../Figs/', flistFileNameID, '/QualityDataSheets/',subDir);
end

dirNameSt = strcat('../analysed_data/',flistFileNameID,'/03_Neuron_Selection/');
dirNameCl = strcat('../analysed_data/',flistFileNameID,'/02_Post_Spikesorting/');

% load st file to get cluster name
clusterName = strcat('st_', clusterNameCore,'.mat');

% get indices for electrode and cluster number
idNumInds = regexp(clusterName, '\d+');
idNumIndsAllPos = regexp(clusterName, '\d');

% get numbers
elNumber = clusterNameCore(1:4);

clusterNumberStart = strfind(clusterNameCore,'n')+1;
clusterNumber = clusterNameCore(clusterNumberStart:end)

% load cl file for data & rename to "spikes" & clear
load(fullfile( dirNameCl, strcat('cl_',elNumber,'.mat')));
eval(['spikes = cl_',elNumber,';']); eval(['clear cl_',elNumber,';']);
%         randomize colors
sizeColorPalette = size(spikes.info.kmeans.colors);
spikes.info.kmeans.colors  = rand(sizeColorPalette(1), sizeColorPalette(2));
% load st file for data & rename to "spikes" & clear
load(fullfile( dirNameSt, strcat('st_',clusterNameCore,'.mat')));
% get rearranged order of electrodes (arranged by amplitude)
eval(['[elAmps rearrangedElsInds ] = sort( ', strrep(clusterName,'.mat',''), '.el_avg_amp, ''descend'');']);
eval(['clear st_',clusterNameCore,';']);

% rearrange order of electrodes
spikes.waveforms = spikes.waveforms(:,:,rearrangedElsInds );
spikes.elidx = spikes.elidx(rearrangedElsInds);
spikes.channel_nr = spikes.channel_nr(rearrangedElsInds );
%send spikes structure to be plotted; return figure handle
% also send as arguments: ind #, file locations, cluster name, proc,p

clusterFileName{1} = clusterName
[fileInds elNumbers] = ...
    get_file_inds_and_el_numbers_from_filename_list(dirNameSt,clusterFileName , 'st_*mat')

if doPlotPCA
    
h = plot_cluster_characteristics2(spikes, ...
    clusterName, fileInds , elNumber,clusterNumber)
else
h = plot_cluster_characteristics2(spikes, ...
    clusterName, fileInds , elNumber,clusterNumber, 'no_pca_plot' )
end
%     ,'testing_on'
if doSave
    scrsz = get(0,'ScreenSize');
    mkdir(qualityDataSheetOutputDir);
    for iPage =1:length(h)
        exportfig(h(iPage),fullfile(qualityDataSheetOutputDir,strcat('Data-Quality-Sheet_', clusterNameCore,'_page', num2str(iPage))), ...
            'fontmode','fixed', 'fontsize',8,'Color', 'rgb' );
        fprintf('Save %s to %s\n', clusterNameCore, qualityDataSheetOutputDir)
    end
end


end

