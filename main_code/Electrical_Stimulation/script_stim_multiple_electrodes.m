%%
% fpga_sock = tcpip('11.0.0.7',32125); %fpga server sock
fpga_sock = tcpip('11.0.0.7',32125); %fpga server sock
fopen(fpga_sock)
 
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stimulation sequences %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stimElChannels = [117];
chipaddress    =             4;        %// "slot" where chip is plugged [0-4]
dacselection   =             2;        %// 0->DAC1.  1->DAC2. 2->[DAC1 without DAC2 encoding]. This is the DAC used to stimulate. The other DAC is then used for encoding stimulation channel and epoch.
voltages       =  [500 1000 1500];        %// [+/-mV; millivolt]   [current: 0 to 450 allowed -->> 0 to +/-4.12uA ONLY! for low current mode]
stim_mode      =             1;        %// [previous==0; voltage==1; current==2]
phase          =           1;        %// [us; microseconds]
delay          =            1000/30;%30;        %// [0->3,000; milliseconds] delay until stimulating sent to fpga (can change limits in test.c)
channel        =           89;        %// Stimulation channel(electrode 10036)
epoch          =        [1:31];
num_repeats =           30;

epoch = 1;

for iVolt=1:length(voltages)
  
    
    for iCh = stimElChannels
        stimulation_sup =[(chipaddress),(dacselection),(iCh),(ceil(voltages(iVolt))/2.9),((ceil(phase/50))),...
            (epoch),(0),(round(delay*20)),(stim_mode)];
        
        for i= 1:num_repeats
         
            %  Stimulation pulse
            stimulation_sup = (int16(stimulation_sup));
            
            % Send stim commands
            % send stimulation
            fwrite(fpga_sock,stimulation_sup,'int16');
            epoch = epoch+1;
            
        end  
        pause(0.5)
    end
    
        
end


%%

fclose(fpga_sock);%%

% fclose(fpga_sock);

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
