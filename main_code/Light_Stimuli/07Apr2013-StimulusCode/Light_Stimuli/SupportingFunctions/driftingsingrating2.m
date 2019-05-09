function driftingsingrating2(angle, cyclespersecond, freq, gratingsize, internalRotation, BeepOn,presentationLength, phase )



Screen('Preference', 'SkipSyncTests', 2 );

% function DriftDemo4([angle=0][, cyclespersecond=1][, freq=1/360][, gratingsize=360][, internalRotation=0])
% ___________________________________________________________________
%
% Display an animated grating, using the new Screen('DrawTexture') command.
% This demo demonstrates fast drawing of such a grating via use of procedural
% texture mapping. It only works on hardware with support for the GLSL
% shading language, vertex- and fragmentshaders. The demo ends if you press
% any key on the keyboard.
%
% The grating is not encoded into a texture, but instead a little algorithm - a
% procedural texture shader - is executed on the graphics processor (GPU)
% to compute the grating on-the-fly during drawing.
%
% This is very fast and efficient! All parameters of the grating can be
% changed dynamically. For a similar approach wrt. Gabors, check out
% ProceduralGaborDemo. For an extremely fast aproach for drawing many Gabor
% patches at once, check out ProceduralGarboriumDemo. That demo could be
% easily customized to draw many sine gratings by mixing code from that
% demo with setup code from this demo.
%
% Optional Parameters:
% 'angle' = Rotation angle of grating in degrees.
% 'internalRotation' = Shall the rectangular image patch be rotated
% (default), or the grating within the rectangular patch?
% gratingsize = Size of 2D grating patch in pixels.
% freq = Frequency of sine grating in cycles per pixel.
% cyclespersecond = Drift speed in cycles per second.
%

% History:
% 3/1/9  mk   Written.

%% SETTINGS
% ------------------------------------------ %
% Based on physical light intensity measurements of projector
% dark gray (25%) = 115
% gray (50%) = 163
% light gray (75%) = 205
% max white (100%) = 255
% ------------------------------------------ %

RestrictKeysForKbCheck(66) % Restrict response to the space bar

% Global vars
global screenid
global win

Black = 0;
White = 255;
DarkGrayVal = 115/White;
GrayVal = 163/White;
LightGrayVal = 205/White;

%sin wave vacillates between 115 and 205
GrayValSinBase = 160/White ;
SinWaveAmp = 95/White % +/- this value

% Phase is the phase shift in degrees (0-360 etc.)applied to the sine
% grating:
if nargin < 8 || isempty(phase)
    PresentationLength = 0;
end

% Initial stimulus parameters for the grating patch:
% presentation length
if nargin < 7 || isempty(presentationLength)
    presentationLength = 100;
end
% use beeping prompt
if nargin < 6 || winisempty(BeepOn)
    BeepOn = 1;
end

if nargin < 5 || isempty(internalRotation)
    internalRotation = 0;
end

if internalRotation
    rotateMode = kPsychUseTextureMatrixForRotation;
else
    rotateMode = [];
end

if nargin < 4 || isempty(gratingsize)
    gratingsize = 360;
end

% res is the total size of the patch in x- and y- direction, i.e., the
% width and height of the mathematical support:
res = [gratingsize gratingsize];

if nargin < 3 || isempty(freq)
    % Frequency of the grating in cycles per pixel: Here 0.01 cycles per pixel:
    freq = 1/360;
end

if nargin < 2 || isempty(cyclespersecond)
    cyclespersecond = 1;
end

if nargin < 1 || isempty(angle)
    % Tilt angle of the grating:
    angle = 0;
end

% Amplitude of the grating in units of absolute display intensity range: A
% setting of 0.5 means that the grating will extend over a range from -0.5
% up to 0.5, i.e., it will cover a total range of 1.0 == 100% of the total
% displayable range. As we select a background color and offset for the
% grating of 0.5 (== 50% nominal intensity == a nice neutral gray), this
% will extend the sinewaves values from 0 = total black in the minima of
% the sine wave up to 1 = maximum white in the maxima. Amplitudes of more
% than 0.5 don't make sense, as parts of the grating would lie outside the
% displayable range for your computers displays:
amplitude = .5;

% Open a fullscreen onscreen window on that display, choose a background
% color of 128 = gray, i.e. 50% max intensity:

% Retrieve video redraw interval for later control of our animation timing:
ifi = Screen('GetFlipInterval', win);

% Compute increment of phase shift per redraw:
phaseincrement = (cyclespersecond * 360) * ifi;

% Build a procedural sine grating texture for a grating with a support of
% res(1) x res(2) pixels and a RGB color offset of 0.5 -- a 50% gray.
gratingtex = CreateProceduralSineGrating(win, res(1), res(2), [0 .5 .5 0.0]);

% Wait for release of all keys on keyboard, then sync us to retrace:
KbReleaseWait;
vbl = Screen('Flip', win);

parapin(0);


% Animation loop: Repeats until keypress...
% for i = 1:PresentationLength
i=1;
while ~KbCheck && i<presentationLength+1
    % Update some grating animation parameters:

    % Increment phase by 1 degree:
    phase = phase + phaseincrement;

    % Draw the grating, centered on the screen, with given rotation 'angle',
    % sine grating 'phase' shift and amplitude, rotating via set
    % 'rotateMode'. Note that we pad the last argument with a 4th
    % component, which is 0. This is required, as this argument must be a
    % vector with a number of components that is an integral multiple of 4,
    % i.e. in our case it must have 4 components:
    Screen('DrawTexture', win, gratingtex, [], [], angle, [], [], [], [], rotateMode, [phase, freq, amplitude, GrayVal]);

    % Show it at next retrace:
    parapin(6);
    vbl = Screen('Flip', win, vbl + 0.5 * ifi);
    parapin(4);
    i=i+1;
end


parapin(0);

if BeepOn

    beep()
    pause(.4)
    beep()

    KbWait;
    pause(.5);


end

%  m = zeros(600,600, 3);
% %m(:,:,1) = 1;
% m(:,:,2) = 1;
% m(:,:,3) =  1;
% %m(1:300,1:300,:)=0;
% color=m*163%GrayVal;
%
% Screen(win, 'PutImage', color);
% Screen(win, 'Flip');
% pause(waitTimeBetweenPresentations)

return;
