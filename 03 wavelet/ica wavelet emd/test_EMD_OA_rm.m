%% step 0
clear; close all; clc;

% alberto8_tdcs_epoched: raw data epoched around TMS pulse
filepath = '..';
filename = 'alberto8_tdcs_epoched.set';

%% Import data to EEGLAB
EEG = pop_loadset('filename', filename, 'filepath', filepath);

%% low pass filter
EEG = pop_tesa_filtbutter( EEG, 1, 48, 4, 'bandpass' );

%% downsample
EEG = pop_resample(EEG, 200);

%% EOG
EOG = EEG.data(3, :);

%% remove unused channels
EEG = pop_select(EEG, 'nochannel', {'TRIG1' 'TRIG2' 'EOG' 'GATE' 'P2' 'P3'});

%% Remove bad electrodes
EEG = pop_rejchan(EEG, 'elec', 1:size(EEG.data,1) , ...
    'threshold',5, ...
    'norm','on',['' ...
    'measure'],'kurt');

%% Add EOG events to dataset
time = 0:1/EEG.srate:length(EOG)/EEG.srate - 1/EEG.srate;

% FIND PEAKS
threshold = mean(EOG) + 1.2 * std(EOG);
[pks, locs] = findpeaks(EOG, 'MinPeakHeight', threshold, ...
                             'MinPeakDistance', EEG.srate);
% Plot found peaks
%figure;
%plot(time, EOG), hold on;
%plot(locs/EEG.srate, pks, 'ro', 'MarkerFaceColor', 'r');
%yline(threshold, '--r', 'Threshold');
%title("EOG - ocular artifacts"), xlabel("Time [s]"), ylabel("Amplitude [uV]");

% Add EOG events to EEG.event without removing existing events (e.g., TMS)
numExistingEvents = length(EEG.event);
for i = 1:length(locs)
    EEG.event(numExistingEvents + i).latency = locs(i);
    EEG.event(numExistingEvents + i).type = 'EOG';
end
%EEG = eeg_checkset(EEG, 'eventconsistency');


%% Remove ocular artifacts
pop_eegplot(EEG, 1, 1, 1, 1);
EEG_EMD = EMD_OA_rm(EEG);
pop_eegplot(EEG_EMD, 1, 1, 1, 1);