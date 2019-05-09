function idx = get_closest_value(myVal, myArray)
% idx = GET_CLOSEST_VALUE(myVal, myArray)

% get difference
diffs = myArray-myVal;

% find min val
[junk idx] = min(abs(diffs));

% diff between point found and point searched for
diffBtwnInputPtAndFoundPt = abs(diff([myVal myArray(idx)]));

% average array interval
arrayInt = max(myArray)/(length(myArray)-1);

if diffBtwnInputPtAndFoundPt > arrayInt
   warning(sprintf('Input value is %d; found value is %d, Array bounds are [%d %d]', ...
       myVal, myArray(idx),min(myArray) ,max(myArray)));
    
end

end