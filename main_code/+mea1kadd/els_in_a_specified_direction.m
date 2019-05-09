function els = els_in_a_specified_direction(elNo, direction)
% els = ELS_IN_A_SPECIFIED_DIRECTION(elNo, direction)
%
% 0 degrees = East
% 90 degrees = North

TL.xy = [239.5 222.0];
TR.xy = [4072 222];
BL.xy = [239.5 2304.5];
BR.xy = [4072 2304.5];

TL.el = 0;
TR.el = 219;
BL.el = 26180;
BR.el = 26399;

% rows
elsPerRow = [TR.el+1];
% cols
elsPerCol = (BR.el+1)/elsPerRow;

els = 1;
i=1;
colNum = mea1kadd.el2col(elNo);
rowNum = mea1kadd.el2row(elNo);

switch direction
    case 0
        while colNum  < elsPerRow
            els(i) = elNo+i ;
            colNum = mea1kadd.el2col(els(i));
            i=i+1;
        end
    case 45
        while colNum  < elsPerRow & rowNum > 1
            els(i) = elNo-220*i+i ;
            colNum = mea1kadd.el2col(els(i));
            rowNum = mea1kadd.el2row(els(i));
            i=i+1;
        end
    case 90
        while rowNum  > 1
            els(i) = elNo-220*i ;
            colNum = mea1kadd.el2col(els(i));
            rowNum = mea1kadd.el2row(els(i));
            i=i+1;
        end
    case 135
        while colNum  > 1 & rowNum > 1
            els(i) = elNo-220*i-i ;
            colNum = mea1kadd.el2col(els(i));
            rowNum = mea1kadd.el2row(els(i));
            i=i+1;
        end
    case  180
        while colNum  > 1
            els(i) = elNo-i ;
            colNum = mea1kadd.el2col(els(i));
            i=i+1;
        end
    case 225
        while colNum  > 1 & rowNum < elsPerCol
            els(i) = elNo+220*i-i ;
            colNum = mea1kadd.el2col(els(i));
            rowNum = mea1kadd.el2row(els(i));
            i=i+1;
        end
    case 270
         while rowNum  < elsPerCol
            els(i) = elNo+220*i ;
            colNum = mea1kadd.el2col(els(i));
            rowNum = mea1kadd.el2row(els(i));
            i=i+1;
        end
    case 315
        while colNum  < elsPerRow & rowNum < elsPerCol
            els(i) = elNo+220*i+i ;
            colNum = mea1kadd.el2col(els(i));
            rowNum = mea1kadd.el2row(els(i));
            i=i+1;
        end
        
end


end
