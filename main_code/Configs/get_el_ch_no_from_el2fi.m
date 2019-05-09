function [elidxInFile chNoInFile] = get_el_ch_no_from_el2fi(dirName, el2fiName)

% all_els=hidens_get_all_electrodes(2);
elidxInFile = [];
chNoInFilx = [];

% check for suffix
if ~sum(strfind(el2fiName,'.el2fi.nrk2'));
    el2fiName = strcat(el2fiName,'.el2fi.nrk2');
    fprintf('Added suffix to el2fi name');
end

fid=fopen(fullfile(dirName,strcat(el2fiName)));

tline = fgetl(fid);
x= [];
i = 1;
while ischar(tline)
    [tokens] = regexp(tline, 'el\((\d+)\)', 'tokens');
    
    elidxInFile(i) = str2double(tokens{1});

    
    [tokens] = regexp(tline, '\((\w+), filter\)', 'tokens');
    stimFilter(i) = tokens{1};
    
    chNoInFile(i) = chName2chNo ( stimFilter{i} );
    
    tline = fgetl(fid);
    i=i+1; 
end

fclose(fid);

    
end