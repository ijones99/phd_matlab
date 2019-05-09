%% TO LOAD DATA:

f = mea1k.file( 'path_to_file.raw.h5' )
m = mea1k.map( 'path_to_mapping.nrk' )

m.mposx % x-coordinaten aller channels
m.mposy % y-coordinaten aller channels

X = f.getData( startFrame, chunkSize ) % gibt die daten zurueck

%% Obtain footprint for selected neuron
expDate = '150401';

fileName.spont = '0008.raw.h5';
fileName.config = '0005.mapping.nrk';

% load data 
f = mea1k.file( fullfile('~/ln/mea1k_recordings/', expDate, fileName.spont));
m = mea1k.map(fullfile('~/ln/mea1k_recordings/', expDate, fileName.spont)  )



%% Plot responses
% Isolate epochs for each voltage
% 1. choose electrode
% 2. load metadata
% 2. load data for epochs 
% 3. plot repeats for voltages
