function show_labeled_electrodes(elConfigInfo )
% show_labeled_electrodes(elConfigInfo )
% Plots electrode configuration from nrk
% file
% 

% init vars
selectedPatches = {};

% set up figure
fullscreen = get(0,'ScreenSize');
figure('Position',[0 -50 fullscreen(3) fullscreen(4)])
hold on

plot(elConfigInfo.elX,elConfigInfo.elY,'*')
set(gca,'YDir','reverse')
text(elConfigInfo.elX+0.5, elConfigInfo.elY,num2str([elConfigInfo.selElNos']));
title('Electrode Number')


end