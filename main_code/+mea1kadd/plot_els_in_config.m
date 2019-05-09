function plot_els_in_config( m , textOpt,varargin)
%  PLOT_ELS_IN_CONFIG( m , textOpt)

textOffset.x = 4;
textOffset.y = 4;
highlightEls = [];
elIdx = 1:length(m.mposx);

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'highlight_els')
            highlightEls = varargin{i+1};
        elseif strcmp( varargin{i}, 'file_name')
            name2 = varargin{i+1};
        elseif strcmp( varargin{i}, 'el_idx')
            elIdx = varargin{i+1};
        end
    end
end


if nargin < 2
    textOpt == '';
end

if isempty(elIdx)
    validIdx = find(m.mposx >= 0);
else
    validIdx = elIdx;
end

% true positions
validEls = m.elNo(validIdx);
[xPos yPos] = mea1kadd.el2xy_v2(validEls);
hold on

if ~isempty(highlightEls )
    idxHL = find(ismember(validEls,highlightEls));
    for j=1:length(idxHL )
        plot(xPos(idxHL(j)), yPos(idxHL(j)), 'rs','MarkerFaceColor', 'r');
    end
end

figs.reverse_y_axis;

plot(xPos,yPos,'k.');
if strcmp(textOpt,'el')
    text(xPos+textOffset.x,yPos+textOffset.y, num2str(m.elNo(validIdx)))
elseif strcmp(textOpt ,'ch')
    text(xPos+textOffset.x,yPos+textOffset.y, num2str((validIdx-1)))
end





end
