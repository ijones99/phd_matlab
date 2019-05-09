function [configCtrX configCtrY configCtrXAll configCtrYAll fileNamesOut] = plot_config_positions_from_el2fi(...
    dirName, searchStr, varargin)


% init vars
doPlotAllEls=0;
doPlotCenter = 0;
doPlotConfigEls = 0;
doLabelCenter = 0;
NeurorouterFormat = 1;
doLabelConfigElIdx = 0;
doLabelConfigChannelNr = 0;
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'do_plot_all_els')
            doPlotAllEls = 1;
        elseif strcmp( varargin{i}, 'do_plot_center_loc')
            doPlotCenter = 1;
        elseif strcmp( varargin{i}, 'hide_config_els')
            doPlotConfigEls = 0;
        elseif strcmp( varargin{i}, 'label_center')
            doLabelCenter = 1;
        elseif strcmp( varargin{i}, 'format_for_normal_plot')
            NeurorouterFormat = 0;
        elseif strcmp( varargin{i}, 'label_config_el_idx')
            doLabelConfigElIdx = 1;
            
        elseif strcmp( varargin{i}, 'label_config_channel_nr')
            doLabelConfigChannelNr = 1;
        end
    end
end


all_els=hidens_get_all_electrodes(2);

if ~sum(strfind(searchStr,'el2fi.nrk2'))
    searchStr = [searchStr, '.el2fi.nrk2'];
end

fileNames = dir(fullfile(dirName, searchStr));
if isempty(fileNames)
   fprintf('File not found.\n')
   return;
end

% plot all els in gray
if doPlotAllEls
    plot(all_els.x,all_els.y,'+','color',[0.4 0.4 0.4]);
    axis equal
end
% mean of entire array
% configCtrXAll = (max(all_els.x)-min(all_els.x))/2; configCtrYAll = (max(all_els.y)-min(all_els.y))/2;
configCtrXAll = mean(all_els.x); configCtrYAll = mean(all_els.y);
% plot red dot in very center
if doPlotCenter
    plot(configCtrXAll, configCtrYAll,'rO','LineWidth', 4)
end

for i=1:length(fileNames)
    
    localInd = [];
    % get elidx and chnummbers
    [elidxInFile chNoInFile] = get_el_ch_no_from_el2fi(dirName, ...
        fileNames(i).name);
    
    % get local indices to get positions
    
    localInd = find(ismember(all_els.el_idx, elidxInFile));
    
    configElsX=all_els.x(localInd);
    configElsY=all_els.y(localInd);
    if doPlotConfigEls
        plot(configElsX,configElsY,'o','Color',rand(1,3));
        
    end
    % get text
    suffixLoc = strfind(fileNames(i).name,'.el2fi.nrk2');
    configNum = fileNames(i).name(suffixLoc-3:suffixLoc-1);
    
    %     % plot number
    %     if doPlotAllEls
    %         plot(configCtrXAll,configCtrYAll,'o','Color',rand(1,3));
    %     end
    if doLabelCenter
        configCtrX(i) = mean(configElsX); configCtrY(i) = mean(configElsY);
        text(configCtrX(i)-25,configCtrY(i),configNum,'FontSize', ...
            14,'FontWeight', 'bold')
    else
        configCtrX = [];
        configCtrY = [];
    end
    % label config els
    if doLabelConfigElIdx
       
        text(all_els.x(localInd)+2, all_els.y(localInd)+2, num2cell(elidxInFile'),'FontWeight', 'bold');
        
    end
    if doLabelConfigChannelNr
         text(all_els.x(localInd)+2, all_els.y(localInd)+2, num2cell(chNoInFile'),'FontWeight', 'bold');
    end
    
end

doPlotAllEls=0;
doPlotCenter = 0;
doPlotConfigEls = 0;
doLabelCenter = 0;
NeurorouterFormat = 0;
doLabelConfigElIdx = 0;
doLabelConfigChannelNr = 0;

if ~NeurorouterFormat
    set(gca,'YDir','reverse');
end

% get file names
   fileNamesOut = {};
for i=1:length(fileNames)
    fileNamesOut{i} = fileNames(i).name;
end


end