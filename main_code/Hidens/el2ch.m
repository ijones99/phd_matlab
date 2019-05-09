function channelNr = el2ch(elIdxSel, elIdxAll, channelNrAll)
% channelNr = EL2CH(elIdxSel, elIdxAll, channelNrAll)

  elSelLocalIdx = multifind(elIdxAll, elIdxSel,'J');
  channelNr = channelNrAll(elSelLocalIdx);


end