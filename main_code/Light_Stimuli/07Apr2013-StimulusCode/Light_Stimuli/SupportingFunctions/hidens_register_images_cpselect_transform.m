function hidens_register_images_cpselect_transform(search_str, varargin)


version=2;
%default fillcolor is white
fillvalue=255;
replacewith=254;
pixel_per_um=1;
transformationtype='';

i=1;
while i<=length(varargin)
    if strcmp(varargin{i}, 'resolution')
        i=i+1;
        pixel_per_um=varargin{i};
    elseif strcmp(varargin{i}, 'saveas')
        i=i+1;
    elseif strcmp(varargin{i}, 'version')
        i=i+1;
    	version=varargin{i};
    elseif strcmp(varargin{i}, 'black')
        fillvalue=0;
        replacewith=1;
    elseif strcmp(varargin{i}, 'transformation')
        i=i+1;
        transformationtype=varargin{i};    
    else
        fprintf('hidens_register_images_cpselect_transform: unknown argument at pos %d\n', 2+i);
    end
    i=i+1;
end
   

flist=get_list_of_files(search_str);
if isempty(flist)
    return
end

%generate hidens image
pos=hidens_get_all_electrodes(version, 1);
devsize=hidens_get_size(version);
hidens_img=hidens_create_chip_image(pos,pixel_per_um,devsize);

%
%registered=zeros([size(hidens_img,1) size(hidens_img,2) 3], 'uint8');

for i=1:length(flist)
    fprintf('processing file: %s\n', flist{i});
    
    %corresponding files
    [pathstr, name, ext, versn] = fileparts(flist{i});
    if isempty(pathstr)
        pathstr=pwd;
    end
    cpoints_filen=[pathstr '/transformed/' name '_cpoints.mat'];
    tform_filen=[pathstr '/transformed/' name '_transformed.jpg'];
    
    if not(exist([pathstr '/transformed'], 'dir'))
        mkdir([pathstr '/transformed']);
    end
    
    reply='N';
    if exist(tform_filen, 'file')
        default_ans='Y';
        quest=sprintf('Found old tranformed image, use as it is? Y/N [%s]: ', default_ans);
        reply = input(quest, 's');
        if isempty(reply)
            reply = default_ans;
        end
    end
    if reply=='N'
    
        I=imread(flist{i});
        %fillvalues
        %I(I==fillvalue)=replacewith;



        clear base_points
        clear input_points

        reply='N';
        if exist(cpoints_filen, 'file')
            default_ans='Y';
            quest=sprintf('Found corresponding control points, apply tranforamtion with those? Y/N [%s]: ', default_ans);
            reply = input(quest, 's');
            if isempty(reply)
                reply = default_ans;
            end
            load(cpoints_filen)
        end
        if reply=='N'
            evalin('base', 'clear base_points');
            evalin('base', 'clear input_points');
            reply='N';
            if exist('base_points', 'var')
                default_ans='Y';
                quest=sprintf('Load old corresponding control points? Y/N [%s]: ', default_ans);
                reply = input(quest, 's');
                if isempty(reply)
                    reply = default_ans;
                end
            end
            if reply=='Y'
                cpselect(hidens_img,I(:,:,2), base_points, input_points)
            else
                cpselect(hidens_img,I(:,:))
            end
            input('press Enter when finished with point selection')

            base_points=evalin('base', 'base_points');
            input_points=evalin('base', 'input_points'); 
%             save(cpoints_filen, 'base_points', 'input_points');
            cpstruct=evalin('base', 'cpstruct'); 
            save(cpoints_filen, 'base_points', 'input_points', 'cpstruct');
        
        end
        
        if isempty(transformationtype)
            nr_base_points=size(base_points, 1);
            if nr_base_points==2
                transformationtype='linear conformal';
            elseif nr_base_points==3
                transformationtype='affine';
            else
                transformationtype='projective';
            end
        end
        tform = cp2tform(base_points,input_points,transformationtype);
        registered = imtransform(I,tform,'FillValues', fillvalue,'XData', [1 size(hidens_img,2)],'YData', [1 size(hidens_img,1)], 'Size', [size(hidens_img,1) size(hidens_img,2)]);

        imwrite(registered, tform_filen);
        
    end
end















