        
%%

 fpga_sock = tcpip('11.0.0.7',32125); %fpga server sock
 fopen(fpga_sock)
 
 %%
 
  chipaddress    =             1;        %// "slot" where chip is plugged [0-4]
  dacselection   =             0;        %// 0->DAC1.  1->DAC2. 2->[DAC1 without DAC2 encoding]. This is the DAC used to stimulate. The other DAC is then used for encoding stimulation channel and epoch.
  voltages        =   [50:2:150];        %// [+/-mV; millivolt]   [current: 0 to 450 allowed -->> 0 to +/-4.12uA ONLY! for low current mode]
  stim_mode      =             1;        %// [previous==0; voltage==1; current==2]
  phase          =           200;        %// [us; microseconds]
  delay          =            30;        %// [0->3,000; milliseconds] delay until stimulating sent to fpga (can change limits in test.c)
% epoch          =             1;        %// User defined optional tag. [0->512] for high res DAC encoding
  channel        =            71;        %// Stimulation channel(electrode 9961)
% delays         = [0.01:0.01:5];
  epoch          =        [1:51];
     
 %%%% network byte order, as used on the Internet, is Most Significant Byte first.
 %%%% matlab is little endian
 %%%% the least significant byte is stored first (little endian)
 %%%% the most significant byte is stored first (big endian).
 % input 0)chipaddress, 1)dacselection, 2)channel, 3)volt/curr(digi), 4)pulsephase(samples), 5)epoch, 6)epoch sign (1 -> negative) 7)delay[msec] 8)stim mode[previous==0; volt==1; curr==2]
 
for stim=1:60 
    
    
    for i= randperm(51)     
      
    %  DAC2 encoding pulse
        delay        =  1000;    
        volt         =     0;
        dacselection =     0;   
        stimulation  =[(chipaddress),(dacselection),(channel),(ceil(volt/2.9)),((ceil(phase/50))),(epoch(i)),(0),(round(delay*20)),(stim_mode)];
        stimulation  = (int16(stimulation));

    %  Stimulation
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

fclose(fpga_sock);

%   fclose('all')S