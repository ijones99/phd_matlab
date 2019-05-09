function y=hidens_save_neuropos(px,py,nsize,sr, basefilename)


if length(px)~=length(py)
    error('px and py must be vectors of the same size');
end

len=length(px);

if length(nsize)==1
    nsize=ones(1,len)*nsize;
end
if length(nsize)~=len
    error('nsize must be either a scalar or a vector of the same length as px, py')
end

if length(sr)==1
    sr=ones(1,len)*sr;
end
if length(sr)~=len
    error('sr must be either a scalar or a vector of the same length as px, py')
end

fname=[basefilename '.neuropos.nrk'];

fid = fopen(fname, 'w');

for i=1:len
    fprintf(fid, 'Neuron matlab%d: %d/%d, %d/%d', i, round(px(i)), round(py(i)), round(nsize(i)), round(nsize(i)));
    if sr(i)~=1
        fprintf(fid, ', sr%d', sr(i));
    end
    fprintf(fid, '\n');
end

fclose(fid);

y=fname;



