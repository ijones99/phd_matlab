function edgeLengths = dimensions_for_ratio(numElementsIn,  ratioIn)
% edgeLengths = DIMENSIONS_FOR_RATIO(numElementsIn,  ratioIn)
%
% default for entire external monitor: 1.6
% frontiers full-page ratio: 1.3333

 c = sqrt(numElementsIn/ratioIn);
 b = numElementsIn/c;
 
 edgeLengths(1) = ceil(c);
 edgeLengths(2)= ceil(b);



end