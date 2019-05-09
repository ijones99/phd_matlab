function ticknum(numTicksX, numTicksY,varargin)
% TICKNUM(numTicksX, numTicksY)

roundDig = [];

% check for arguments
handleVal = gca;
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'handle')
            handleVal = varargin{i+1};
        elseif strcmp( varargin{i}, 'file_name')
            name2 = varargin{i+1};        
        elseif strcmp( varargin{i}, 'round')
            roundDig=varargin{i+1}; 
        end
    end
end


if ~isempty(numTicksX)
    l = get(handleVal,'Xlim');
    intVals = linspace(l(1),l(2),numTicksX);
    if not(isempty(roundDig))
        [beforeDec afterDec ] = math.separate_decimal(roundDig(1));
        formatStr = ['%', num2str(roundDig(1)),'f|'];
        set(gca,'XTickLabel',sprintf(formatStr,intVals))
    end
    set(handleVal,'xtick',intVals);
end

if ~isempty(numTicksY)
    L = get(handleVal,'YLim');
    intVals = linspace(L(1),L(2),numTicksY);
    if not(isempty(roundDig))
        [beforeDec afterDec ] = math.separate_decimal(roundDig(2));
        formatStr = ['%', num2str(beforeDec),'.', num2str(afterDec),'f|'];
        set(gca,'YTickLabel',sprintf(formatStr,intVals))
    end
    set(handleVal,'YTick',intVals);
end

end