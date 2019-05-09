%% These scripts are the ZMQ commands written by Jan Mueller
%% start stimloop
k = stimloop;
%% args to disconnect el
slotNum = 0; enable = 0; dacSel = 0; cLarge = 0; channel = -1; broadcast = 1;
k.push_connect_channel(slotNum,enable,dacSel,cLarge, channel, broadcast);
k.flush

%% args to connect el
slotNum = 0; enable = 1; dacSel = 0; cLarge = 0; channel = 83; broadcast = 0;
k.push_connect_channel(slotNum,enable,dacSel,cLarge, channel, broadcast);
k.flush
%% single pulse

k.setTimeout(5000);
for i = 1:5
    amp = 50;
    k.push_simple_pulse(slotNum, 0, amp, 4)
    k.push_simple_delay(80*20); % 30 ms delay
    
end
k.flush

%% triphasic pulse

ampsTriPhasic = [100 -150 50];
phaseTriPhasic = [4 4 4 ];
delayMsec = 100;
delay = delayMsec*20;%msec

for i = 1
   delay = 100;
   k.push_triphasic_pulse(slotNum,dacSel,ampsTriPhasic(1),ampsTriPhasic(2),...
       ampsTriPhasic(3), ...
       phaseTriPhasic(1), phaseTriPhasic(2), phaseTriPhasic(3), delay);
end




%% Very basic example (from WIKI)

f.setTimeout(5000);
for i = 1:10
    amp = sin((2*pi)/50.0*i)*50;
    f.push_simple_pulse(4, 0, 100+amp, 4)
    f.push_simple_delay(30*20); % 30 ms delay
    
end
g = stimloop;
for i = 1:10
    delay = -sin((1*pi)/50.0*i)*20*28;
    g.push_simple_pulse(4, 0, 100, 4)
    g.push_simple_delay(30*20 + delay); % 20 ms delay
end

f.send();
g.send();


%% Biphasic pulse
m = stimloop;
pause(2)
m.push_biphasic_pulse(slotNum,1,107,20, 40*20, 60*20, 20, 0); 
m.flush();

%% Triphasic Stimulus
k = stimloop;
for i = 1
   delay = 100;
   k.push_triphasic_pulse(4,1,200,-150,50, 200, 200, 200, 100);
end

%% args to connect el
slotNum = 0; enable = 1; dacSel = 1; cLarge = 0; channel = 120; broadcast = 1;
k.push_connect_channel(slotNum,enable,dacSel,cLarge, channel, broadcast);
k.send();
%% Triphasic Stimulus Both DACs

slotNum = 4; voltOffset = 512; 
dac1Amps = [150 -200 50];
dac2Amps = [-150 200 -50];
phaseTimes = [20 20 20]*20; % must be in samples 
delay = 40*20;% must be in samples
chNums = [107];
pause(1)
for i=1
    j = stimloop;
    % args to connect el
    enable = 1; dacSel = 0; cLarge = 0; channel = chNums(i); broadcast = 0;
    j.push_connect_channel(slotNum,enable,dacSel,cLarge, channel, broadcast);
    pause(1);
    
    delay = 2000;
    j.push_triphasic_simdac_pulse(slotNum,voltOffset,...
        dac1Amps(1),dac1Amps(2),dac1Amps(3), ...
        dac2Amps(1),dac2Amps(2),dac2Amps(3),...
        phaseTimes(1),phaseTimes(2),phaseTimes(3), delay);
    
      
    j.send()
    pause(1)
    broadcast = 1; enable = 0;
    j.push_connect_channel(slotNum,enable,dacSel,cLarge, channel, broadcast);
j.send()
end


%% Triphasic Stimulus One DACs

slotNum = 0; voltOffset = 512; 
dac1Amps = [150 -200 50];
dac2Amps = [-150 200 -50];
phaseTimes = [20 20 20]*20; % must be in samples 
delay = 40*20;% must be in samples
chNums = [22];
pause(1)


j = stimloop;
% args to connect el
enable = 1; dacSel = 0; cLarge = 0; channel = chNums(1); broadcast = 0;
j.push_connect_channel(slotNum,enable,dacSel,cLarge, channel, broadcast);
pause(0.25);

delay = 2000;
j.push_triphasic_simdac_pulse(slotNum,voltOffset,...
    dac1Amps(1),dac1Amps(2),dac1Amps(3), ...
    dac2Amps(1),dac2Amps(2),dac2Amps(3),...
    phaseTimes(1),phaseTimes(2),phaseTimes(3), delay);

for i=1:30
    j.send()


end