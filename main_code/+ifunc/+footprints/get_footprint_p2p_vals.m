function allAmplitudes = get_footprint_p2p_vals(footprint)
% function allAmplitudes = get_footprint_p2p_vals(footprint)
allAmplitudes = max(footprint, [], 2) - min(footprint, [], 2);

end