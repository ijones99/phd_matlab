function [xOut yOut] = create_line(x1, y1, x2, y2, n) 
% [xOut yOut] = CREATE_LINE(x1, y1, x2, y2, n)

m = (y2-y1)/(x2-x1);

if iszero(m) | isinf(m) % no change y
    
    xOut = linspace(x1,x2,n);
    yOut = linspace(y1,y2,n);

    
else
        % y=mx+b; b=y-mx;
    b = y1-m*x1;
    xOut = linspace(x1,x2,n);
    yOut = m*xOut+b;
    
end


end
