function [ elConfigInfo ] = get_el_pos_from_nrk2_file(varargin)
%  nrkFileName,  fileDir
% fileDir = '/home/ijones/Experiments/Configs/Rec/Aperture_Exp/center6x18sp1_PeriphDiagLine/';
% nrkFileName = 'center6x18sp1_PeriphDiagLine_Left.el2fi.nrk2'

% Note!! Be sure that you are using the correct version of
% "hidens_ask_emulator.m"

% init vars
fileDir='../Configs/'; nrkFileName={};
flist = '';
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'file_dir')
            fileDir = varargin{i+1};
        elseif strcmp( varargin{i}, 'file_name')
            nrkFileName = varargin{i+1};
        elseif strcmp( varargin{i}, 'flist')
            flist = varargin{i+1};    
        end
    end
end

if isempty(nrkFileName)
    nrkFileName = '*.hex.nrk2';
end
if isempty(fileDir)
    fileDir = '../Configs/';
end

% check for nrkfile
if isempty(nrkFileName)
    nrkFileName = dir(fullfile(fileDir,[nrkFileName ]));
else
nrkFileName = dir(fullfile(fileDir,strcat(nrkFileName)));
end
% nrkfile error
if isempty(nrkFileName) || length( nrkFileName) > 1
    fprintf('Ensure that proper nrk2 file is in Configs directory\n');
    return;
    
else
    nrkFileName = nrkFileName(1).name;
end

el=hidens_get_all_electrodes(2);
elConfigInfo.selElNos = [];

fid=fopen(fullfile(fileDir, nrkFileName),'r');

% get electrode id Nos
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    elInfoLoc = strfind(tline, 'el(')+3;
    if ~isempty(str2num(tline(elInfoLoc:elInfoLoc+3)))
        elConfigInfo.selElNos(end+1) = str2num(tline(elInfoLoc:elInfoLoc+3));
    end
end
fclose(fid);

%% get x and y coords
elConfigInfo.elX=[]; elConfigInfo.elY=[];
for i=1:length(elConfigInfo.selElNos)
    infoInd = find(el.el_idx == elConfigInfo.selElNos(i));
    elConfigInfo.elX(end+1) = el.x(infoInd);
    elConfigInfo.elY(end+1) = el.y(infoInd);
end

elConfigInfo.allElNos = el.el_idx;
elConfigInfo.allElX = single(el.x);
elConfigInfo.allElY = single(el.y);

if ~isempty(flist)
    if iscell(flist)
        elConfigInfo.selChNos = convert_el_numbers_to_chs(flist{1}, elConfigInfo.selElNos);
    else
        elConfigInfo.selChNos = convert_el_numbers_to_chs(flist, elConfigInfo.selElNos);
    end
end
% %% plot electrodes
% figure
% plot(elConfigInfo.elX,elConfigInfo.elY,'*'), hold on
% text(elConfigInfo.elX, elConfigInfo.elY,num2str([1:length(elConfigInfo.selElNos)]'))
%
%
% 
% %% get middle value (true, as seen on camera)
% meanX = mean(elConfigInfo.elX)/0.972;
% meanY = mean(elConfigInfo.elY)/1.05248955223881;


end