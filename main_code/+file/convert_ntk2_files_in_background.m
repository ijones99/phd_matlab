function convert_ntk2_files_in_background(checkInterval)
% CONVERT_NTK2_FILES_IN_BACKGROUND(checkInterval)

if nargin < 1
    checkInterval = 120;
end
dirPath = '../proc/';

pause(checkInterval );
fprintf('Waiting...\n')
while 1==1
    try
    % get file names
    fileNamesNtk = get_file_names_from_dir(dirPath, '*.ntk');
    fileNamesH5 = get_file_names_from_dir(dirPath, '*.h5');
    
    fileNamesNtk = strrep(fileNamesNtk,'.ntk','');
    fileNamesH5 = strrep(fileNamesH5,'.h5','');
    
    % check list for nonconverted files
    nonconvertedFileIdx = find(~ismember(fileNamesNtk,fileNamesH5));
    
    % num nonconverted files
    numNonConvertedFiles = length(nonconvertedFileIdx);
    
    % get last file size
    if numNonConvertedFiles > 0
        flistLast = sprintf('../proc/%s.ntk', fileNamesNtk{nonconvertedFileIdx(end)});
        infoLastFileFirstCheck = dir(flistLast);
        sizeLastFile = [];
        sizeLastFile(1) = infoLastFileFirstCheck.bytes;
    end
    
    % if there are files to be converted, convert all except for the
    % last, since the last may still be in save-to-disk mode.
    for i=1:numNonConvertedFiles-1
        %flist name
        flist = sprintf('../proc/%s.ntk', fileNamesNtk{nonconvertedFileIdx(i)});
        %         try
        mysort.mea.convertNTK2HDF(flist,'prefilter', 1);
        fprintf('Converted file %s.\n', flist)
        %         catch
        %             fprintf('Already converted file %s.\n', flist)
        %         end
        
    end
    
    % wait
    pause(checkInterval);
    fprintf('Waiting...\n')
    
    if numNonConvertedFiles > 0
        % check last file to see if it's grown
        infoLastFileSecondCheck = dir(flistLast);
        sizeLastFile(2) = infoLastFileSecondCheck.bytes;
        
        % if no change in size, convert
        if sizeLastFile(1) == sizeLastFile(2)
            try
                mysort.mea.convertNTK2HDF(flistLast,'prefilter', 1);
                fprintf('Converted file %s.\n', flistLast)
            catch
                fprintf('Already converted file %s.\n', flistLast)
            end
            
        end
        
    end
    catch
       fprintf('Error.\n');
    end
    
end


end