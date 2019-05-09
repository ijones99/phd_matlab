function sort_cluster_based(expName, flist, groups, spikeSortingRunName )
% set name of experiment
ename = expName;
egroup = 'Roska';
% load configuration file

if nargin < 4
    spikeSortingRunName = 'run_01';
end
% set some paths
spsort_path = '/net/bs-filesvr01/export/group/hierlemann/recordings/HiDens/SpikeSorting';
% spsort_path = '/links/groups/hima/recordings/HiDens/SpikeSorting/';
dpath = '/net/bs-filesvr01/export/group/hierlemann/recordings/HiDens/'; %~/bel.svn/hima_internal/cmosmea_recordings/trunk/
group_dpath = fullfile(dpath, egroup);
exp_dpath = fullfile(group_dpath, ename);
ntk_dpath = fullfile(exp_dpath, 'proc');

% Check if output directory exists
spsort_out_path = fullfile(spsort_path, egroup, ename);

%%
C.flist = flist;  
% First step, convert ntk files to a single h5 file
for i=1:length(C.flist)
    % Convert ntk 2 hdf5
    [PATH,NAME,EXT] = fileparts(C.flist{i});
    ntkfile = [NAME EXT];
    hd5file = fullfile(spsort_out_path, [NAME '.h5']);
    gdffile = fullfile(spsort_out_path, [NAME '.gdf']);
    spath = fullfile(spsort_out_path, NAME, 'sortings');
    if ~exist(spath, 'file')
        mkdir(spath);
    end    
    mysort.mea.ntk2hdf(ntk_dpath, ntkfile, hd5file, 'writelog', true);
    
    % build mea object
    sessionmea = mysort.mea.CMOSMEA(hd5file, 'hpf', 350, 'lpf', 8000, 'filterOrder', 6);
    % prefilter
    sessionmea.prefilter();
    
    % build local electrode neighborhoods that will be sorted together
    ME = sessionmea.getMultiElectrode();
    %     [groupsidx nGroupsPerElectrode] = mysort.mea.constructLocalElectrodeGroups(ME.electrodePositions(:,1), ME.electrodePositions(:,2));
    
    % replace electrode indices with electrode numbers
    
    for ii=1:length(groups)
        
        groupsidx{ii} = find(ismember(ME.electrodeNumbers,groups{ii}));
%         groups{ii} = ME.electrodeNumbers(groupsidx{ii});
    end
%     groups = groupsidx;
    % sort
    try
        numCPUs = 4;
        ana.sortConfig(spath, sessionmea, 1, groups, groupsidx, spikeSortingRunName,numCPUs,1);
    catch
        p = mfilename('fullpath');
        writeMsg = sprintf('spath %s', spath);
        ifunc.log.write_to_log_file(p, writeMsg);
        %         mysort.util.logToFile('log.txt', ['iteration: ' num2str(i)]);
        %         mysort.util.logLastErrToFile('log.txt');
    end
end
end
