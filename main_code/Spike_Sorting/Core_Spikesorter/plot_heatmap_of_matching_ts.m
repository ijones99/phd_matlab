function heatMap = plot_ts_matching_heatmaps(flistName, varargin)

idNameStartLocation = strfind(flistName{1},'T');idNameStartLocation(1)=[];
flistFileNameID = flistName{1}(idNameStartLocation:end-11);

filesSelInDir = [];
neuronsIndSel = 0;
i=1;
while i<=length(varargin)
    if not(isempty(varargin{i}))
        if  strcmp(varargin{i},'add_dir_suffix')
            clear flistFileNameID;
            flistFileNameID = strcat(flistName{1}(idNameStartLocation:end-11),varargin{i+1});                
        else
            fprintf('unknown argument at pos %d\n', 2+i);
        end
    end
    i=i+1;
end

binWidthMs = 0.5;


for iBinWidth = 1: length(binWidthMs)
    
    % get a heatmap of matches (always comapred to the row neurons as a ground
    % truth)
    [heatMap, neuronTs] = get_heatmap_of_matching_ts(binWidthMs(iBinWidth), flistFileNameID  );
    
    if iBinWidth == 1
        subplotMainHandle = figure;
    end
    
    % direct to subplot figure
    figure(subplotMainHandle)
    
    % plot subplot
    subplot(3,3,iBinWidth);
    imagesc(heatMap);
    title(strcat('Bin Width-', num2str(binWidthMs(iBinWidth)),' ms'));
    
    % plot to separate figure
    figure
    imagesc(heatMap);
    title(strcat('Bin Width-', num2str(binWidthMs(iBinWidth)),' ms'));
    colorbar
    
    % save file
    saveToDir = '';
    print('-depsc', '-tiff', '-r300', fullfile(saveToDir, ...
        strcat('HeatmapComparison_BinWidth',...
        strrep(num2str(binWidthMs(iBinWidth)),'.','-') )));
    
    
end

