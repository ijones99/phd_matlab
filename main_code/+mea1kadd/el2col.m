function col = el2row(elNo)
% col = EL2COL(elNo)

TR.el = 219;
elsPerRow = [TR.el+1];
col = rem(  elNo, elsPerRow)+1;

end
