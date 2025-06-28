%% step 0
clear; close all; clc;

% alberto8_tdcs_epoched: raw data epoched around TMS pulse
filepath = '.';
filename = 'alberto8_tdcs_epoched.set';

%% Step 1: Import data to EEGLAB
EEG = pop_loadset('filename', filename, 'filepath', filepath);
EOG = EEG.data(3, :);

% remove unused channels
EEG = pop_select(EEG, 'nochannel', {'TRIG1' 'TRIG2' 'EOG' 'GATE' 'P2' 'P3'});

%% Add EOG events to dataset
CHANNEL = EEG.data(1, :);
time = 0:1/EEG.srate:length(CHANNEL)/EEG.srate;
time = time(1:end-1);

% FIND PEAKS
threshold = mean(EOG) + 1.2 * std(EOG);
[pks, locs] = findpeaks(EOG, 'MinPeakHeight', threshold, ...
                             'MinPeakDistance', EEG.srate);
% Plot found peaks
figure;
plot(time, EOG), hold on;
plot(locs/EEG.srate, pks, 'ro', 'MarkerFaceColor', 'r');
yline(threshold, '--r', 'Threshold');
title("EOG - ocular artifacts"), xlabel("Time [s]"), ylabel("Amplitude [uV]");

% mask creation
% creating a mask around ocular artifacts
mask = false(1, length(CHANNEL));
mask(locs) = true;
blinkWindow = round(0.8 * EEG.srate);  % seconds to remove before and after event

for i=1:length(locs)
    idx_start = locs(i) - blinkWindow;
    idx_end = locs(i) + blinkWindow;
    if idx_start < 1
        idx_start = 1;
    end
    if idx_end > length(mask)
        idx_end = length(mask);
    end
    mask(idx_start:idx_end) = true;
    %figure;
    %plot(mask);
    %waitforbuttonpress;
end

mask = [false(1, 20) mask false(1, 20)];

% Adding EOG event to EEG 
EEG.event = [];
for level = 1:length(locs)
    EEG.event(level).latency = locs(level);
    EEG.event(level).type = 'EOG';
end
EEG.event = eeg_checkset(EEG.event);

% plot EEG data channels scrolling
pop_eegplot(EEG, 1, 1, 1, 1);

%% wavelet decomposition
n = 6; % number of levels
wname = 'db4'; % wavelet name

% Denoising brute forces approximation
chanNames = {EEG.chanlocs.labels};

% Downampling the mask for each level
for i=1:n
    mask = downsample(mask, 2);
end

for chanIdx = 1:length(chanNames)
    [c, l] = wavedec(EEG.data(chanIdx, :), n, wname);

    filt_c = c;
    base_value = mean(filt_c(1:l(1)-1));  

    new_level = filt_c(1:l(1)-1);
    %figure;
    %plot(new_level), hold on;
    new_level(mask) = base_value;
    %plot(new_level), legend(["Old" "New"]);
    %title("Channel: " + chanNames(chanIdx));

    filt_c(1:l(1)-1) = new_level(1:l(1)-1);   % tolgo sesto livello
    reconstructed_orig = waverec(c, l, wname);
    reconstructed_filt = waverec(filt_c, l, wname);
    
    %Coefficente di approssimazione livello n
    %approx = appcoef(filt_c, l, wname, n);
    %figure;
    %plot(approx);
    
    %{
    figure;
    plot(time, reconstructed_orig);
    hold on;
    plot(time, reconstructed_filt);
    title("Channel: " + chanNames(chanIdx));
    legend(["Orignal" "Filtered"]);
    %}

    EEG.data(chanIdx, :) = reconstructed_filt;
end

pop_eegplot(EEG, 1, 1, 1, 1);
