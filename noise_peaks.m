
clc; clear; close all;
filename = '109samples.csv';
data = readtable(filename);

time_strings = data{:,1};
time_strings = erase(time_strings, {'"', ''''}); 
time_parts = split(time_strings, {':', '.'});
minutes = str2double(time_parts(:,1));
seconds_part = str2double(time_parts(:,2));
milliseconds = str2double(time_parts(:,3));
valid_idx = ~isnan(minutes) & ~isnan(seconds_part) & ~isnan(milliseconds);
time = (minutes(valid_idx) * 60) + seconds_part(valid_idx) + (milliseconds(valid_idx) / 1000);
ecgsignal = data{valid_idx,2};
dt = diff(time); 
dt = dt(~isnan(dt) & ~isinf(dt));
fs = 1 / mean(dt);
L = length(ecgsignal);
f = fs * (0:(L/2)) / L;
Y = fft(ecgsignal);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2 * P1(2:end-1);

figure;
subplot(2,1,1);
plot(time, ecgsignal);
title('ECG Signal'); xlabel('Time (s)'); ylabel('Amplitude'); grid on;

subplot(2,1,2);
plot(f, P1);
title('Fast foruier transform'); xlabel('Frequency (Hz)'); ylabel('|P1(f)|'); grid on;
hold on;

[pxx, f] = pspectrum(ecgsignal, fs, 'power', 'FrequencyResolution', 0.5);
figure;
hold on;
plot(f, 10*log10(pxx), 'b', 'LineWidth', 1.5); 
xlabel('Frequency (Hz)');
ylabel('Power/Frequency (dB/Hz)');
title('Power density according to nosies');
grid on;
idx = (f >= 50) & (f <= 60);
plot(f(idx), 10*log10(pxx(idx)), 'r', 'LineWidth', 2.25); 
legend('powerline-noise', '50-60 Hz');
hold off;

[qrs_peaks, qrs_locs] = findpeaks(ecgsignal, 'MinPeakHeight', mean(ecgsignal) + 1.2 * std(ecgsignal), 'MinPeakDistance', round(0.6 * fs));
Q_locs = arrayfun(@(r) find(ecgsignal(max(r-20,1):r) == min(ecgsignal(max(r-20,1):r)), 1) + max(r-20,1) - 1, qrs_locs);
s_window = round(0.06 * fs); 
S_locs = arrayfun(@(r) ...
    find(ecgsignal(r:min(r+s_window, length(ecgsignal))) == ...
    min(ecgsignal(r:min(r+s_window, length(ecgsignal)))), 1) + r - 1, ...
    qrs_locs);
P_locs = arrayfun(@(q) find(ecgsignal(max(q-40,1):q) == max(ecgsignal(max(q-40,1):q)), 1) + max(q-40,1) - 1, Q_locs);
T_locs = arrayfun(@(s) find(ecgsignal(s:min(s+40,length(ecgsignal))) == max(ecgsignal(s:min(s+40,length(ecgsignal)))), 1) + s - 1, S_locs);

figure;
plot(time, ecgsignal);
hold on;
plot(time(qrs_locs), ecgsignal(qrs_locs), 'ro', 'MarkerFaceColor', 'r'); 
plot(time(Q_locs), ecgsignal(Q_locs), 'go', 'MarkerFaceColor', 'g');
plot(time(S_locs), ecgsignal(S_locs), 'bo', 'MarkerFaceColor', 'b'); 
plot(time(P_locs), ecgsignal(P_locs), 'mo', 'MarkerFaceColor', 'm');
plot(time(T_locs), ecgsignal(T_locs), 'co', 'MarkerFaceColor', 'c');
legend('ECG Signal', 'R-peaks', 'Q-peaks', 'S-peaks', 'P-peaks', 'T-peaks');
title('P, Q, R, S, and T Wave Detection in ECG Signal'); xlabel('Time (s)'); ylabel('Amplitude'); grid on;
hold off;

RR_time = diff(time(qrs_locs)); 
bpm= 60 ./ mean(RR_time); 
disp(['Average Heart beat: ', num2str(bpm), ' BPM']);

figure;
histogram(RR_time, 'BinWidth', 0.01);
title('Distribution of RR Intervals'); xlabel('RR Interval (s)'); ylabel('Frequency'); grid on;
