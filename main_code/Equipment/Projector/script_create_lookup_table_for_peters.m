load /home/ijones/Documents/Equipment/Projector/2012-06-25_Peters_Setup_Measurements/pwrND_II.mat
pwrMeasInds = 1282:-5:1282-254*5;
pwrMeasInds = pwrMeasInds(end:-1:1);

for i=1:255
    lookupTbMean_II(i) = mean(pwrND_II( pwrMeasInds(i)-1:pwrMeasInds(i)+1));
end

% rename var
lookupTbMean_ND2_norm = lookupTbMean_II;
% remove offset
lookupTbMean_ND2_norm = lookupTbMean_ND2_norm - min(lookupTbMean_ND2_norm);
% norm to one
lookupTbMean_ND2_norm = lookupTbMean_ND2_norm./max(lookupTbMean_ND2_norm);
save ../DataFiles/lookupTbMean_ND2_norm.mat lookupTbMean_ND2_norm
%%
% load data
% load /home/ijones/Documents/Equipment/Projector/2011_11_03' Measurements'/2011_11_03_blu+green.mat
% load /home/ijones/Documents/Equipment/Projector/2012-06-25_Peters_Setup_Measurements/lookupTbMean_II.mat   
% max value of the pwr readings
maxPowerReading = 255;

% the values that are specified in the code
inputPixVal =[1:255]';
% the readout energy levels (power), normalized [0 .. 255]
outputPixVal = lookupTbMean_II*255/maxPowerReading;
% outputPixVal(2) = outputPixVal(2)+.001;
% outputPixVal(end-1) = outputPixVal(end-1)+.001;
% outputPixVal(end) = outputPixVal(end)+.002;
% plot data
figure
plot(inputPixVal, outputPixVal,'*');

% label
xlabel('input'), ylabel('output');

%% polyfit

% get polyfit for data
n = 12;
p = polyfit(outputPixVal, inputPixVal',n);

% get fitted power readings based on this fit
% !!!! use this formula to transform matrices
fittedPowerReadings = polyval(p,outputPixVal);

% save polyfit coefficients
save polyFitCoeff.mat p

% plot the original readings and the fitted data
figure, plot(outputPixVal,inputPixVal,'o',outputPixVal, fittedPowerReadings ,'*')

%% modify if redudant values
outputPixVal(251) = outputPixVal(250)+1e-20;

%% plot values

lookupTable = spline(outputPixVal , fittedPowerReadings,1:255);
figure, plot(outputPixVal,inputPixVal','ro', 1:255,lookupTable,'.')
 xlabel('output (power readings, uW/mm^2, scaled to [0 255])'), ...
     ylabel('input (pixel brightness value settings)'), ...
     title('fitted values for input/output');
%save info
% save lookupTable.mat lookupTable
%% plot fitted values
figure
lookupTable = spline(pixelSetValues, uint8(fittedPowerReadings),1:255);

plot(pixelSetValues, powerReadings ,'ro', 1:255,lookupTable,'.')

%% test function
% random matrix
x = randi(255,600);

% 
maxFittedPower = max(fittedPowerReadings)-min(fittedPowerReadings);