function z = get_latency(wfs,thresh)
% 
Fs=2e4;
interpMult=8;
edges = linspace(1,size(wfs,2), size(wfs,2)*interpMult);
% center waveforms
wfsBL = median(wfs(:,1:5),2);
wfsC = wfs-repmat(wfsBL,1,size(wfs,2));

% find wfs under threshold
idxVal = find(min(wfsC,[],2)<=thresh);

I = nan(1,size(wfsC,1));
% figure, hold on

for i=1:length(idxVal)%1:size(wfs,1) % note, must invert for findpeaks()
    
    %     hold off
    currWf = -wfsC(idxVal(i),:);
    
    currWfInterp1 = interp(currWf,interpMult);
    
    [pks,currLoc1] = findpeaks( ...
        currWfInterp1 ,'minpeakheight',-thresh,'npeaks',1);

    
    if ~isempty(currLoc1)
        I(idxVal(i)) = edges(currLoc1);
    end

end

z = double((I-min(I))*1/(Fs/1e3));

end


% Fs=2e4;
% interpMult = 3;
% % center waveforms
% wfsBL = median(wfs(:,1:5),2);
% wfsC = wfs-repmat(wfsBL,1,size(wfs,2));
% 
% % find wfs under threshold
% idxVal = find(min(wfsC,[],2)<=thresh);
% 
% I = nan(1,size(wfsC,1));
% 
% for i=1:length(idxVal)%1:size(wfs,1) % note, must invert for findpeaks()
%     hold off
%     
%     currWf = -wfsC(idxVal(i),:);
%     currWfInterp = interp(currWf,interpMult);
%     
%     [pks,currLoc] = findpeaks( ...
%         currWfInterp ,'minpeakheight',-thresh,'npeaks',1);
%     if ~isempty(currLoc)
%         I(idxVal(i)) = currLoc/interpMult;
%     end
%     %     plot(wfsC(idxVal(i),:)), hold on
%     %     plot(currLoc,-pks,'ko');
%     %     pause(0.2);
% end
% 
% 
% 
% z = double((I-min(I))*1/(Fs/1e3));
% 

% end