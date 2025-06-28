%% Configuration Parameters
function config = config()
    % Centralized configuration for EEG processing pipeline
    
    % File paths
    config.filepath = '..';
    config.filename = 'alberto8_tdcs_epoched.set';
    
    % Channel removal
    config.channels_to_remove = {'TRIG1', 'TRIG2', 'EOG', 'GATE', 'P2', 'P3'};
    
    % Bad electrode rejection
    config.rejection_threshold = 7.5;
    config.rejection_measure = 'kurt';
    
    % EOG peak detection
    config.eog_threshold_multiplier = 1.2;
    config.min_peak_distance_factor = 1; % multiplied by sampling rate
    
    % Artifact removal parameters
    config.wavelet.levels = 12;
    config.wavelet.wavelet_name = 'db4';
    config.wavelet.levels_to_remove = 7:12;
    
    % Filtering parameters
    config.filter.low_freq = 1;
    config.filter.high_freq = 48;
    config.filter.order = 4;
    config.filter.type = 'bandpass';
    
    % Plotting parameters
    config.plot.freq_limit = [0 50];
    config.plot.psd_limit = [-60 60];
end
