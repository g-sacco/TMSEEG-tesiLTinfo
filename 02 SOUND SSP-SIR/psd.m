clear; close all; clc;

filepath = 'C:\Users\Utente\OneDrive - Università degli Studi di Milano-Bicocca\unimib\Stage\TMSEEG-tesiLTinfo\02 SOUND SSP-SIR\';


%% Data before cleaning
filename_before = 'alberto8_tdcs_soundsspsir_before.set';
EEG_before = pop_loadset('filename', filename_before, 'filepath', filepath);


%% Data after SOUND cleaning
filename_sound = 'alberto8_tdcs_soundsspsir_cleaned.set';
EEG_after = pop_loadset('filename', filename_sound, 'filepath', filepath);

%%Data after ICA
filepath = 'C:\Users\Utente\OneDrive - Università degli Studi di Milano-Bicocca\unimib\Stage\TMSEEG-tesiLTinfo\01 tesa on real data\';
filename_ica = 'alberto8_tdcs_tesa_cleaned.set';
EEG_ica = pop_loadset('filename', filename_ica, 'filepath', filepath);

%% PSD
figure;
hold on;
pwelch(EEG_before.data(1, :), [], [], [], EEG_before.srate);
pwelch(EEG_after.data(1, :), [], [], [], EEG_after.srate);
pwelch(EEG_ica.data(1, :), [], [], [], EEG_ica.srate);
legend({'Raw', 'SOUND/SSP-SIR', 'Two-step FastICA'});
xlim([0 100]);