function save_sta_data(ts_white_noise, path_frames, neuronNumber)
global  mainDirPath analyzedDataDirPath electrodeOfInterest
%   plot_sta(ts_white_noise,path_frames,...)
%   ts_white_noise = time stamps of your neuron
%   path_frames = where you stored your frames, example 'home/michelef/..'

neuron_image_frames=[double(ts_white_noise)];
ts_RGC=neuron_image_frames;
SpikeHistory=[];
n_frames_befor_spikes=25;

ts_RGC(find(ts_RGC<n_frames_befor_spikes))=[];    %ensure there are no ind that will give 0 values
SpikeHistory = zeros(length(ts_RGC), 1); %init spike history matrix
SpikeHistory(:,1) = ts_RGC-n_frames_befor_spikes;
SpikeHistory = repmat(SpikeHistory, 1,n_frames_befor_spikes+1); %create matrix ts by duplicates
addSteps = [0:size(SpikeHistory,2)-1]; 
addSteps = repmat(addSteps,size(SpikeHistory,1),1);
SpikeHistory = SpikeHistory+addSteps;
load (path_frames)
oneD_image = int8([]);

for i=1:size(SpikeHistory,2)
    frameInd = SpikeHistory(:,i);
    frameInd(find(frameInd==0))=[];
    spike_movie=saved_frames(:,:,frameInd);
    
    i
    for j=1:length(spike_movie)
        %         oneD_image=reshape(flipud(rot90(spike_movie(:,:,j))),size(spike_movie,1)*size(spike_movie,1),1);
        oneD_image=reshape(((spike_movie(:,:,j))),size(spike_movie,1)*size(spike_movie,1),1);
        oneD_image=int8(oneD_image);
        
        %         oneD_image(find(oneD_image==0))=-1;
        oneD_matrix(:,j)=oneD_image;
    end
    oneD_matrix(find(oneD_matrix==0))=-1;
    final_spike_movie(:,i)=mean(oneD_matrix,2);
end

for i=1:size(final_spike_movie,2)
    twoD_image=reshape(final_spike_movie(:,i),size(spike_movie,1),size(spike_movie,1));
    if i==1
        twoD_movie=twoD_image;
    else
        twoD_movie(:,:,i)=twoD_image;
    end
end
%save sta data
save(fullfile(analyzedDataDirPath,strcat('sta',num2str(electrodeOfInterest),'Neuron',num2str(neuronNumber),'.mat')),'twoD_movie','-v7.3');

