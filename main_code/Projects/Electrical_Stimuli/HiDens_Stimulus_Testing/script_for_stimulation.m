%% send data to test function

fpga_sock = tcpip('11.0.0.7',32130); %fpga server sock
fopen(fpga_sock)
pause(1)

a.pulsePolarity = [ 1 0 1]; 
a.amps = [100 150 50] / 2.9;
a.waveformTimes = [2  [10 12]  [12+1/(20*8) 14]  [14+1/(20*8) 16] 30  ]*20*8; 
a.channelNum = 53;
a.channelCount = length(a.channelNum);
a.selStimMode = 2;
a.numRepeats = 1;
a.interStimSamplesCount = 0;
b.pulsePolarity = [ 1 0 1]; 
b.amps = [100 150 50] / 2.9;
b.waveformTimes = [2  [10 12]  [12+1/(20*8) 14]  [14+1/(20*8) 16] 30  ]*20*8; 
b.channelNum = 53;
b.channelCount = length(b.channelNum);
b.selStimMode = 2;
b.numRepeats = 1;
b.interStimSamplesCount = 0;


% stimulation  =[pulsePolarity amps waveformTimes channelNum selStimMode];

% stimulation  =[a.pulsePolarity a.amps a.waveformTimes a.channelNum ...
%     a.selStimMode a.numRepeats a.interStimSamplesCount...
%     b.pulsePolarity b.amps b.waveformTimes b.channelNum ...
%     b.selStimMode b.numRepeats b.interStimNumSamples];

stimulation  =[ ...
a.pulsePolarity a.amps a.waveformTimes a.channelCount a.channelNum a.selStimMode ... 
a.numRepeats a.interStimSamplesCount ...
b.pulsePolarity b.amps b.waveformTimes b.channelCount b.channelNum b.selStimMode ... 
b.numRepeats b.interStimSamplesCount... 
];

numInputVals = length(stimulation);
stimulation  = int16([numInputVals stimulation]);

% Send stim commands
for i=1
fwrite(fpga_sock,stimulation,    'int16');
pause(0.05)
end
fclose(fpga_sock)
    
%% send data to     

portNo = 32125; % port for

fpga_sock = tcpip('11.0.0.7',portNo); %fpga server sock
fopen(fpga_sock)
chipaddress    =             4;        %// "slot" where chip is plugged [0-4]
dacselection   =             0;        %// 0->DAC1.  1->DAC2. 2->[DAC1 without DAC2 encoding]. This is the DAC used to stimulate. The other DAC is then used for encoding stimulation channel and epoch.
voltages       =  ceil([400]/2.9);        %// [+/-mV; millivolt]   [current: 0 to 450 allowed -->> 0 to +/-4.12uA ONLY! for low current mode]
stim_mode      =             1;        %// [previous==0; voltage==1; current==2]
phase          =           400;        %// [us; microseconds]
delay          =            30;        %// [0->3,000; milliseconds] delay until stimulating sent to fpga (can change limits in test.c)
channel        =           102;        %// Stimulation channel(electrode 10036)
epoch          =        [1:31];
    
i = 1;

for stim=1%:60
    volt         =  voltages(i);
    stimulation  =[(chipaddress),(dacselection),(channel),(ceil(volt)),((ceil(phase/50))),(epoch(i)),(0),(round(delay*20)),(stim_mode)];
    stimulation  = (int16(stimulation));
    
    %  Stimulation pulse

    
    dacselection =            2;
    stimulation_sup =[(chipaddress),(dacselection),(channel),(ceil(volt)),...
        ((ceil(phase/50))),(epoch(i)),(0),(round(delay*20)),(stim_mode)];
    stimulation_sup = (int16(stimulation_sup));
    
    % Send stim commands
    fwrite(fpga_sock,stimulation,    'int16');            % send stimulation
    fwrite(fpga_sock,stimulation_sup,'int16');
  
   stim
end

fclose(fpga_sock);%%


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stimulation sequences %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

     fpga_sock = tcpip('11.0.0.7',32125); %fpga server sock
    fopen(fpga_sock)
chipaddress    =             1;        %// "slot" where chip is plugged [0-4]
dacselection   =             0;        %// 0->DAC1.  1->DAC2. 2->[DAC1 without DAC2 encoding]. This is the DAC used to stimulate. The other DAC is then used for encoding stimulation channel and epoch.
voltages       =  [400:10:700];        %// [+/-mV; millivolt]   [current: 0 to 450 allowed -->> 0 to +/-4.12uA ONLY! for low current mode]
stim_mode      =             1;        %// [previous==0; voltage==1; current==2]
phase          =           200;        %// [us; microseconds]
delay          =            30;        %// [0->3,000; milliseconds] delay until stimulating sent to fpga (can change limits in test.c)
channel        =           102;        %// Stimulation channel(electrode 10036)
epoch          =        [1:31];
    
for stim=1%:60
   
   
    for i= randperm(31)    
     
    %  DAC2 encoding pulse
        delay        = 1000;   
        volt         =    0;
        dacselection =    0;  
        stimulation  =[(chipaddress),(dacselection),(channel),(ceil(volt/2.9)),((ceil(phase/50))),(epoch(i)),(0),(round(delay*20)),(stim_mode)];
        stimulation  = (int16(stimulation));

    %  Stimulation pulse
        delay        =            0;
        volt         =  voltages(i);
        dacselection =            2;
        stimulation_sup =[(chipaddress),(dacselection),(channel),(ceil(volt)/2.9),((ceil(phase/50))),(epoch(i)),(0),(round(delay*20)),(stim_mode)];
        stimulation_sup = (int16(stimulation_sup));
  
      % Send stim commands
        fwrite(fpga_sock,stimulation,    'int16');            % send stimulation 
        fwrite(fpga_sock,stimulation_sup,'int16');
    end
   
   
end


%%

fclose(fpga_sock);%%

fclose(fpga_sock);

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %













































