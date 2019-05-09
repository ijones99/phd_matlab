function [ window screenRect transitionScreen ] = initialize_screen( varargin )
% function [SCREEN_SIZE window screenRect whichScreen transitionScreen ...
%     ] = initialize_screen( Settings )
%
% varargin
%   'circle_trans_screen': [diameter in px , object foreground RGB val,
%   object background RGB val)
%
%
screen.objValueRGB = 0;
screen.surrDims = [1200, 1200];
outputTransCircle.doCreate = 0;
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'circle_trans_screen')
            
            outputTransCircle.doCreate = 1;
            outputTransCircle.diamPx = varargin{i+1};
            outputTransCircle.objectRGB = varargin{i+2};
            outputTransCircle.bkndRGB = varargin{i+3};
        elseif strcmp( varargin{i}, 'transition_screen_dims')
            screen.surrDims =varargin{i+1} ;        
        elseif strcmp( varargin{i}, 'transition_screen_brightness')
            screen.objValueRGB =varargin{i+1} ;
        end
    end
end



if outputTransCircle.doCreate
%     [indsSection C] = shapes.get_circle_inds(screen.surrDims , 500);
    [indsSection C] = shapes.get_circle_inds([screen.surrDims(1)] , ...
        outputTransCircle.diamPx,'center');
    transScrMtx = single(zeros(screen.surrDims));
    transScrMtx(indsSection) = 1;
    screen.objValueRGB = outputTransCircle.objectRGB;
    
else
    transScrMtx = single(ones(screen.surrDims));

end





SCREEN_SIZE = get(0,'ScreenSize');
% origScrHeight = SCREEN_SIZE(4);
% adjScrHeight =  round(SCREEN_SIZE(4)*1.7/1.6);
% SCREEN_SIZE(4) = adjScrHeight;
% screen.surrDims = SCREEN_SIZE;

% KbName('KeyNamesLinux') %run this command to get the
% names of the keys
if ismac
    RestrictKeysForKbCheck(44) % Restrict response to the space bar
else
    RestrictKeysForKbCheck(66) % Restrict response to the space bar
end

HideCursor
whichScreen = 0;
% do screen tests
Screen('Preference', 'SkipSyncTests',1)
% window = Screen('OpenWindow', whichScreen, [0 MID_GRAY_DECI*WHITE_VAL MID_GRAY_DECI*WHITE_VAL 0]);
[window screenRect] = Screen('OpenWindow', whichScreen, ...
    [0 0 0 0]);
% do not use red LED
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA,[0,1,1,0]);

objectMatrix = transScrMtx*screen.objValueRGB;
if outputTransCircle.doCreate
    objectMatrix(find(objectMatrix==0)) = outputTransCircle.bkndRGB;
end
transitionScreen = Screen(window, 'MakeTexture',  double(objectMatrix));
% % show screen
% Screen(window, 'DrawTexture', transitionScreen    );
% Screen(window,'Flip');
HideCursor
% Beeps & wait for keyboard input (space bar)



end