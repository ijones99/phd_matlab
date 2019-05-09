function plot_clusters(data, clusterAssigns, idxA, idxB, varargin)
% PLOT_CLUSTERS(data, clusterAssigns, idxA, idxB, varargin)

markerStyle = '*';
 
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'marker_style')
            markerStyle = varargin{i+1};
        end
    end
end



% number of clusters
nclass = length(unique(clusterAssigns));

% plot all clusters
colorMats = graphics.distinguishable_colors(nclass,[1 1 1]);

numParams = size(data,2);

hold on

for iClus = 1:size(colorMats,1)
    I = find(clusterAssigns==iClus); % I is index for current cluster
    
    plot(data(I,idxA),data(I,idxB),markerStyle,...
        'LineWidth',3,'Color',colorMats(iClus,:),'MarkerSize',3)
end

end