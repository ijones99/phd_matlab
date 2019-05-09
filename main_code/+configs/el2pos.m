function posInfo = el2pos(elIdxSel)
% posInfo = el2pos(elIdxSel, all_els)
%
% arguments
%   all_els = get_all_config_info(2)

global all_els

if ~isempty('all_els')
    verNo = 2;
    all_els=hidens_get_all_electrodes(verNo);
end

  elSelLocalIdx = multifind(all_els.el_idx, elIdxSel,'J');
  posInfo.x = all_els.x(elSelLocalIdx);
  posInfo.y = all_els.y(elSelLocalIdx);

end