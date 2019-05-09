% script to plot receptive fields for RGCs found in experiments

% list of directories
dirNames = { ...
    '../analysed_data/profiles/White_Noise/';...
    }
hFig = figure, hAxes = axes, hold on
% loop through dir
for iDir = 1:length(dirNames)
    % make figure
%     load neurNameMat.mat
    % get file names
    
    fileNames = dir(fullfile(dirNames{iDir},sprintf('*.mat')));
    
    % loop through file names
    for iFile = 1:length(fileNames)
        try
%         hFig = figure, hAxes = axes, hold on
        % load file into currIm
%         fileNames = dir(fullfile(dirNames{iDir},sprintf('*%s*.mat',neurNameMat{iFile,1})));
        
        load(fullfile(dirNames{iDir},fileNames(iFile).name));
        
        staPlotData = data.White_Noise.sta_temporal_plot.staIms; 
        staPlotData = staPlotData-mean(staPlotData);
        [Y bestFrameInd] = max(staPlotData);
        
        inputImOrig = data.White_Noise.sta(:,:,bestFrameInd);
        [I, J, outlineIm] = ifunc.im_proc.get_outline_of_receptive_field(inputImOrig);
        if I~=0
            try
                [ellipse_t rotated_ellipse] = ifunc.fit2d.fit_ellipse( I,J,hAxes, hFig);
                if ellipse_t.long_axis < 300
                    figure(hFig)
                    plot( rotated_ellipse(1,:),rotated_ellipse(2,:),'b','LineWidth',2 );
                end
            end
        end
        xlim([0 300]), ylim([0 300])
        iFile
        pause(1)
         
    
    circle([10*data.White_Noise.plot_info.imWidth/2+1.5 10*data.White_Noise.plot_info.imWidth/2+1.5],...
        (10*data.White_Noise.plot_info.imWidth*...
        10*data.White_Noise.plot_info.apertureDiam/(10*data.White_Noise.plot_info.stimWidth))/2,...
        10*data.White_Noise.plot_info.imWidth,'k--',3);
    title(sprintf('Experiment %s', get_dir_date'),'FontSize', 20)
    axis off
        end
    end
%     Receptive_Field_Outlines_20Dec2012
    
end