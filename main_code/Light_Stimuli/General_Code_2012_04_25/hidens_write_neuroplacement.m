function hidens_write_neuroplacement(fname, varargin)

folder='matlab_specs';
npos=[];
default_size=13;
default_elcnt=nan;
default_multiloc=0;

i=1;
while i<=length(varargin)
    if not(isempty(varargin{i}))
        if strcmpi(varargin{i}, 'folder')
            i=i+1;
            folder=varargin{i};    
        elseif strcmpi(varargin{i}, 'npos')
            i=i+1;
            npos=varargin{i};    
        elseif strcmpi(varargin{i}, 'size')
            i=i+1;
            default_size=varargin{i};    
        elseif strcmpi(varargin{i}, 'elcnt')
            i=i+1;
            default_elcnt=varargin{i};    
        elseif strcmpi(varargin{i}, 'multiloc')
            default_multiloc=1;   
        else
            fprintf('unknown argument at pos %d\n', 1+i);
        end
    end
    i=i+1;
end

%some initializations
if isempty(fname)
    fprintf('you need to specify a file name...\n');
    return
end

if isempty(folder)
    folder='matlab_specs';
end

if not(exist('../Configs', 'dir'))
    error('Configs directory does not exist');
end
if not(exist(['../Configs/' folder ], 'dir'))
    mkdir(['../Configs/' folder ]);
end
full_fname=['../Configs/' folder '/' fname];


%export to file

fid=fopen(full_fname, 'w');
for i=1:length(npos)
    dx=default_size;  %size
    if isfield(npos{i}, 'dx')
        dx=npos{i}.dx;
    end
    dy=dx;
    if isfield(npos{i}, 'dy')
        dy=npos{i}.dy;
    end
    elcnt=default_elcnt;
    if isfield(npos{i}, 'elcnt')
        elcnt=npos{i}.elcnt;
    end
    multiloc=default_multiloc;
    if isfield(npos{i}, 'multiloc')
        multiloc=npos{i}.multiloc;
    end
    if multiloc
        fprintf(fid, '*');
    end
    fprintf(fid, 'Neuron %s: %d/%d, %d/%d', npos{i}.label, round(npos{i}.x), round(npos{i}.y), round(dx), round(dy));
    if isfield(npos{i}, 'c_sr')
        fprintf(fid, ', sr%d', npos{i}.c_sr);
    end
    if isfield(npos{i}, 'cost')
        fprintf(fid, ', c%f', npos{i}.cost);
    end
    if ~isnan(elcnt)
        fprintf(fid, ', el%d', elcnt);
    end
    fprintf(fid, '\n');
end
fclose(fid);












