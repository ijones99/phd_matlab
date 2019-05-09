fname = '/home/jamuelle/xxx/0080.spikeBand.filter.h5';
mapName = '/home/jamuelle/xxx/config8.mapping.nrk';
f = mea1k.file( fname );
m = mea1k.map( mapName );

X = f.getData( 1 , 12 * 20000 );

figure;plot(X(:,609+1))
trace = X(:,610);

[I J] = spikes.findPeaks( trace );

M1 = f.getCutoutsAllNoFilt( I , 50 , 200  );
M2 = reshape ( M1 , size(M1,1)/1024 , 1024 , size(M1,2) );
M3 = ( squeeze ( median( M2 , 3 ) ) );

figure;plot(M3)

jplot.templates( m.mposx, m.mposy, M3 )
jplot.templates( m.mposx, m.mposy, M3 )

%%
clf;
axis ij;
axis equal;
jplot.templates( m.mposx, m.mposy , ...
    M3(45:100,:) , ...
    'YScale', -1/15.0 , 'XScale', 1/70.0 , ...
    'LineWidth', 2, 'Color', [0 0 0] );

%%



clf
ok = 1:1024
colors = jet
jplot.templatesFigure( ...
    m.mposx, m.mposy, M3, 1:length(M3) , ...
    'ContourLines' , 2 , ...
    'TemplateLinesInsideContour' , 1 ,...
    'TemplateLines' , 2 ,...
    'YScale', -1/150, ...
    'ColorMap', colors, ...
    'Axes' , gca , ...
    'ok' , ok );


size(I)


