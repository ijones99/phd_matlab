function [elsInPatch chsInPatch indsInPatch] = get_electrodes_sorting_patches(ntk2, numElsInPatch)
% function get_electrode_list(directoryName,flistName)
%
%load data

sortingPatchs = {};
elsInPatch = {};
indsInPatch = {};
chsInPatch = {};
fname = ntk2.fname;
ntk2Chs = ntk2.channel_nr;
% siz = 5000; % how many samples of data to load (30 s)
% ntk=initialize_ntkstruct(fname, 'hpf', 500, 'lpf', 3000);
% [ntk2 ntk]=ntk_load(ntk, siz);
plot(ntk2.x, ntk2.y, '*b'), hold on
% declare colormap
cmap = colormap('jet');

% step size in colormap
colorStepSize = ceil(length(cmap)/20);

electrodesRmdr = ntk2.el_idx;
i=1;
while size(electrodesRmdr,2) ~= 0
    
    % at the end of the run, there may be a patch with fewer electrodesRmdr
    % than the selected number
    if length(electrodesRmdr) < numElsInPatch
        numElsInPatch = length(electrodesRmdr);
    end
    
    % Find ntk2 index of first value in electrodesRmdr variable
    ntkIndNum = find(electrodesRmdr(1)==ntk2.el_idx);
    
    % get all distances between selected electrode and other electrodesRmdr
    interElDist = sqrt((ntk2.x(ntkIndNum)-ntk2.x).^2+ (ntk2.y(ntkIndNum)-ntk2.y).^2 );
    
    % sort electrode distances from small to large
    [Y,I] = sort(interElDist);
    
    % select electrodesRmdr in patch
    elsInPatch{end+1} = ntk2.el_idx(I(1:numElsInPatch));
    chsInPatch{end+1} = ntk2.channel_nr(I(1:numElsInPatch));
    
    indsInPatch{end+1} = I(1:numElsInPatch);
    I(1:numElsInPatch)
    plot(ntk2.x(indsInPatch{i}), ntk2.y(indsInPatch{i}), '*r')
    plot(ntk2.x(indsInPatch{i}(1)), ntk2.y(indsInPatch{i}(1)), '*g')
    
    electrodesRmdr(I(1:numElsInPatch)) = [];
    ntk2.x(I(1:numElsInPatch))=[];
    ntk2.y(I(1:numElsInPatch))=[];
    ntk2.el_idx(I(1:numElsInPatch))=[];
    ntk2.channel_nr(I(1:numElsInPatch))=[];
    
    
    [Y indsInPatch{i}] = ismember(chsInPatch{i},ntk2Chs )
    i=i+1;
    

    
end

end