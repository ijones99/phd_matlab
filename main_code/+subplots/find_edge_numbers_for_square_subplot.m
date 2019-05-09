function edges = find_edge_numbers_for_square_subplot(numPlots)
% edges = find_edge_numbers_for_square_subplot(numPlots)

sqrtVal = sqrt(numPlots);
maxEdgeNum  = ceil(sqrtVal);
minEdgeNum  = floor(sqrtVal);

if maxEdgeNum*minEdgeNum >= numPlots
    edges(1) = maxEdgeNum;
    edges(2) = minEdgeNum;
else
    edges = [1 1]*maxEdgeNum;
    
end



end