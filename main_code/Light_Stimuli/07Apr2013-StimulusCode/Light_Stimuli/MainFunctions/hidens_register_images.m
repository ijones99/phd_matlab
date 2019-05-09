function y=hidens_register_images(search_str, varargin)

in_varargin=varargin;

save_as='';
%default fillcolor is white
fillvalue=255;
replacewidth=254;
transormationtype='';  %'linear conformal' (>=2pts), 'affine' (>=3pts), 'projective' (>=4pts)
                       %default is projective
                       
passargs={};                      

i=1;
while i<=length(varargin)
    if strcmp(varargin{i}, 'resolution')
        i=i+1;
        passargs{end+1}='resolution';
        passargs{end+1}=varargin{i};
    elseif strcmp(varargin{i}, 'saveas')
        i=i+1;
    	save_as=varargin{i};
    elseif strcmp(varargin{i}, 'version')
        i=i+1;
        passargs{end+1}='version';
        passargs{end+1}=varargin{i};
    elseif strcmp(varargin{i}, 'black')
        fillvalue=0;
        replacewidth=1;
    elseif strcmp(varargin{i}, 'transformation')
        i=i+1;
        passargs{end+1}='transformation';
        passargs{end+1}=varargin{i};
    else
        fprintf('hidens_register_images: unknown argument at pos %d\n', 2+i);
    end
    i=i+1;
end
   

%get control points and transform images
hidens_register_images_cpselect_transform(search_str, in_varargin{:}, passargs{:});


merged=hidens_register_images_merge(search_str, fillvalue);

if not(isempty(save_as))
    if not(exist('reg_pics', 'dir'))
        mkdir('reg_pics');
    end
    imwrite(merged, ['reg_pics/' save_as '.jpg']);
end
















