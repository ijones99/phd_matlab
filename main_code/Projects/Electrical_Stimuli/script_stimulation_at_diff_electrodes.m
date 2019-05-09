%%

 fpga_sock = tcpip('11.0.0.7',32125); %fpga server sock
 fopen(fpga_sock)
 
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stimulation sequences %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

stimRunName   = 'test01';
channel        =           3;        %// Stimulation channel(electrode 10036)
chipaddress    =             1;        %// "slot" where chip is plugged [0-4]
dacselection   =             0;        %// 0->DAC1.  1->DAC2. 2->[DAC1 without DAC2 encoding]. This is the DAC used to stimulate. The other DAC is then used for encoding stimulation channel and epoch.
voltages       = [50 100 250 500 1000];        %// [+/-mV; millivolt]   [current: 0 to 450 allowed -->> 0 to +/-4.12uA ONLY! for low current mode]
stim_mode      =             1;        %// [previous==0; voltage==1; current==2]
phase          =           200;        %// [us; microseconds]
delay          =            500;        %// [0->3,000; milliseconds] delay until stimulating sent to fpga (can change limits in test.c)
delayStim      =    0;

repeats        =            30;
epoch          =        1:length(voltages)*repeats;

epochRand = randperm(length(epoch));
voltageReps = repmat(voltages, 1, repeats);

runTime = input(sprintf('Time = %2.1f minutes', length(channel)*0.5*length(epoch)/60))

for iCh = 1:length(channel) % go through channels
    
    for iEpoch = epochRand % go through repeats & voltages
        
        %  DAC2 encoding pulse
        volt         =    0;
        dacselection =    0;
        stimulation  =[(chipaddress),(dacselection),(channel),(ceil(volt/2.9)),((ceil(phase/50))),(epochRand(iEpoch)),(0),(round(delay*20)),(stim_mode)];
        stimulation  = (int16(stimulation));
        
        %  Stimulation pulse
        volt         =  voltageReps(epochRand(iEpoch));
        dacselection =            2;
        stimulation_sup =[(chipaddress),(dacselection),(channel),(ceil(volt)/2.9),((ceil(phase/50))),(epochRand(iEpoch)),(0),(round(delayStim*20)),(stim_mode)];
        stimulation_sup = (int16(stimulation_sup));
        
        % Send stim commands
        fwrite(fpga_sock,stimulation,    'int16');            % send stimulation
        fwrite(fpga_sock,stimulation_sup,'int16');
        
    end
    
end

save(sprintf('Stimulation_Variables_%s.mat', stimRunName));
%%

% fclose(fpga_sock);%%

fclose(fpga_sock);

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %













































