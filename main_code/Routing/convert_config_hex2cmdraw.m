function convert_config_hex2cmdraw(dirName, fName)
% convert_config_hex2cmdraw(dirName, fName)
%
% dirName: directory where config is
% fName: name of config file

    cmd=(['BitStreamer -n -f ' dirName fName '.hex.nrk2']);
    system(cmd) 

end