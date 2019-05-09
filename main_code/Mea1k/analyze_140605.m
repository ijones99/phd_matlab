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
X = f_flt.getData(1,20000);    
figure;plot(X);

%% find footprints
% amplitude map
jplot.chipArea( map.mposx , map.mposy , min(double(X))' );
jplot.text(  map.mposx , map.mposy , [1:1024] );

[I J] = spikes.findPeaks( X , 'th', -5 );

fP = {};
for ch = 1:1024
    preTime  = 80;
    postTime = 80;

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
amp = zeros(1,1024);
for ch = 1:1024
    amp(ch) = max( max(fP{ch})-min(fP{ch}) ) ;
end

%%
figure
for ch = 1:1024
    if amp(ch)>50
        disp(ch)
        jplot.templates( 14* map.mposx , 10* map.mposy , fP{ch} , 'Color' , rand(1,3) , 'YScale', 1/3 )
    end
end

%% Load stim files

files={};

for idx = 1:3
    idx_str = num2str( idx-1, '%04d' );
    disp( idx_str );
    files{idx} = mea1k.file('', [recBaseDir 'analyzed_data/stim/' idx_str '.spikeBand.filter.h5'], '/sig' );
end

jplot.chipArea( map.mposx, map.mposy , double( min( X((4e4+7153) :4e4+7180 ,: ) ) )' )


