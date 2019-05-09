function open_matlabpool(requestedNumWorkersInPool)
% OPEN_MATLABPOOL(requestedNumWorkersInPool)

currSize = matlabpool('size');

if currSize == 0 % if close, open
    eval(sprintf('matlabpool open local%dclus',requestedNumWorkersInPool));
elseif currSize ~= requestedNumWorkersInPool % if different number open, then close and reopen.
    matlabpool close
    eval(sprintf('matlabpool open local%dclus',requestedNumWorkersInPool));
else
    warning('Already running this number of workers.')
end

% 

end