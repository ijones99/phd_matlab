% To sort data automatically
% 1) put config files into Matlab/Configs
mkdir('Configs');
% 2) make Matlab/GenFiles/ directory
mkdir('GenFiles');
% 2.5) put white noise frames in dir
mkdir('StimCode'); % white_noise_frames
% 3) ntk file location?
% 4) 

%% run auto sort for all stimuli
flistNames = { ...
    'flist_white_noise_checkerboard'...
    }
stimNames = { ...
    'white_checkerboard'...
    }


ifunc.auto_run.run_auto_sort(flistNames, stimNames)
ifunc.stim.get_and_save_frameno(flistName, stimName);

%% White Noise
flistNames = 'flist_white_noise_checkerboard';
stimNames = 'white_noise_checkerboard';
    
ifunc.auto_run.process_white_noise2(flistNames, stimNames)

%% get selected els
plot_electrode_config
[selEls notIncludedEls] = ifunc.el_config.get_sel_els(elConfigInfo,[4543 4226 6981 6778 6787 6891  ])
notIncludedEls = elConfigInfo.ntk2_to_nrk2_conversion_inds(notIncludedEls)
save('notIncludedEls.mat','notIncludedEls')
%% Noise Movie
dirNameStimFrames = strcat('/home/ijones/ln_nas/projects/retina_project/Light_Stimuli/', ...
    'Noise_Movies/Noise_Movie_Contrast_Vary/');