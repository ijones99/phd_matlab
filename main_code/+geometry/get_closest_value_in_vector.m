function [Y,I] = get_closest_value_in_vector(val1, vector1)
% [Y,I] = GET_CLOSEST_VALUE_IN_VECTOR(val1, vector1)

distVal = abs(vector1 - val1);

I = multifind(distVal, min(distVal));

I = I(end);
Y = vector1(I);



end
