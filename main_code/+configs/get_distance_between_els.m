function dist = get_distance_between_els(elIdx, all_els)

% find local ind for two els;
allElsIdx = find(ismember(all_els.el_idx,elIdx));

elIdx1.x = all_els.x(allElsIdx(1));
elIdx1.y = all_els.y(allElsIdx(1));

elIdx2.x = all_els.x(allElsIdx(2));
elIdx2.y = all_els.y(allElsIdx(2));

dist = sqrt((elIdx1.x-elIdx2.x)^2+(elIdx1.y-elIdx2.y)^2);



end