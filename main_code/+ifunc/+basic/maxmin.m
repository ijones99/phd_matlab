function rangeVals = maxmin(value)
rangeVals = zeros(1,2);
rangeVals(1) = min(min(min(value)));
rangeVals(2) = max(max(max(value)));



end