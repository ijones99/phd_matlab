%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Silhouette Play Ground Script to test & debug clustering
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%  Make 4 different gaussian noise clusters

X = [];

% the four cluster means, easy to cluster
centers = [ 1 1 ;
            5 5 ;
            1 5 ;
            5 1 ];

% four cluster means, hard to cluster
centers = [ 1     1 ;
            2.6   2.6 ;
            1     2.6 ;
            2.6   1 ];

for nClus = 1:4
    mu = centers( nClus , : );
    Sigma = [1 .5; .5 1.7];
    Sigma = [.2 .1; .1 .2];
    R = chol(Sigma);
    z = repmat(mu,100,1) + randn(100,2)*R;
    X = [X ; z ];
end

figure;plot(X(:,1) , X(:,2) , 'x' );

%% Here, we use kmeans to cluster the 4 clusters

sCoeff = zeros(1,10);
C      = zeros(size(X,1),10);

for numClusters = 1:10
    C(:,numClusters) = kmeans( X , numClusters );
    s = silhouette( X , C(:,numClusters) );
    sCoeff(1,numClusters) = median( s );
end

[~,bestNumClusters] = max( sCoeff );

figure; subplot( 1, 2, 1)

plot( 1:10 , sCoeff )
ylim( [0 1 ])

subplot( 1, 2, 2)
hold on;

color = hsv(bestNumClusters);
bestC = C(:,bestNumClusters);

for col = 1:bestNumClusters
    plot(X(bestC==col,1) , X(bestC==col,2) , 'x' , 'Color' , color( col, : ) );
end
axis equal

figure;silhouette( X , C(:,bestNumClusters) );


%% Since kmeans is pretty crappy and depends on the initial (random)
%  distribution of cluster centroids, we run it multipletimes and
%  the best run out of it.

sCoeff = zeros(1,10);
C      = zeros(size(X,1),10);

for numClusters = 1:10
    
    bestS = 0;
    for run = 1:10
        Ctmp = kmeans( X , numClusters , 'emptyaction','singleton' );
        s = median( silhouette( X , Ctmp ) );
        if s>bestS
            bestS = s;
            C(:,numClusters) = Ctmp;
            sCoeff(1,numClusters) = s;
        end
    end

end

[~,bestNumClusters] = max( sCoeff );

figure; subplot( 1, 2, 1)

plot( 1:10 , sCoeff )
ylim( [0 1 ])
grid on

subplot( 1, 2, 2)
hold on;

color = hsv(bestNumClusters);
bestC = C(:,bestNumClusters);

for col = 1:bestNumClusters
    plot(X(bestC==col,1) , X(bestC==col,2) , 'x' , 'Color' , color( col, : ) );
end
axis equal



