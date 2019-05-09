% show checkerboard on bs-dw27

% calculate STA
[staFrames staTemporalPlot plotInfo ] = ifunc.sta.make_sta( spikeTimes, white_noise_frames, ...
            frameInd, 'neuron_name', neuronName); %
        
        