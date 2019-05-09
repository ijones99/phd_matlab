function posInfo = el2pos(elIdxSel, all_els)
% posInfo = el2pos(elIdxSel, all_els)
%
% arguments
%   all_els = get_all_config_info(2)

if nargin < 3
    verNo = 2;
    all_els=hidens_get_all_electrodes(verNo);
end

  elSelLocalIdx = multifind(all_els.el_idx, elIdxSel,'J');
  posInfo.x = all_els.x(elSelLocalIdx);
  posInfo.y = all_els.y(elSelLocalIdx);

end