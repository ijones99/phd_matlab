%%

    fpga_sock = tcpip('11.0.0.7',32130); %fpga server sock
    fopen(fpga_sock)
 
    amp1 = 100;
    amp2 = 120;
    amp3 = 123;

    stimulation  =[(amp1),(amp2),(amp3)];
    stimulation  = (int16(stimulation));

    %  Stimulation pulse

    % Send stim commands
    fwrite(fpga_sock,stimulation,    'int16'); 

    fclose(fpga_sock);
    
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stimulation sequences %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 
chipaddress    =             1;        %// "slot" where chip is plugged [0-4]
dacselection   =             0;        %// 0->DAC1.  1->DAC2. 2->[DAC1 without DAC2 encoding]. This is the DAC used to stimulate. The other DAC is then used for encoding stimulation channel and epoch.
voltages       =  [400:10:700];        %// [+/-mV; millivolt]   [current: 0 to 450 allowed -->> 0 to +/-4.12uA ONLY! for low current mode]
stim_mode      =             1;        %// [previous==0; voltage==1; current==2]
phase          =           200;        %// [us; microseconds]
delay          =            30;        %// [0->3,000; milliseconds] delay until stimulating sent to fpga (can change limits in test.c)
channel        =           102;        %// Stimulation channel(electrode 10036)
epoch          =        [1:31];
    
for stim=1:60
   
   
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













































