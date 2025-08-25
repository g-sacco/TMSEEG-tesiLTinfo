%% step 0
clear; close all; clc;

filepath = 'C:\Users\Utente\OneDrive - Università degli Studi di Milano-Bicocca\unimib\Stage\TMSEEG-tesiLTinfo\02 SOUND SSP-SIR\';
fileprefix = 'alberto8_tdcs';

% Open EEGLAB
%[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

%% Step 1: Import data to EEGLAB
filename = [fileprefix, '.set'];
EEG = pop_loadset('filename', filename, 'filepath', filepath);

%% Step 2: Load channel locations (note that you might need to change the file location here for your computer).
EEG = pop_chanedit(EEG, 'lookup','C:\Users\Utente\AppData\Roaming\MathWorks\MATLAB Add-Ons\Collections\eeglab2025.0.0\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp');

%% Step 3: Add TMS pulse events 
EEG = pop_chanevent(EEG, 1, ...
    'oper', 'X > 4', ... 
    'edge', 'leading', ...      % extract rising edges (typical for TMS triggers)
    'edgelen', 1, ...           % samples to tolerate for edge detection
    'delevent', 'on', ...       % remove old events
    'nbtype', 1, ...            % treat all triggers as same event type
    'typename', 'TMS', ...      % name the event type
    'delchan', 'on');           % delete the GATE channel

%% Step 4: Epoch data (-1000 to 1000 ms)
EEG = pop_epoch(EEG, {'TMS'}, [-1 1.00069], 'epochinfo', 'yes');

%% Save point
filename = [fileprefix,'_epoched.set'];
EEG = pop_saveset( EEG, 'filename',filename,'filepath',filepath);


%% Step 5: Remove unused electrodes
EEG = pop_select(EEG, 'nochannel', {'TRIG1' 'TRIG2' 'EOG'});

%Save the original EEG locations for use in interpolation later
EEG.allchan = EEG.chanlocs;

%% Step 6: Remove bad electrodes
EEG = pop_rejchan(EEG, 'elec', [1:size(EEG.data,1)] , ...
    'threshold',7.5, ...
    'norm','on',['' ...
    'measure'],'kurt');

%% Step 7: Remove bad trials (automatic)
EEG = pop_jointprob(EEG,1,[1:size(EEG.data,1)] ,5,5,0,0);
% Automatically identify bad trials based on joint probability
EEG.BadTr = find(EEG.reject.rejjp == 1);
fprintf('Automatically detected %d bad trials\n', length(EEG.BadTr));
EEG = pop_rejepoch(EEG, EEG.BadTr, 0); 

%% Save point
filename = [fileprefix,'_soundsspsir_before.set'];
EEG = pop_saveset( EEG, 'filename',filename,'filepath',filepath);

eeglab redraw;

plotAvgTEP(EEG);

%% Step 8: Highpass filter before ICA (0.1 Hz)
EEG = pop_tesa_filtbutter( EEG, 0.1, [], 4, 'highpass' ); 

plotAvgTEP(EEG);

%% Step 9: Wavelet for ocular artifacts
EEG = wavelet_OA_rm(EEG, 12, 'db4', 7:12);

plotAvgTEP(EEG);

%% Step 10: SOUND for noise removal
EEG = pop_tesa_sound(EEG, 'lambdaValue', 0.1, ...
                          'iter', 5); 

%% Step 11: Baseline correction
EEG = pop_rmbase(EEG, [-1000 0]);
plotAvgTEP(EEG);

%% Step 12: SSP SIR for remaining muscle artifact
[EEG] = pop_tesa_sspsir(EEG, 'PC', {'data', 90});
plotAvgTEP(EEG);

%% Step 13: Bandpass and bandstop filter
%EEG = pop_tesa_filtbutter( EEG, 1, 100, 4, 'bandpass' ); 
%EEG = pop_tesa_filtbutter( EEG, 48, 52, 4, 'bandstop' );
EEG = pop_tesa_filtbutter( EEG, 1, 48, 4, 'bandpass' ); 

%% Step 14: Baseline correction
EEG = pop_rmbase(EEG, [-1000 0]);
plotAvgTEP(EEG);

%% Step 15: Downsample data
EEG = pop_resample(EEG, 725);

%% Save point
filename = [fileprefix,'_soundsspsir_cleaned.set'];
EEG = pop_saveset( EEG, 'filename',filename,'filepath',filepath);

eeglab redraw;