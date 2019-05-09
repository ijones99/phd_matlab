
requestedNumWorkersInPool = 6;
eval(sprintf('matlabpool open local%dclus',requestedNumWorkersInPool));
matlabpool close