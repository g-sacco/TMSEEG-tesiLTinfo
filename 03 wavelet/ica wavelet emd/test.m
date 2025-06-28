%% step 0
clear; close all; clc;

% alberto8_tdcs_epoched: raw data epoched around TMS pulse
filepath = '..';
filename = 'alberto8_tdcs_epoched.set';

%% Import data to EEGLAB
EEG = pop_loadset('filename', filename, 'filepath', filepath);
EOG = EEG.data(3, :);

% remove unused channels
EEG = pop_select(EEG, 'nochannel', {'TRIG1' 'TRIG2' 'EOG' 'GATE' 'P2' 'P3'});

%% Remove bad electrodes
EEG = pop_rejchan(EEG, 'elec', 1:size(EEG.data,1) , ...
    'threshold',5, ...
    'norm','on',['' ...
    'measure'],'kurt');

%% low pass filter
EEG_low = pop_tesa_filtbutter( EEG, 1, 48, 4, 'bandpass' );

%% downsample
EEG_low_down = pop_resample(EEG_low, 200);

FC = EEG.data(1, :);
FC_low = EEG_low.data(1, :);
FC_low_down = EEG_low_down.data(1, :);