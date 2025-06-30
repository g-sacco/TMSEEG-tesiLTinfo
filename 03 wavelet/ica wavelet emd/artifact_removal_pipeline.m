function results = artifact_removal_pipeline(EEG, config)
    %% Apply all three artifact removal methods
    % Input: EEG - preprocessed EEG structure
    %        config - configuration structure
    % Output: results - structure containing all processed EEG data
    
    fprintf('Applying artifact removal methods...\n');
    
    % Highpass filter before artifact removal (improve ICA performance)
    fprintf('  - Highpass filtering EEG data...\n');
    EEG = pop_tesa_filtbutter( EEG, 0.1, [], 4, 'highpass' );

    % Apply wavelet artifact removal
    fprintf('  - Wavelet artifact removal...\n');
    results.EEG_wavelet = wavelet_OA_rm(EEG, config.wavelet.levels, ...
                                       config.wavelet.wavelet_name, ...
                                       config.wavelet.levels_to_remove);
    
    % Apply ICA artifact removal
    fprintf('  - ICA artifact removal...\n');
    results.EEG_ICA = ICA_OA_rm(EEG);
    
    % Apply EMD artifact removal
    fprintf('  - EMD artifact removal...\n');
    results.EEG_EMD = EMD_OA_rm(EEG);
    
    % Store original EEG for comparison
    results.EEG_original = EEG;
    
    fprintf('Artifact removal completed.\n');
end
