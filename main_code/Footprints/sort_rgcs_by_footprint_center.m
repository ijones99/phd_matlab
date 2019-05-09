function [fileInds xAndYLocations ] = sort_rgcs_by_footprint_center(neurNames, elConfigInfo)
% fileInds = sort_rgcs_by_footprint_center(neurNames, elConfigInfo)
% PURPOSE: sorts the rgc files based on cell center, computed by taknig
% electrodes with 7 highest amplitudes and computing the effective location
% of the center based on their spatial locations and amplitudes


if ischar(neurNames)
    neurNamesTemp = neurNames;clear neurNames;
    neurNames{1} = neurNamesTemp;
end

% initialize variable for locations of electrodes
xAndYLocations = zeros(length(neurNames),2);
textprogressbar('start finding footprint centers>')
for i=1:length(neurNames)
   % load neuron data
   try
   data = load_profiles_file(neurNames{i});
   % sort eletrode amps
   
   maxPeakToPeak = max(data.White_Noise.footprint.averaged,[],2)-min(data.White_Noise.footprint.averaged,[],2);
   data.White_Noise.max_peak_to_peak = maxPeakToPeak;
   [elAmps, indElAmps] = sort(data.White_Noise.max_peak_to_peak,'descend');
   % retain 4 highest amps
   elAmps = elAmps(1:7);indElAmps = indElAmps(1:7);
   % x value: sum of amps * spatial locations divided by sum of spat.
   % locations
   xAndYLocations(i, 1) = sum(elAmps'.*elConfigInfo.elXNtk2(indElAmps))/sum(elAmps);
   xAndYLocations(i, 2) = sum(elAmps'.*elConfigInfo.elYNtk2(indElAmps))/sum(elAmps);
   
   centerOfFootprintXY = [xAndYLocations(i, 1) xAndYLocations(i, 2)];
   save_to_profiles_file(neurNames{i}, 'White_Noise.footprint', 'center_of_footprint_xy', centerOfFootprintXY,1);
     
   catch
       fprintf('Could not load data for %s\n', neurNames{i});
   end
       textprogressbar(100*i/length(neurNames));
end
textprogressbar('Finish finding footprint centers>')
% 
% % round values
% xAndYLocationsRounded =round2(xAndYLocations,10);

% sort by x and then y locations
[junk, fileInds ] = sortrows(xAndYLocations,[2 1]);



end