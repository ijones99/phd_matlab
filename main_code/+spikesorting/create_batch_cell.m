function batchData = create_batch_cell(stimTypes)
% batchData = CREATE_BATCH_CELL(stimTypes)
%


inputArg = 0;
iBatch = 1;
while ~strcmp(inputArg,'d') % for the run number
    inputArg = input('New Group: enter stim run number >>','s'); % run number
    runNo = str2num(inputArg);
    batchData{iBatch}.runNo = runNo;
    if strcmp(inputArg,'d')
        break
    end
    while ~strcmp(inputArg,'d') | ~strcmp(inputArg,'r') % for stim type
        for i=1:length(stimTypes)
            fprintf('(%d) %s\n', i, stimTypes{i});
        end
        inputArg = input('Enter stimType >>','s'); % flist number
        if strcmp(inputArg,'r') | strcmp(inputArg,'d')
            break
        end
        stimType = stimTypes{str2num(inputArg)};
        
        
        while ~strcmp(inputArg,'r') % for flist
            % flist data
            %              fileIdx = [];
            %              finishSel = 'n'
            %              while strcmp(finishSel,'n')
            [fileIdx flistNames]= filenames.select_flist_name;
            %                  finishSel = input('done? [enter for "yes"/"n" for "no"]');
            %              end
            
            inputArg = fileIdx;
            if strcmp(inputArg,'r') | strcmp(inputArg,'d')| strcmp(inputArg,'s')
                break
            end
          inputArgNum = inputArg;
            batchData{iBatch}.runNo = runNo;
            for iFlist = 1:length(inputArgNum)
                batchData{iBatch}.flist{iFlist} = ['../proc/', flistNames(inputArgNum(iFlist)).name];
            end
            batchData{iBatch}.stimType= stimType;
            %             flistNo = str2num(inputArg);
            %             batchData{iBatch}.flistNo = flistNo;
            batchData{iBatch}.elIdxCtr = input('Enter elIdx >>'); % flist number
            iBatch = iBatch+1;
        end
  
    end
end

end