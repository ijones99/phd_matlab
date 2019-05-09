function neuronsCollected = batch_merge_neurons(fname, interactiveSel)

% interactiveSel = 1; % interactive merging

procDirName = '../proc/';
neuronsFileNames = dir(strcat(procDirName,'neurons_*',fname(end-21:end-11),'*.mat'));


load(fullfile(procDirName,neuronsFileNames(1).name));
neuronsCollected = neurons; clear neurons;

for i=2:length(neuronsFileNames)
    i
    if exist('neurons')
        
        clear neurons;
    end
    
    load(fullfile(procDirName,neuronsFileNames(i).name));
    try
        
        if interactiveSel == 1
            neuronsCollected = merge_neurons( [neuronsCollected neurons],'interactive',1   );
        else
            
            neuronsCollected = merge_neurons( [neuronsCollected neurons] );
        end
    catch
        fprintf('Error merging file %s\n',neuronsFileNames(i).name )
    end
    progress_bar((i)/length(neuronsFileNames), 1, strcat('Merging clusters:', num2str(i),'/', num2str(length(neuronsFileNames)),'clusters processed)'));
end


end