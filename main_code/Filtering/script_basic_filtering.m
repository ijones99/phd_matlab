%%
data = diffTrace;
filtLow = 1000;
Fs = 20000;
[b, a] = butter(1, filtLow/(Fs/2), 'low');
y = filtfilt(b, a, data);
figure, plot(data,'x-'), hold on
plot(y,'x-g')