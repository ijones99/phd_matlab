function distMat = compare_centers_of_mass(ctrMassX, ctrMassY)
% distMat = compare_centers_of_mass(ctrMassX, ctrMassY)


% init output
distMat = zeros(length(ctrMassX));

%     % get all lengths to center of mass from reference point (0,0)
%     cLength = sqrt(ctrMassX.^2 + ctrMassY.^2);
%
for i=1:length(ctrMassX)
    
    
    distMat(i,:) = sqrt((ctrMassX-ctrMassX(i)).^2 + (ctrMassY-ctrMassY(i)).^2);
    
    
end






end