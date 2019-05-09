%% find stimulation channel of interest
searchCh = [50];

for i=1:length(settings.stimCh)
    if length(searchCh)>1
        if length(settings.stimCh{i}) > 1
            if settings.stimCh{i}(1) == searchCh(1) && settings.stimCh{i}(2) == searchCh(2)
                
                fprintf('ind = %d: [', i)
                for j=1:length(settings.stimCh{i})
                    fprintf('%d ', settings.stimCh{i}(j))
                end
                fprintf(']\n');
            end
        end
    else
        if settings.stimCh{i}(1) == searchCh(1)
            fprintf('ind = %d: [', i)
            for j=1:length(settings.stimCh{i})
                fprintf('%d ', settings.stimCh{i}(j))
            end
            fprintf(']\n');
        end
        
    end
    
end