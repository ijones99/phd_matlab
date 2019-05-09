function convert_ntk2_files_to_h5(expDirNames);
roskaProcDir = '/net/bs-filesvr01/export/group/hierlemann/recordings/HiDens/Roska';
expDirNames = { ...
%     '30Oct2012'; ...
%     '20Dec2012'; ...
%     '13Dec2012_2'; ...
%     '13Dec2012'; ...
%     '27Nov2012'; ...
%     '21Aug2012'; ...
%     '07Aug2012'; ...
%     '03Aug2012'; ...
'10Apr2013';
    }

for i=1:length(expDirNames)
    tic
    % set proc dir location
    dirProc = fullfile( roskaProcDir,expDirNames{i},'proc/')
    
    % set hdf dir location
    dirHdf5 = fullfile( roskaProcDir,expDirNames{i},'hdf5/')
    
    % make directory for hdf files
    mkdir(dirHdf5);
    
    % get proc file names
    ntkFileName = dir(fullfile(dirProc,'Trace*ntk'));
    
    % convert each proc file
    for iNtkFile = 1:length(ntkFileName)
        % set flist variable (name of ntk file)
        selNtkFileName{1} = strcat('../proc/', ntkFileName(iNtkFile).name);
        % get name of output hdf5 file
        outfile = fullfile(dirHdf5, strrep(ntkFileName(iNtkFile).name,'ntk','h5'));
        % First step, convert ntk files to a single h5 file
        mysort.mea.ntk2hdf(dirProc, selNtkFileName, outfile);
        
    end
    % Now convert using all ntk files together
    % make flists
    flist = {};
    for iNtkFile = 1:length(ntkFileName)
        flist{iNtkFile} = strcat('../proc/', ntkFileName(iNtkFile).name);
        
    end
    
    % get name of output hdf5 file
    outfile = fullfile(dirHdf5, 'config01.stream.h5');
    % First step, convert ntk files to a single h5 file
    mysort.mea.ntk2hdf(dirProc, flist, outfile);
    fprintf('Experiment %d of %d done\n', i,length(expDirNames));
    toc
end






