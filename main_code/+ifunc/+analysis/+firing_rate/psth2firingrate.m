function firingRate = psth2firingrate(psth,numTrials,binWidth)
% firingRate = PSTH2FIRINGRATE(psth,numTrials,binWidth)

firingRate = (psth/numTrials)/binWidth;


end