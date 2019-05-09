function plot_polar_for_rgc(stimDirectionsDegrees, responseAmplitudes, varargin)
% function plot_polar_for_rgc(stimDirectionsDegrees, responseAmplitudes)
% P.color = 'b';

P.color = 'b';
P = mysort.util.parseInputs(P, varargin, 'error');

% normalize amplitudes
responseAmplitudes = responseAmplitudes/max(responseAmplitudes);

% convert degrees to radians
stimDirectionsRadians = stimDirectionsDegrees*2*pi()/360;

h = polar([stimDirectionsRadians stimDirectionsRadians(1)], ...
    [responseAmplitudes([1:end 1])]);

set(h, 'LineWidth',2,'Color',P.color);

view([90 -90])
end