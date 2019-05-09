function uniqueNeurons = find_unique_neurons(flistName, varargin)

idNameStartLocation = strfind(flistName{1},'T');idNameStartLocation(1)=[];
flistFileNameID = flistName{1}(idNameStartLocation:end-11);

filesSelInDir = [];
neuronsIndSel = 0;
binWidthMs = 1;
matchingThresh = 0.1;
i=1;
while i<=length(varargin)
    if not(isempty(varargin{i}))
        if  strcmp(varargin{i},'add_dir_suffix')
            clear flistFileNameID;
            flistFileNameID = strcat(flistName{1}(idNameStartLocation:end-11),varargin{i+1});
        elseif  strcmp(varargin{i},'bin_width')
            binWidthMs = varargin{i+1};
        elseif  strcmp(varargin{i},'matching_thresh')
            matchingThresh = varargin{i+1};
        else
            fprintf('unknown argument at pos %d\n', 2+i);
        end
    end
    i=i+1;
end


% get a heatmap of matches (always comapred to the row neurons as a ground
% truth)
[heatMap, neuronTs] = get_heatmap_of_matching_ts(binWidthMs, flistFileNameID  );

[rows,cols,vals] = find(heatMap>matchingThresh);




end

