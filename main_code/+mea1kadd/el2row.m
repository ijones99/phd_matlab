function row = el2row(elNo)
% row = EL2ROW(elNo)

TR.el = 219;

% rows
elsPerRow = [TR.el+1];
row = floor(elNo/elsPerRow)+1;


end
