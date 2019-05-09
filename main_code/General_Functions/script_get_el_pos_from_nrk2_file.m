el=hidens_get_all_electrodes(2)

fileDir = '/home/ijones/Experiments/Configs/Rec/Aperture_Exp/center6x18sp1_PeriphDiagLine/';
fileName = 'center6x18sp1_PeriphDiagLine_Right.el2fi.nrk2'
%%
selElIds = [];

fid=fopen(fullfile(fileDir, fileName),'r');

% get electrode id numbers
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    elInfoLoc = strfind(tline, 'el(')+3;
    selElIds(end+1) = str2num(tline(elInfoLoc:elInfoLoc+3));
end
fclose(fid);

%% get x and y coords
elX=[]; elY=[];
for i=1:length(selElIds)
    infoInd = find(el.el_idx == selElIds(i));
    elX(end+1) = el.x(infoInd);
    elY(end+1) = el.y(infoInd);
end

%% plot electrodes
figure
plot(elX,elY,'*'), hold on
text(elX, elY,num2str([1:length(selElIds)]'))



%% get middle value (true, as seen on camera)
meanX = mean(elX)/0.972;
meanY = mean(elY)/1.05248955223881;