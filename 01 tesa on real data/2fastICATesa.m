%% step 0
%clear; close all; clc;

filepath = 'C:\\Users\\Utente\OneDrive - Università degli Studi di Milano-Bicocca\\unimib\\Stage\\codice\\tesa on real data\\';
fileprefix = 'alberto8_tdcs';

% Open EEGLAB
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

%% Step 1: Import data to EEGLAB
filename = [fileprefix, '.set'];
EEG = pop_loadset('filename', filename, 'filepath', filepath);

%% Step 2: Load channel locations (note that you might need to change the file location here for your computer).
EEG = pop_chanedit(EEG, 'lookup','C:\Users\Utente\AppData\Roaming\MathWorks\MATLAB Add-Ons\Collections\eeglab2025.0.0\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp');

%% Step 4: Find TMS pulses (if no triggers recorded) - skipped
%GATE = EEG.data(1, :);
%stem(GATE);
EEG = pop_chanevent(EEG, 1, ...
    'oper', 'X > 4', ... 
    'edge', 'leading', ...      % extract rising edges (typical for TMS triggers)
    'edgelen', 1, ...           % samples to tolerate for edge detection
    'delevent', 'on', ...       % remove old events
    'nbtype', 1, ...            % treat all triggers as same event type
    'typename', 'TMS', ...      % name the event type
    'delchan', 'on');          % do NOT delete the GATE channel

%% Step 3: Remove unused electrodes
EEG = pop_select(EEG, 'nochannel', {'TRIG1' 'TRIG2' 'EOG'});

%Save the original EEG locations for use in interpolation later
EEG.allchan = EEG.chanlocs;

%% Step 5: Remove bad electrodes
EEG = pop_rejchan(EEG, 'elec', [1:size(EEG.data,1)] , ...
    'threshold',5, ...
    'norm','on',['' ...
    'measure'],'kurt');

%% Step 10: Downsample data
EEG = pop_resample(EEG, 725);

%% Step 6: Epoch data (-1000 to 1000 ms)
EEG = pop_epoch(EEG, {'TMS'}, [-1 1.00069], 'epochinfo', 'yes');

%% Step 7: Demean data (-1000 ms to 1000 ms)
EEG = pop_rmbase(EEG, [-1000 1000]);

%% Step 11: Remove bad trials  
EEG = pop_jointprob(EEG,1,[1:size(EEG.data,1)] ,5,5,0,0);
%pop_rejmenu(EEG,1);
%pause_script = input('Highlight bad trials, update marks and then press enter');
%EEG.BadTr = unique([find(EEG.reject.rejjp==1) find(EEG.reject.rejmanual==1)]);
EEG.BadTr = find(EEG.reject.rejjp == 1);
EEG = pop_rejepoch(EEG, EEG.BadTr, 0); 

%% Save point
filename = [fileprefix,'_before.set'];
EEG = pop_saveset( EEG, 'filename',filename,'filepath',filepath);

eeglab redraw;

plotAvgTEP(EEG);

%% Step 13: Remove TMS-evoked muscle activity (using FastICA and auto component selection)
EEG = pop_tesa_fastica( EEG, 'approach', 'symm', 'g', 'tanh', 'stabilization', 'off' );
EEG = pop_tesa_compselect( EEG,'comps',15,'figSize','small','plotTimeX',[-200 500],'plotFreqX',[1 100],'tmsMuscle','on','tmsMuscleThresh',8,'tmsMuscleWin',[11 30],'tmsMuscleFeedback','off','blink','off','blinkThresh',2.5,'blinkElecs',{'Fp1','Fp2'},'blinkFeedback','off','move','off','moveThresh',2,'moveElecs',{'F7','F8'},'moveFeedback','off','muscle','off','muscleThresh',0.6,'muscleFreqWin',[30 100],'muscleFeedback','off','elecNoise','off','elecNoiseThresh',4,'elecNoiseFeedback','off' );

plotAvgTEP(EEG);

%% Step 16: Bandpass (1-100 Hz) and bandstop (48-52 Hz) filter data
%EEG = pop_tesa_filtbutter( EEG, 1, 100, 4, 'bandpass' ); 
%EEG = pop_tesa_filtbutter( EEG, 48, 52, 4, 'bandstop' );
EEG = pop_tesa_filtbutter( EEG, 1, 48, 4, 'bandpass' ); 

plotAvgTEP(EEG);

%% Step 18: Remove all other artifacts (using FastICA and auto component selection)
% ho dovuto modificare muscleFreqWin in muscleFreqIn
EEG = pop_tesa_fastica( EEG, 'approach', 'symm', 'g', 'tanh', 'stabilization', 'off' );
EEG = pop_tesa_compselect( EEG,'compCheck','on','comps',[],'figSize','small','plotTimeX',[-200 500],'plotFreqX',[1 100],'tmsMuscle','on','tmsMuscleThresh',8,'tmsMuscleWin',[11 30],'tmsMuscleFeedback','off','blink','on','blinkThresh',2.5,'blinkElecs',{'Fp1','Fp2'},'blinkFeedback','off','move','on','moveThresh',2,'moveElecs',{'F7','F8'},'moveFeedback','off','muscle','on','muscleThresh',0.6,'muscleFreqIn',[30 100],'muscleFeedback','off','elecNoise','on','elecNoiseThresh',4,'elecNoiseFeedback','off' );

plotAvgTEP(EEG);

%% Step 20: Interpolate missing channels
%EEG = pop_interp(EEG, EEG.allchan, 'spherical');

%% Step 21: Re-reference to average
EEG = pop_reref( EEG, []);

plotAvgTEP(EEG);

%% Save point
filename = [fileprefix,'_cleaned.set'];
EEG = pop_saveset( EEG, 'filename',filename,'filepath',filepath);

eeglab redraw;