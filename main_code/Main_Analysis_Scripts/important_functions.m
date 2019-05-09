
title(strcat(['Response to Moving Bars ON: ', get_dir_date, '/el-', ...
    neuronsList{expGroupNumMovingBars}.neuron_names{iNeurons}]));


%% set up figure 
h = figure('Position', [1 1 1000 1200] ); % [left bottom width height]....get(0,'ScreenSize')  [1 1 1920 1200]                                                                                    
numSubplotsVert = 8;
subPlotNo = 3;
setSpacing = 0.013;
setPadding = 0.01;
setMargin = 0.015;
subplotsVert = 2;
subplotsHor = 2;
subplot(subplotsVert,subplotsHor,3);