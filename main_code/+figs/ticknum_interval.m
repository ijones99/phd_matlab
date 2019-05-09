function ticknum_interval(ticksIntX, ticksIntY)
% TICKNUM(ticksIntX, ticksIntY)

if ~isempty(ticksIntX)
    L = get(gca,'XLim');
    set(gca,'XTick',[L(1):ticksIntX:L(2)])
end

if ~isempty(ticksIntY)
    L = get(gca,'YLim');
    set(gca,'YTick',[L(1):ticksIntY:L(2)])
end

end