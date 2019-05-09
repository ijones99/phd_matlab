function stimChNo = elidx2ch(el2fiName, elidxInput)
% stimChNo = ELIDX2CH(el2fiName, elidx)


fid=fopen(el2fiName);
elidx=[];

tline = fgetl(fid);
x= [];
while ischar(tline)
    [tokens] = regexp(tline, 'el\((\d+)\)', 'tokens');
    
    extractedElNo = str2double(tokens{1});
    elidx(end+1)= extractedElNo;
    for i=1:length(elidxInput)
        if extractedElNo==elidxInput(i)
            [tokens] = regexp(tline, '\((\w+), filter\)', 'tokens');
            stimFilter(i) = tokens{1};
        end
    end
    tline = fgetl(fid);
end

fclose(fid);

if exist('stimFilter')
    
    for i=1:length(elidxInput)
        stimChNo(i) = chName2chNo ( stimFilter{i} );
    end
    
else
    
    fprintf('Stim channel not found in el2fi file, %s.\n', el2fiName)

end