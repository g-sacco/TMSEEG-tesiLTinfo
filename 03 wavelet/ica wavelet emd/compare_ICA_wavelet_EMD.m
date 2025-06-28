%% step 0
clear; close all; clc;

%% Import data to EEGLAB
filepath = '..';
filename = 'alberto8_tdcs_epoched.set';
EEG = pop_loadset('filename', filename, 'filepath', filepath);
EOG = EEG.data(3, :);

% remove unused channels
EEG = pop_select(EEG, 'nochannel', {'TRIG1' 'TRIG2' 'EOG' 'GATE' 'P2' 'P3'});
%% Remove bad electrodes
EEG = pop_rejchan(EEG, 'elec', 1:size(EEG.data,1) , ...
    'threshold', 7.5, ...
    'norm','on',['' ...
    'measure'],'kurt');

%% Add EOG events to dataset
CHANNEL = EEG.data(1, :);
time = 0:1/EEG.srate:length(CHANNEL)/EEG.srate - 1/EEG.srate;

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

% Add EOG events to EEG.event without removing existing events (e.g., TMS)
numExistingEvents = length(EEG.event);
for i = 1:length(locs)
    EEG.event(numExistingEvents + i).latency = locs(i);
    EEG.event(numExistingEvents + i).type = 'EOG';
end
%EEG = eeg_checkset(EEG, 'eventconsistency');

%% Remove ocular artifacts
EEG_wavelet = wavelet_OA_rm(EEG, 12, 'db4', 7:12);
EEG_ICA = ICA_OA_rm(EEG);
EEG_EMD = EMD_OA_rm(EEG);

%% Plotting PSD results
chan_name = EEG.chanlocs(1).labels; % Get the name of the first channel
figure;
tiledlayout(4, 1);
% EEG
nexttile;
pwelch(EEG.data(1, :), [], [], [], EEG.srate);
xlim([0 50]), ylim([-60 60]);
title("EEG channel " + chan_name + " - before artifact removal");
% EEG_wavelet
nexttile;
pwelch(EEG_wavelet.data(1, :), [], [], [], EEG_wavelet.srate);
xlim([0 50]), ylim([-60 60]);
title("EEG channel " + chan_name + " - after wavelet artifact removal");
% EEG_ICA
nexttile;
pwelch(EEG_ICA.data(1, :), [], [], [], EEG_ICA.srate);
xlim([0 50]), ylim([-60 60]);
title("EEG channel " + chan_name + " - after ICA artifact removal");
% EEG_EMD
nexttile;
pwelch(EEG_EMD.data(1, :), [], [], [], EEG_EMD.srate);
xlim([0 50]), ylim([-60 60]);
title("EEG channel " + chan_name + " - after EMD artifact removal");

%% Plotting PSD results
chan_name = EEG.chanlocs(1).labels; % Get the name of the first channel
figure;
% EEG
pwelch(EEG.data(1, :), [], [], [], EEG.srate);
hold on;
% EEG_wavelet
pwelch(EEG_wavelet.data(1, :), [], [], [], EEG_wavelet.srate);
hold on;
% EEG_ICA
pwelch(EEG_ICA.data(1, :), [], [], [], EEG_ICA.srate);
hold on;
% EEG_EMD
pwelch(EEG_EMD.data(1, :), [], [], [], EEG_EMD.srate);
xlim([0 50]), ylim([-60 60]);
legend(["Raw EEG", "Wavelet", "ICA", "EMD"]);
title("EEG channel " + chan_name);

%% Root Mean Square Error (RMSE) between the three methods
E_wave_norm = rmse(EEG_wavelet.data(1, :), EEG.data(1, :));
E_ica_norm = rmse(EEG_ICA.data(1, :), EEG.data(1, :));
E_emd_norm = rmse(EEG_EMD.data(1, :), EEG.data(1, :));

% Display RMSE values
disp(['RMSE between wavelet and original: ', num2str(E_wave_norm)]);
disp(['RMSE between ICA and original: ', num2str(E_ica_norm)]);
disp(['RMSE between EMD and original: ', num2str(E_emd_norm)]);

% RMSE bar chart
figure;
bar([E_wave_norm, E_ica_norm, E_emd_norm], 'FaceColor', [0.2 0.6 0.8]);
set(gca, 'XTickLabel', {'Wavelet', 'ICA', 'EMD'});
ylabel('RMSE (dB/Hz)');
title('RMSE on Raw data');
grid on;

%% 1-48 Hz bandpass filter
EEG = pop_tesa_filtbutter( EEG, 1, 48, 4, 'bandpass' );
EEG_wavelet = pop_tesa_filtbutter( EEG_wavelet, 1, 48, 4, 'bandpass' ); 
EEG_ICA = pop_tesa_filtbutter( EEG_ICA, 1, 48, 4, 'bandpass' );
EEG_EMD = pop_tesa_filtbutter( EEG_EMD, 1, 48, 4, 'bandpass' ); 


%% EEGplot
pop_eegplot(EEG, 1, 1, 1, 1, 'title', 'Original EEG');
pop_eegplot(EEG_wavelet, 1, 1, 1, 1, 'title', 'EEG - Wavelet Artifact Removal');
pop_eegplot(EEG_ICA, 1, 1, 1, 1, 'title', 'EEG - ICA Artifact Removal');
pop_eegplot(EEG_EMD, 1, 1, 1, 1, 'title', 'EEG - EMD Artifact Removal');