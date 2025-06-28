function EEG = preprocess_eeg(config)
    %% Preprocess EEG data: load, clean, and prepare for artifact removal
    % Input: config - configuration structure
    % Output: EEG - preprocessed EEG structure with EOG events
    
    % Import data to EEGLAB
    EEG = pop_loadset('filename', config.filename, 'filepath', config.filepath);
    
    % Store EOG data before removing the channel
    EOG = EEG.data(3, :);
    
    % Remove unused channels
    EEG = pop_select(EEG, 'nochannel', config.channels_to_remove);
    
    % Remove bad electrodes
    EEG = pop_rejchan(EEG, 'elec', 1:size(EEG.data,1), ...
        'threshold', config.rejection_threshold, ...
        'norm', 'on', ...
        'measure', config.rejection_measure);
    
    % Add EOG events to dataset
    EEG = add_eog_events(EEG, EOG, config);
end

function EEG = add_eog_events(EEG, EOG, config)
    %% Add EOG events to EEG structure based on peak detection
    
    % Create time vector
    time = 0:1/EEG.srate:length(EOG)/EEG.srate - 1/EEG.srate;
    
    % Find peaks in EOG signal
    threshold = mean(EOG) + config.eog_threshold_multiplier * std(EOG);
    min_peak_distance = config.min_peak_distance_factor * EEG.srate;
    
    [pks, locs] = findpeaks(EOG, 'MinPeakHeight', threshold, ...
                                 'MinPeakDistance', min_peak_distance);
    
    % Plot found peaks for visualization
    plot_eog_peaks(time, EOG, locs, pks, threshold);
    
    % Add EOG events to existing events
    num_existing_events = length(EEG.event);
    for i = 1:length(locs)
        EEG.event(num_existing_events + i).latency = locs(i);
        EEG.event(num_existing_events + i).type = 'EOG';
    end
end

function plot_eog_peaks(time, EOG, locs, pks, threshold)
    %% Plot EOG signal with detected peaks
    
    figure('Name', 'EOG Peak Detection', 'NumberTitle', 'off');
    plot(time, EOG);
    hold on;
    plot(locs/length(time)*time(end), pks, 'ro', 'MarkerFaceColor', 'r');
    yline(threshold, '--r', 'Threshold');
    title('EOG - Ocular Artifacts Detection');
    xlabel('Time [s]');
    ylabel('Amplitude [μV]');
    legend('EOG Signal', 'Detected Peaks', 'Threshold');
    grid on;
    hold off;
end
