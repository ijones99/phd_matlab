function cutoutRaw = extract_epoch(rawData, ts, preTs, postTs)
% cutoutRaw = EXTRACT_EPOCH(rawData, ts, preTs, postTs)

ts = round(ts);

idxStr = '[';
for i=1:length(ts)
   currStr = sprintf('%d:%d ', ts(i)-preTs, ts(i)+postTs);
   idxStr(end+1:end+length(currStr)) = currStr;
end
idxStr(end+1) = ']';

eval(['cutoutRaw = rawData(', idxStr, ')'';']);

end
