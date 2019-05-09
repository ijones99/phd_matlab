function rgcs2 = filter_based_sort_ums_output(flistName, rgcs2, varargin)
% sort_ums_output(flistName, varargin)


global spikes_saved    
selInds = [];
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'sel_inds')
            selInds = varargin{i+1};
          
        end
    end
end

if selInds == []
indsToLoopThrough = 1:length(rgcs2)    
end

for i=1:indsToLoopThrough 
    eval(['splitmerge_tool(', rcgs{i} ,')']);
    set(gcf,'name',num2str(i),'numbertitle','off')
    % wait for user input after sorting
    
    fprintf('File %d of %d done\n', i , length(fileNames));
    aa = input('Save and proceed?');
    rgcs2{i} = spikes_saved;
end








eval([outputStructName,'=spikes_saved;']);


close all


end