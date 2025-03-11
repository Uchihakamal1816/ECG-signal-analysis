
clc; clear; close all;
filename = '109samples.csv';
data = readtable(filename);

raw_tme = data{:,1}; 
raw_tme = erase(raw_tme, {'"', ''''}); 
time_div = split(raw_tme, {':', '.'}); 
min = str2double(time_div(:,1));
sec = str2double(time_div(:,2));
ms = str2double(time_div(:,3));

idx = ~isnan(min) & ~isnan(sec) & ~isnan(ms);
time = (min(idx) * 60) + sec(idx) + (ms(idx) / 1000);

ecg_data = data{idx,2}; 
fs = 1 / mean(diff(time));


int_mean = mean(ecg_data);
int_std = std(ecg_data);


noisy = 0.05 * randn(size(ecg_data)); 
fin_ecg = ecg_data + noisy;

t = time(:);
power_noise = 0.05 * sin(2 * pi * 50 * t); 
fin_ecg = fin_ecg + power_noise;


fin_mean = mean(fin_ecg);
fin_std = std(fin_ecg);

disp('Mean Before Noise: '), disp(int_mean)
disp('Standard devaition Before Noise: '), disp(int_std)
disp('Mean After Noise: '), disp(fin_mean)
disp('Standard devaition After Noise: '), disp(fin_std)


figure;
subplot(2,1,1);
plot(time, ecg_data);
title('Original'); xlabel('Time (s)'); ylabel('Amplitude'); grid on;

subplot(2,1,2);
plot(time, fin_ecg, 'r');
title('Noisy'); xlabel('Time (s)'); ylabel('Amplitude'); grid on;
legend('Noisy ECG');
