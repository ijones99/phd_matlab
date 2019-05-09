%% 
cd /home/ijones/hima/recordings/Mea1k/shared/140605
clear all;close all;

recBaseDir = '/home/ijones/hima/recordings/Mea1k/shared/140605/';

%outBaseDir = [recBaseDir '131103/data_analysed/tonic718_try2_A3_spikeBand_filter/trial_1'];
%mkdir( outBaseDir );
%cfg_set = 1:68;

%% Load one file:
f_raw   = mea1k.file('', [recBaseDir 'data/0001.raw.h5'], '/sig' );
f_flt   = mea1k.file('', [recBaseDir 'analyzed_data/0001.spikeBand.filter.h5'], '/sig' );

map = mea1k.map(     [recBaseDir 'config/003.mapping.nrk'] );
X = f_flt.getData(20000*10+1,20000*15);    
figure;plot(X);

%% load many footprints

bp = mea1k.filter( 300 , 3000 , 8 );

Qa  = cell(1,24);
nx = cell(1,24);
ny = cell(1,24);

for fp = 0:23
    disp(fp)
    Z = scope.getTemplate( 'analyzed_data/many_footprints_2.h5' , fp );
    Qa{fp+1} = bp.bp( Z );
    attval = h5readatt('analyzed_data/many_footprints_2.h5',['/channelset' num2str(fp)],'Channels');      
    Q = Qa{fp+1};
    nx{fp+1}=double( attval(:,2));
    ny{fp+1}=double(attval(:,3));
end

%%
figure;hold on;
plot( nx{1} , ny{1} , 's' , 'MarkerEdgeColor',0.3*ones(1,3),...
    'MarkerFaceColor',[0.5 0.5 0.5])

for fp = [1 3 5 ]%length(Qa)
    Q = Qa{fp};
%    clf;jplot.templates( nx{fp+1} , ny{fp+1} , Q , 'YScale' , -3 )
%    mat = (max( Q ) - min( Q )) .* (max( Q ) + min(Q) );
    mat = max(Q)-min(Q);
%     jplot.chipArea( nx{fp}, ny{fp} , mat' )
    mat(mat>20) = 20;
    mat = mat + fp*20
    plot.plot_xyz_data(nx{fp}, ny{fp} , mat', 'n_contour_lines', 6 )
%    caxis( [0 10] )
    axis ij;
    axis equal;
end

axis off

%%
ok = args.ok;

hold on;
axis ij;
axis equal;

%%
figure;
axis ij;
axis equal;

col = lines( length(Qa));

    for i = 1:5 %length(Qa)
        Q = Qa{i};
        % args.TemplateLinesInsideContour == 1
        okInside = min( Qa{i}(10:70,:) ) < -4.5*1;
        xV = nx{i};
        yV = ny{i};
        aV = 1:size(Q,2);
        jplot.templates( xV(okInside), yV(okInside), ...
            Q(10:70,aV(okInside)) , ...
            'YScale', -0.6 , 'XScale', 0.4 , ...
            'LineWidth', 2,  'Color', col(i,:) );
        
        % args.ContourLines > 0
        jplot.contour( xV, yV, ...
            Q(1:90,:) , ...
            'YScale', -1 , 'XScale', 1 , ...
            'LinesAt', [13] , 'Resolution', 60, ...
            'LineWidth', 2 , ...
            'Color', col(i,:) , ...
            'ShowTraces' , false ,...
            'MaxDiameter', 100 , ...
            'SplitXAxis', false );

        % args.PlotIdxIntoCenter == 1
        [~,b] = sort( max( Q(20:90,:)) - min( Q(20:90,:) ) ,'descend' );
        xx = xV;
        yy = yV;
        cX = xx(b(1));
            cY = yy(b(1));
            text( cX, cY , num2str( i ) ,'FontSize', 27);

    end


%% amp map
x = map.mposx;
y = map.mposy;
z= max(X,[],1)-min(X,[],1);
z = double(z');
indRem = find(x==-1);
indAll = 1:1024;
indKeep = find(~ismember(indAll,indRem));
x(indRem) = [];%x(indRem(1)-1);
y(indRem) = [];%y(indRem(1)-1);
z(indRem) = [];%z(indRem(1)-1);
figure, hold on
plot(x,y,'s','MarkerEdgeColor',[0.5 0.5 0.5], 'MarkerFaceColor', [0.5 0.5 0.5]);
plot.plot_xyz_data(x,y,z), axis square

%% activity map
[I J] = spikes.findPeaks( X , 'th', -5 );

zRate = [];
for i=1:length(indKeep)
    zRate(i) = sum(ismember(J, indKeep(i)));
    progress_info(i, length(indKeep));
end

figure, hold on
plot(x,y,'s','MarkerEdgeColor',[0.5 0.5 0.5], 'MarkerFaceColor', [0.5 0.5 0.5]);
plot.plot_xyz_data(x,y,zRate'), axis square
%%
[Ipos Jpos] = spikes.findPeaks( X , 'th', -5 );

zRate = [];
for i=1:length(indKeep)
    zRatePos(i) = sum(ismember(Jpos, indKeep(i)));
    progress_info(i, length(indKeep));
end

figure, hold on
plot(x,y,'s','MarkerEdgeColor',[0.5 0.5 0.5], 'MarkerFaceColor', [0.5 0.5 0.5]);
plot.plot_xyz_data(x,y,zRatePos'), axis square
%%
% electrode map
figure, hold on
elNumber = indKeep;
elIdx = []
for i=1:length(indKeep)
    elIdx(i) = map.getEl(indKeep(i));
end
gui.plot_els_using_coord(map.mposx, map.mposy, 'marker_style','ks');
plot.plot_text_labels_on_meal1k(  map.mposx , map.mposy , [1:1024],'text_offset', [0.5,-0.5] );

for i = 1:length(stimEl)
elidxSel = find(elIdx == stimEl(i));
plot.plot_text_labels_on_meal1k(  map.mposx(elidxSel) , map.mposy(elidxSel) , 'o',...
    'text_offset', [0.5,-0.5],'color', 'g' );
end
%% find footprints
% amplitude map
jplot.chipArea( map.mposx , map.mposy , min(double(X))' );
jplot.text(  map.mposx , map.mposy , [1:1024] );



fP = {};
for ch = indKeep
    preTime  = 40;
    postTime = 40;

    templates = zeros(preTime+postTime+1,sum(J==ch));

    ps = I(J==ch);
    ps = ps(ps<20000-postTime);
    ps = ps(ps>preTime);
    V = zeros( (preTime+postTime+1) * 1024 , length(ps) );
    for j = 1:length(ps)
    	V(:,j) = reshape( X( (ps(j)-preTime):(ps(j)+postTime) , : ) , (preTime+postTime+1)*1024, 1 );
    end
    
    % make template
    fP{end+1} = reshape( median(V,2) , preTime+postTime+1 , 1024 );
    %fP{end+1} = reshape( mean(V,2) , preTime+postTime+1 , 1024 );
%clf;jplot.templates( 14* map.mposx , 10* map.mposy , fP{end} , 'Color' , C(i,:) , 'YScale', 1/3 )
    %clf;jplot.templates( 14* map.mposx , 10* map.mposy , fP{end} , 'YScale', 1/3 )

    progress_info(ch, 1024)
end

clf;
amp = zeros(1,length(indKeep));

for ch = 1:length(indKeep)
    amp(ch) = max( max(fP{ch})-min(fP{ch}) ) ;

end

%%

for ch = 1:length(indKeep)

    if amp(ch)>50
        
        h = figure;
        set(h, 'units', 'normalized', 'position', [0 0 0.9 0.8]);
        xlim([1000, 1700]);
        ylim([550, 1050])
        jplot.templates( 14* map.mposx , 10* map.mposy , fP{ch} , 'Color' , ...
            rand(1,3) , 'YScale', 1/3 ,'LineWidth', 2);
        axis square
        title(num2str(indKeep(ch)))
%         figure(gcf)
%         junk = input('press enter');
%         
    end
end

%% Load stim files

files={};

for idx = 1:3
    idx_str = num2str( idx-1, '%04d' );
    disp( idx_str );
    files{idx} = mea1k.file('', [recBaseDir 'analyzed_data/stim/' idx_str '.spikeBand.filter.h5'], '/sig' );
end
figure
jplot.chipArea( map.mposx, map.mposy , double( min( X((4e4+7153) :4e4+7180 ,: ) ) )' )


