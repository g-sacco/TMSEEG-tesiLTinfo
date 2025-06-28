%% step 0
clear; close all; clc;

% alberto8_tdcs_epoched: raw data epoched around TMS pulse
filepath = '.';
filename = 'alberto8_tdcs_epoched.set';

%% Step 1: Import data to EEGLAB
EEG = pop_loadset('filename', filename, 'filepath', filepath);

%% Step 2: find ocular artifacts timings in EOG channel
EOG = EEG.data(3, :);

time = 0:1/EEG.srate:length(EOG)/EEG.srate;
time = time(1:end-1);

threshold = mean(EOG) + 1.2*std(EOG);

figure;
plot(time, EOG);
xlabel("Time [s]"), ylabel("Amplitude [uV]");
hold on, grid on;

[pks, locs] = findpeaks(EOG, 'MinPeakHeight', threshold, ...
                             'MinPeakDistance', 3*EEG.srate);
plot(locs/EEG.srate, pks, 'ro', 'MarkerFaceColor', 'r');
yline(threshold, '--r', 'Threshold');

% remove unused channels
EEG = pop_select(EEG, 'nochannel', {'TRIG1' 'TRIG2' 'EOG' 'GATE'});

%% Step 3: visualize EOG artifacts on EEG data
% add EOG events to EEG
EEG.event = [];
for level = 1:length(locs)
    EEG.event(level).latency = locs(level);
    EEG.event(level).type = 'EOG';
end
EEG.event = eeg_checkset(EEG.event);
% plot EEG data channels scrolling
%pop_eegplot(EEG, 1, 1, 1, 1);

%% Step 4: remove ocular artifacts using wavelet decomposition
FP1 = EEG.data(1, :);

% wavelet decomposition
n = 6; % number of levels
wname = 'db4'; % wavelet name

% c = vettore con tutti i coefficienti wavelet concatenati
% l = vettore con le dimensioni dei coefficienti per ogni livello, per poterli separare correttamente
[c, l] = wavedec(FP1, n, wname);

%{
for level=1:n
    approx = appcoef(c, l, wname, level);
    figure;
    plot(approx);
    title("Level " + level + " Approximation Coefficients");
    xline(locs/2^level, '-r');
end


detailCoefficents = detcoef(c, l, 1:n);
for level=1:n
    figure;
    plot(detailCoefficents{level});
    title("Level " + level + " Detail Coefficients");
    xline(locs/2^level, '-r');
end
%}

%% Denoising brute forces approximation
filt_c = c;
filt_c(1:l(1)-1) = 0;   % tolgo primo livello
%filt_c(l(1):l(2)-1) = 0;   % tolgo secondo livello

recontructed_orig = waverec(c, l, wname);
recontructed_filt = waverec(filt_c, l, wname);

figure;
recontructed_orig = recontructed_orig - mean(recontructed_orig);
plot(time, recontructed_orig);
hold on;
recontructed_filt = recontructed_filt - mean(recontructed_filt);
plot(time, recontructed_filt);

legend(["Orignal" "Filtered"])