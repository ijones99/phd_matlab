t = 0:0.001:10;
yOrig = zeros(size(t));
spikes = rand(1,20)*10;
spikeInds = find(ismember(t, round2(spikes,0.001))>0);
t_c = 0.2;

for iSpikes = 1:length(spikes)
    y(iSpikes,:) = yOrig;
    
    
    expPart = exp(-t/t_c);
    y(iSpikes,spikeInds(iSpikes):end) =  expPart(1:length(t)-spikeInds(iSpikes)+1);
    
end

outPut = sum(y,1);