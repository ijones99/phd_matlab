% load data
load /home/ijones/Documents/Equipment/Projector/2011_11_03' Measurements'/2011_11_03_blu+green.mat

% max value of the pwr readings
maxPowerReading = max(intensity_level);

% the values that are specified in the code
inputPixVal =intensity_level;
% the readout energy levels (power), normalized [0 .. 255]
outputPixVal = values_in_uW*255/maxPowerReading;
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
n = 10;
p = polyfit(outputPixVal, inputPixVal,n);

% get fitted power readings based on this fit
% !!!! use this formula to transform matrices
fittedPowerReadings = polyval(p,outputPixVal);

% save polyfit coefficients
save polyFitCoeff.mat p

% plot the original readings and the fitted data
figure, plot(outputPixVal,inputPixVal,'o',outputPixVal, fittedPowerReadings ,'-*')

%% plot values

lookupTable = spline(outputPixVal , fittedPowerReadings,0:255);
figure, plot(outputPixVal,inputPixVal,'ro', 0:255,lookupTable,'.')
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