function epocs = extract_epocs(f, ts, preTs, postTs, chNum)
% epocs = EXTRACT_EPOCS(f, ts, preTs, postTs, chNum)
%
% output
%   epocs: [samples X channels X timestamps]

if nargin < 5
    chNum=1:1024;
end
ts = double(ts);
lenCh = length(chNum);

if lenCh == 1
    % out: [concat wfs X timestamp#]
    M1 = f.getCutouts(chNum, ts, preTs , postTs )
elseif lenCh == 1024
    M1 = f.getCutoutsAllNoFilt( ts, preTs , postTs);
else
    error('Cannot handle multiple specified channels');
end

epocs = reshape ( M1 , size(M1,1)/lenCh , lenCh , size(M1,2) );

end



% X=