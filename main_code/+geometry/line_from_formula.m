function line1 = line_from_formula( slopeVal, yInterceptVal)
% line1 = LINE_FROM_FORMULA( slopeVal, yInterceptVal)
% line1 = [x1 y1]
%         [x2 y2]

line = zeros(2);
if yInterceptVal~=0 && slopeVal~=0
    
    % set x to zero, b = intercept, m = slope
    % y = b
    
    line1(1,:) = [0 yInterceptVal];
    
    % set y to zero
    % x = (y-b)/m
    line1(2,:) = [(-yInterceptVal)/slopeVal 0];
    
    
else % intercept == 0 
    %     y = mx+b
    locRange = [-200 200];
    line1(1,:) = [locRange(1) locRange(1)*slopeVal+yInterceptVal];
    line1(2,:) = [locRange(2) locRange(2)*slopeVal+yInterceptVal];
end

end