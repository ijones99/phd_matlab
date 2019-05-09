
xLocations = [-400:100:400];
yLocations = xLocations;

locCtr = 1;
for iX = 1:length(xLocations)
    for iY = 1:length(yLocations)
       Settings.XY_LOC_um(locCtr,:)= [xLocations(iX), yLocations(iY)];
       locCtr = locCtr+1;
        
    end
end


Settings.RAND_XY_LOC= randperm(locCtr-1);