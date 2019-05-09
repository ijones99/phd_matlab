function spikeTrain = put_vals_into_ind_vector(inputTs, inputVals, precision)

spikeTrain = single(zeros(1, inputTs(end)*1/precision));

iVal = 1;
for i=1:2:length(inputVals)
    spikeTrain(inputTs(i)*(1/precision):inputTs(i+1)*(1/precision)-1)=inputVals(iVal);
    iVal=iVal+1;
end

end