module load HiDens/experimental

ntk2hdf    filename.stream.ntk

i=4, figure, plot(h5SpikeWaveforms(:,(i-1)*61+1:i*61)')
x = h5SpikeWaveforms(:, (i-1)*61+1:i*61)';
 
x = h5SpikeWaveforms(:, (i-1)*61+1:i*61 )';
xx = reshape(x,1,[]);
figure, plot(xx)