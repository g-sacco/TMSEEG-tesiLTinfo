clear; close all; clc;

filepath = 'C:\\Users\\Utente\OneDrive - Università degli Studi di Milano-Bicocca\\unimib\\Stage\\codice\\SOUND SSP-SIR\\';

% Open EEGLAB
%[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;


%% Data before cleaning
filename = 'alberto8_tdcs_soundsspsir_before.set';
EEG_before = pop_loadset('filename', filename, 'filepath', filepath);

%[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG_before, 0 );

EEG_before = pop_tesa_filtbutter(EEG_before, 1, 48, 4, 'bandpass' ); 

pop_eegplot(EEG_before, 1, 1, 1);

eeglab redraw;

%% Data after cleaning
filename = 'alberto8_tdcs_soundsspsir_cleaned.set';
EEG_after = pop_loadset('filename', filename, 'filepath', filepath);

%[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG_after, 0 );

pop_eegplot(EEG_after, 1, 1, 1);

eeglab redraw;

