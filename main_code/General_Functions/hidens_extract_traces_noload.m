function y=hidens_extract_traces_noload(neurons, ntk2, varargin)
%
%
% loops through all specified neurons and reextract the spike traces from
% the *.stream.ntk files.
%
% This function can take 
%   * old neurons-structure (incl. tbase)
%   * new neurons-structure (without tbase)
% as an input. However, it will always generate the new neurons-structure
% without tbase.
%
% it replaces the old traces
%
% args:
%
% ['neurons', n_list]
%       list of neuron idx (if not spec, all are processed)  
% ['eventparam', param]
%       timing info for event extraction, (if not specified the event_param
%       from the old neurons is used)
% ['chunk', chunk_size]
%       if not specified 10s blocks are loaded
% ['nomargin']
%       don't extract margin
%
% ['simplify']
%       reduce traces, so that only templates are stored to reduce filesize,
%       with simplify_traces

y=neurons;


n_list=1:length(neurons);
event_param=[];
load_chunk_size=200000;
extract_margin=1;
simplify=0;
do_time_align=0;
no_detect_valid_channels=0;

passargin={};

i=1;
while i<=length(varargin)
    if not(isempty(varargin{i}))
        if strcmp(varargin{i}, 'neurons')
            i=i+1;
            n_list=varargin{i};    
        elseif strcmp(varargin{i}, 'eventparam')
            i=i+1;
            event_param=varargin{i};    
        elseif strcmp(varargin{i}, 'chunk')
            i=i+1;
            load_chunk_size=varargin{i};    
        elseif strcmp(varargin{i}, 'nomargin')
            extract_margin=0;  
        elseif strcmp(varargin{i}, 'simplify')
            simplify=1;
        elseif strcmp(varargin{i}, 'time_align')
            do_time_align=1;
        elseif strcmp(varargin{i}, 'no_detect_valid_channels')
            no_detect_valid_channels=1;
        elseif strcmp(varargin{i}, 'filter')
            passargin{end+1}='filter';
            i=i+1;
            passargin{end+1}=varargin{i};
        elseif strcmp(varargin{i}, 'hhp')
            passargin{end+1}='hhp';
            i=i+1;
            passargin{end+1}=varargin{i};
        elseif strcmp(varargin{i}, 'llp')
            passargin{end+1}='llp';
            i=i+1;
            passargin{end+1}=varargin{i};
        elseif strcmp(varargin{i}, 'lpf')
            passargin{end+1}='lpf';
            i=i+1;
            passargin{end+1}=varargin{i};
        elseif strcmp(varargin{i}, 'hpf')
            passargin{end+1}='hpf';
            i=i+1;
            passargin{end+1}=varargin{i};
        elseif strcmp(varargin{i}, 'nofilters')
            passargin{end+1}='nofilters';
        elseif strcmp(varargin{i}, 'noconfig')
            passargin{end+1}='noconfig';
        elseif strcmp(varargin{i}, 'verbose')
            passargin{end+1}='verbose';
        elseif strcmp(varargin{i}, 'keep_discarded')
            passargin{end+1}='keep_discarded';  
        else
            fprintf('unknown argument at pos %d\n', 1+i);
        end
    end
    i=i+1;
end

overlap_pre_event_t=50;
overlap_post_event_t=50;

%find all needed files
fnames=cell(1,0);
neurons_in_file_idx=cell(1,0);
total_ts=zeros(1, length(n_list));
file_type=zeros(1, length(n_list));   %0-tbase, 1-no tbase

for n=n_list
    
    if isfield(neurons{n}, 'tbase_idx')
        file_type(n)=0;
    else
        file_type(n)=1;
    end
    if ~iscell(neurons{n}.fname)        % in order to work with testbench-neurons!!!
        a=neurons{n}.fname;
        neurons{n}.fname=cell(1);
        neurons{n}.fname{1}=a;
    end
    if ~isfield(neurons{n}, 'finfo') && file_type(n)==1    % in order to work with testbench-neurons - works fine!!!
        neurons{n}.finfo{1}.first_frame_no=1;
        if iscell(neurons{n}.ts)
            neurons{n}.finfo{1}.last_frame_no=-1;
            for cts=neurons{n}.ts
                neurons{n}.finfo{1}.last_frame_no=max([neurons{n}.finfo{1}.last_frame_no max(cts{:})]);
            end
        else
            neurons{n}.finfo{1}.last_frame_no=max(neurons{n}.ts);
        end
        neurons{n}.finfo{1}.timestamp=datestr('04-Nov-1980',31);    % just a date... :-)
        neurons{n}.ts_fidx=ones(size(neurons{n}.ts));
    end

    
    for fidx=1:length(neurons{n}.fname)
        strcmp_res=strcmp(neurons{n}.fname{fidx}, fnames);      
        if any(strcmp_res)
            %fname already exists
            if sum(strcmp_res)>1, warning('HIDENS:hidens_extract_traces', 'detected double file entry in neuron.');  end
            fidx_f=find(strcmp_res,1,'first');
            fnd_res=find(neurons_in_file_idx{fidx_f}.n_list==n);
            if any(fnd_res)
                %add to other neuron
                if file_type(n), warning('HIDENS:hidens_extract_traces', 'something went wrong'); end
                nidx_f=find(fnd_res,1,'first');
                neurons_in_file_idx{fidx_f}.tb_idx{nidx_f}(end+1)=fidx;
            else
                %new neuron in that file    
                neurons_in_file_idx{fidx_f}.n_list(end+1)=n;
                if file_type(n)
                    % old, not needed (jaeckeld)
                    %no-tbase
                    if neurons{n}.finfo{fidx}.first_frame_no<neurons_in_file_idx{fidx_f}.finfo{1}.first_frame_no
                        neurons_in_file_idx{fidx_f}.finfo{1}.first_frame_no=neurons{n}.finfo{fidx}.first_frame_no;
                    end
                    if neurons{n}.finfo{fidx}.last_frame_no>neurons_in_file_idx{fidx_f}.finfo{1}.last_frame_no
                        neurons_in_file_idx{fidx_f}.finfo{1}.last_frame_no=neurons{n}.finfo{fidx}.last_frame_no;
                    end          
                else
                    %tbase
                    neurons_in_file_idx{fidx_f}.tb_idx{end+1}=fidx;
                end
            end
        else
            %found new fname
            fnames{end+1}=neurons{n}.fname{fidx};
            neurons_in_file_idx{end+1}.n_list(1)=n;
            if file_type(n)
                %no-tbase
                neurons_in_file_idx{end}.finfo{1}=neurons{n}.finfo{fidx};           
            else
                %tbase
            	neurons_in_file_idx{end}.tb_idx{1}=fidx;
            end
        end 
    end
    
    if file_type(n)
        %no-tbase
        total_ts(n)=length(neurons{n}.ts);
    else
        %tbase
        for tbi=1:length(neurons{n}.ts)
            total_ts(n)=total_ts(n)+length(neurons{n}.ts{tbi});
        end
    end
    
    if not(isempty(event_param))
        y{n}.event_param=event_param;
    end
    y{n}.template=[];
    y{n}.x=[];
    y{n}.y=[];
    y{n}.el_idx=[];
    y{n}.trace={};
    if isfield(y{n}, 'active_els'), y{n}=rmfield(y{n}, 'active_els');end
    if isfield(y{n}, 'tbase_idx'),y{n}=rmfield(y{n}, 'tbase_idx');end
    y{n}.event_param.margin=extract_margin*y{n}.event_param.margin;
    y{n}.ts=[];
    y{n}.ts_pos=[];
    y{n}.fname={};
    y{n}.finfo={};
    if isfield(neurons{1}, 'ts_fidx')
        y{n}.ts_fidx=[];
    end
end

%display all needed files
fprintf('List of all required files:\n');
for fidx=1:length(fnames)
   fprintf('File %s:\n', fnames{fidx});
   for i=1:length(neurons_in_file_idx{fidx}.n_list)
       n=neurons_in_file_idx{fidx}.n_list(i);
       fprintf('   neuron %d',  n);
       if ~file_type(n)
           fprintf(' (tbases: ');
           if length(neurons_in_file_idx{fidx}.tb_idx{i})>1, fprintf('%d, ', neurons_in_file_idx{fidx}.tb_idx{i}(1:end-1)); end
           fprintf('%d)', neurons_in_file_idx{fidx}.tb_idx{i}(end));
       end
       fprintf('\n');
   end
end

fprintf('\n\n');

unused_files=[];
%load files and extract traces
for f_idx=1:length(fnames)
    skip=0;
    
    if not(exist(fnames{f_idx}, 'file'))
       warning('HIDENS:hidens_extract_traces', 'file "%s" does not exist', fnames{f_idx});
       unused_files(end+1)=f_idx;   %#ok<AGROW>
       skip=1;
    end
    if ~skip
        ntk=initialize_ntkstruct(fnames{f_idx}, passargin{:});
        if ntk.eof
            unused_files(end+1)=f_idx; %#ok<AGROW>
            skip=1;
        end
    end
    
    if ~skip
        clear overlap;
        first_frame_no=-1;
        last_frame_no=-1;

        %prepare new neurons struct
        done=0;
        pending_ts=cell(1,length(neurons_in_file_idx{f_idx}.n_list));
        pending_ts_pos=zeros(1,length(neurons_in_file_idx{f_idx}.n_list));
        pending_ts_len=zeros(1,length(neurons_in_file_idx{f_idx}.n_list));
        file_added_to_neuron=zeros(1,length(neurons_in_file_idx{f_idx}.n_list));
        total_this_file=zeros(1,length(neurons_in_file_idx{f_idx}.n_list));
        for i=1:length(neurons_in_file_idx{f_idx}.n_list)
            n=neurons_in_file_idx{f_idx}.n_list(i);
            pending_ts_pos(i)=y{n}.event_param.pre2+y{n}.event_param.margin;
            pending_ts_len(i)=y{n}.event_param.pre2+y{n}.event_param.post2+2*y{n}.event_param.margin;

            if ~file_type(n)
                %tbase
                pending_ts{i}=[];
                for tbi=neurons_in_file_idx{f_idx}.tb_idx{i}
                    pending_ts{i}=[pending_ts{i} neurons{n}.ts{tbi}+neurons{n}.ts_pos{tbi}];
                end
            else            
                %no-tbase
                if isfield(neurons{n}, 'ts_fidx')
                    loc_idx_of_this_file=find(strcmp(neurons{n}.fname,fnames{f_idx}));
                    idx_of_ts_from_this_file{i}=find(neurons{n}.ts_fidx==loc_idx_of_this_file);
                    pending_ts{i}=neurons{n}.ts(idx_of_ts_from_this_file{i})+neurons{n}.ts_pos(idx_of_ts_from_this_file{i});                    
                else
                    %do the old way, if no '.ts_fidx' around: 
                    pending_ts{i}=neurons{n}.ts+neurons{n}.ts_pos;
                    pending_ts{i}=pending_ts{i}(pending_ts{i}>=neurons_in_file_idx{f_idx}.finfo{1}.first_frame_no & pending_ts{i}+pending_ts_len(i)<neurons_in_file_idx{f_idx}.finfo{1}.last_frame_no);%select only those ts that are in the current file
                end
            end
            %adjust ts
            pending_ts{i}=pending_ts{i}-y{n}.event_param.pre2-y{n}.event_param.margin;
            total_this_file(i)=length(pending_ts{i});
        end


%         while not(ntk.eof) && not(done)

%             if do_time_align
%                 [ntk2 ntk]=ntk_load(ntk, load_chunk_size,'time_align');
%             else
%                 [ntk2 ntk]=ntk_load(ntk, load_chunk_size);
%             end

            %add overlap
            if exist('overlap', 'var')
                t_start_idx=t_next_idx;
                ntk2.sig=[overlap.sig ; ntk2.sig];
                if isfield(ntk2, 'frame_no'),ntk2.frame_no=[overlap.frame_no ntk2.frame_no];end;
                if isfield(ntk2, 'temp'),ntk2.temp=[overlap.temp ; ntk2.temp];end;
                if isfield(ntk2, 'dc'),ntk2.dc=[overlap.dc ; ntk2.dc];end;
            else
                t_start_idx=0;
                first_frame_no=ntk2.frame_no(1);
            end   

            overlap.sig=ntk2.sig(end-(overlap_pre_event_t+overlap_post_event_t-1):end,:);

            if isfield(ntk2, 'frame_no'),overlap.frame_no=ntk2.frame_no(end-(overlap_pre_event_t+overlap_post_event_t-1):end);end;
            if isfield(ntk2, 'temp'),overlap.temp=ntk2.temp(end-(overlap_pre_event_t+overlap_post_event_t-1):end);end;
            if isfield(ntk2, 'dc'),overlap.dc=ntk2.dc(end-(overlap_pre_event_t+overlap_post_event_t-1):end);end;

            t_next_idx=t_start_idx+size(ntk2.sig,1)-size(overlap.sig,1);    

            %detect valid channels
            if ~no_detect_valid_channels
                ntk2=detect_valid_channels(ntk2, 1); %#ok<NASGU>
            end

            if sum(ntk2.frame_no>2^52)
                error('Framenumbers exceeds 2^52 (max integer in double precision)!\n');
            end

            t_idx=(1:size(ntk2.sig,1))+t_start_idx;
            t_idx_fr=double(ntk2.frame_no); %(1:size(ntk2.sig,1))+t_start_idx;

            unfolded=zeros(1,t_idx_fr(end)-t_idx_fr(1)+1); %this is a problem if there are very large gaps in the data
            unfolded(t_idx_fr-t_idx_fr(1)+1)=1;
            unfolded=cumsum(unfolded);
            %TODO: check for missing frame numbers and drop those events


            if first_frame_no==-1, first_frame_no=ntk2.frame_no(1); end
            if last_frame_no<ntk2.frame_no(end), last_frame_no=ntk2.frame_no(end); end

            done=1;
            for i=1:length(neurons_in_file_idx{f_idx}.n_list)
                n=neurons_in_file_idx{f_idx}.n_list(i);

                if file_type(n)
                    %no-tbase
                    found_ts=find(pending_ts{i}>=t_idx_fr(1) & pending_ts{i}+pending_ts_len(i)<=t_idx_fr(end));
                    found_ts_frno=pending_ts{i}(found_ts);
                    found_ts_idx=unfolded(found_ts_frno-t_idx_fr(1)+1);
                else
                    %tbase
                    found_ts=find(pending_ts{i}>=t_idx(1) & pending_ts{i}+pending_ts_len(i)<=t_idx(end));
                    found_ts_idx=pending_ts{i}(found_ts)-t_start_idx;   %FIXME: +1 ???
                    found_ts_frno=t_idx_fr(found_ts_idx);
                end


                new_ts_idx=length(y{n}.ts)+(1:length(found_ts));

                %found ts?
                if not(isempty(found_ts))
                    %any new channel found?
                    new_el_idx=1:length(ntk2.el_idx);
                    [n_idx ntk_idx]=multifind(y{n}.el_idx, ntk2.el_idx);
                    new_el_idx(ntk_idx)=[];
                    if not(isempty(new_el_idx))
                        %fprintf('found %d new channels for neuron %d\n', length(new_el_idx), n);
                        %yeap, have new channels, init 
                        new_el_idx_idx=length(y{n}.el_idx)+(1:length(new_el_idx));
                        y{n}.x=[y{n}.x ntk2.x(new_el_idx)];
                        y{n}.y=[y{n}.y ntk2.y(new_el_idx)];
                        y{n}.el_idx=[y{n}.el_idx ntk2.el_idx(new_el_idx)];

                        for c=new_el_idx_idx
                            y{n}.trace{c}.ts_idx=zeros(1,0);
                            y{n}.trace{c}.data=zeros(pending_ts_len(i),0);
                        end
                    end

                    %only add the filename if ts have been found
                    if ~(file_added_to_neuron(i))
                        y{n}.fname{end+1}=fnames{f_idx};
                        y{n}.finfo{end+1}.first_frame_no=first_frame_no;
                        file_added_to_neuron(i)=1;
                    end

                    %add the ts
                    y{n}.ts=[y{n}.ts found_ts_frno];
                    y{n}.ts_pos=[y{n}.ts_pos ones(1,length(found_ts))*pending_ts_pos(i)];
                    if isfield(neurons{n}, 'ts_fidx')
                        % y{n}.ts_fidx=[y{n}.ts_fidx neurons{n}.ts_fidx(idx_of_ts_from_this_file{i})];    % proper ts_fidx!!!
                        [a b]=intersect(y{n}.ts,found_ts_frno); % b = which ts were found
                        y{n}.ts_fidx=[y{n}.ts_fidx neurons{n}.ts_fidx(b)];  % corrected (jaeckeld), TODO: test with multiple files!!
                    end
                    [n_idx ntk_idx]=multifind(y{n}.el_idx, ntk2.el_idx);
                    for c=1:length(n_idx)
                        last_tr=length(y{n}.trace{n_idx(c)}.ts_idx);
                        y{n}.trace{n_idx(c)}.ts_idx=[y{n}.trace{n_idx(c)}.ts_idx new_ts_idx];
                        y{n}.trace{n_idx(c)}.data(:,last_tr+(1:length(found_ts)))=zeros(pending_ts_len(i), length(found_ts));
                        for e=1:length(found_ts)
                            y{n}.trace{n_idx(c)}.data(:, last_tr+e)=ntk2.sig(found_ts_idx(e)+(0:(pending_ts_len(i)-1)),ntk_idx(c));
                        end
                    end
                end
                if file_added_to_neuron(i)
                    y{n}.finfo{end}.last_frame_no=ntk2.frame_no(end);
                end

                pending_ts{i}(found_ts)=[];

                %lost_ts=find(pending_ts{i}<t_next_idx);
                fprintf('   neuron %d: extracted %d traces, loaded %.1f%% (%.1f%% from this file)\n', n, length(found_ts), length(y{n}.ts)/total_ts(n)*100,  (1-length(pending_ts{i})/total_this_file(i))*100);
                %pending_ts{i}(lost_ts)=[];
                if not(isempty(pending_ts{i}))
                    done=0;
                end
            end
        
    end

    clear ntk
    clear ntk2
end
if simplify        % reduce traces
    y=simplify_traces(y);
end

fprintf('remove unused channels & reextract templates\n')


fprintf('\n\n');
if not(isempty(unused_files))
    fprintf('Files:\n');
    fprintf('The following files could not be loaded (either don''t exist or have\n');
    fprintf('or have been marked ''discarded''. Consider running this function with\n');
    fprintf('the option ''keep_discarded''.):\n');
    for i=unused_files
        fprintf('* %s\n', fnames{i});
    end
    fprintf('\n');
end

fprintf('Result:\n');
remove_n=[];
for n=n_list
    fprintf('   neuron %d: loaded a total of %d traces (%.1f%%)', n,  length(y{n}.ts), length(y{n}.ts)/total_ts(n)*100);
    if isempty(y{n}.ts)
        remove_n(end+1)=n; %#ok<AGROW>
        fprintf('     will be removed!');
    elseif length(y{n}.ts)~=total_ts(n)
        fprintf('     not complete!');
    end
    fprintf('\n');
end

n_list(remove_n)=[];

fprintf('\n\nremove unused channels & reextract templates\n')
for n=n_list
    %remove channels with no spikes
    tot_evs=zeros(size(y{n}.el_idx));
    for c=1:length(y{n}.el_idx)  %loop through all channels
        if not(isempty(y{n}.trace{c}))
            if isfield(y{n}.trace{c}, 'weight')
                %we have a preaveraged trace/template here....
                tot_evs(c)=tot_evs(c)+sum(y{n}.trace{c}.weight);
            else
                tot_evs(c)=tot_evs(c)+length(y{n}.trace{c}.ts_idx);
            end
        end
    end
    discard_c=find(tot_evs==0);
    y{n}.x(discard_c)=[];
    y{n}.y(discard_c)=[];
    y{n}.el_idx(discard_c)=[];
    y{n}.trace(discard_c)=[];
    
    %get template
    y{n}.template=get_template(y{n});
    
    %get 'timestamp'-entries
    
    if file_type(n)
        %no-tbase
        for i=1:length(y{n}.finfo)
            cmp_idx=find(strcmp(neurons{n}.fname,y{n}.fname{i}));
            if isfield(neurons{n}.finfo{cmp_idx},'timestamp')       % some old stored neurons (no-tbase) don't have timestamp
                y{n}.finfo{i}.timestamp=neurons{n}.finfo{cmp_idx}.timestamp;
            else
                y{n}.finfo{i}.timestamp=datestr('04-Nov-1980',31);
            end
        end
    else
        %tbase
        % what to do here?? 1. add .ts_fidx 2. add .timestamp
        warning('This neuron uses tbase index. Following entries were not adapted: .ts_fidx; .timestamp')
        
    end
end

y(remove_n)=[];



