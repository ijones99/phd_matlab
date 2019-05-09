function send_config_to_chip(dirName, fName, clientAddress, clientPort)
% send_config_to_chip(dirName, fName)
%
% dirName: directory where config is
% fName: name of config file
% clientAddress: 11.0.0.7
% clientPort: 32124

if nargin < 4
    clientPort = '32124';
elseif nargin < 3
    clientAddress = '11.0.0.7';
end
%remove superfluous prefix
if ~isempty(strfind(fName,'.cmdraw.nrk2'))
    strrep(fName,'.cmdraw.nrk2','');
end

cmd=(['nc 11.0.0.7 32124 < ' dirName fName '.cmdraw.nrk2']);
    system(cmd);


end