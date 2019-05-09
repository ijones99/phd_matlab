function B = draw_outline_of_bw_shape(imInput, varargin)
% B = DRAW_OUTLINE_OF_BW_SHAPE(imInput, varargin)


lineColor = 'k';
lineWidth = 2;
doPlotOriginalIm = 0;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'color')
            lineColor = varargin{i+1};
        elseif strcmp( varargin{i}, 'line_width')
            lineWidth = varargin{i+1};
        elseif strcmp( varargin{i}, 'plot_original_im')
            doPlotOriginalIm = varargin{i+1};
        end
    end
end

BW = im2bw(imInput, graythresh(imInput));
[B,L] = bwboundaries(BW,'noholes');
if doPlotOriginalIm
    imshow(label2rgb(L, @jet, [.5 .5 .5]))
end
for k = 1:length(B)
    boundary = B{k};
    plot(boundary(:,2), boundary(:,1), 'Color',lineColor, 'LineWidth', lineWidth)
end


end