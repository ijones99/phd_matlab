function lookupTbStim = make_stim_lookuptable(m_stim, metaData, metaDataIdxEl, stimTimes, numTestStimAtBegin)
% lookupTbStim = MAKE_STIM_LOOKUPTABLE(m_stim, metaData, metaDataIdxEl,
% stimTimes, numTestStimAtBegin)

% get idx of stim times
voltIdx = [metaDataIdxEl+numTestStimAtBegin+1:metaDataIdxEl+length(stimTimes)+numTestStimAtBegin];
lookupTbStim = nan(length(stimTimes),2);
% stimulus timestamps
lookupTbStim(:,1) = stimTimes;
lookupTbStim(:,2) = metaData{2}(voltIdx);


end
