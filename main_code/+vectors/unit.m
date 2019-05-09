function unit_vectors = unit(V)
    % unit computes the unit vectors of a matrix
    % V is the input matrix
    norms = sqrt(sum(V.^2));
    unit_vectors = zeros(size(V));
    normsIndex=norms>eps;
    unit_vectors(:,normsIndex) = V(:,normsIndex)./repmat(norms,size(V,1),1);
end