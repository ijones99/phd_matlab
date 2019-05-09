function y=hidens_register_images_merge(search_str, fillvalue)




flist=get_list_of_files(search_str);
if isempty(flist)
    return
end

%now merging images

for i=1:length(flist)
    %load file
    %corresponding files
    [pathstr, name, ext, versn] = fileparts(flist{i});
    if isempty(pathstr)
        pathstr=pwd;
    end
    cpoints_filen=[pathstr '/transformed/' name '_cpoints.mat'];
    tform_filen=[pathstr '/transformed/' name '_transformed.jpg'];
    
    fprintf('processing file: %s - ', tform_filen);
    
    if exist(tform_filen, 'file')
        reg=imread(tform_filen);
        fprintf('loaded\n');
        
        if i==1
            merged=reg;
        else
            if not(all(size(reg)==size(merged)))
                fprintf('loaded image size does not match, skip\n');
            else
                merged=merged.*uint8(merged~=fillvalue)+reg.*uint8(merged==fillvalue);
                
            end
        end
    else
        fprintf('does not exist\n');
    end
end


y=merged;















