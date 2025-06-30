%% Main script for EEG artifact removal comparison
% This script compares three different methods for removing ocular artifacts:
% 1. Wavelet decomposition
% 2. Independent Component Analysis (ICA)
% 3. Empirical Mode Decomposition (EMD)

function main()
    %% Initialize
    clear; close all; clc;
    
    fprintf('=== EEG Artifact Removal Comparison Pipeline ===\n\n');
    
    % Load configuration
    cfg = config();
    
    try
        %% Step 1: Preprocess EEG data
        fprintf('Step 1: Preprocessing EEG data...\n');
        EEG = preprocess_eeg(cfg);
        fprintf('Preprocessing completed successfully.\n\n');
        
        %% Step 2: Apply artifact removal methods
        fprintf('Step 2: Applying artifact removal methods...\n');
        results = artifact_removal_pipeline(EEG, cfg);
        fprintf('All artifact removal methods completed.\n\n');
        
        %% Step 3: Generate visualizations and analysis
        fprintf('Step 3: Generating visualizations and analysis...\n');
        visualization_suite(results, cfg);
        fprintf('Analysis completed successfully.\n\n');
        
        fprintf('=== Pipeline execution completed successfully ===\n');
        
    catch ME
        fprintf('Error occurred during pipeline execution:\n');
        fprintf('Error ID: %s\n', ME.identifier);
        fprintf('Error Message: %s\n', ME.message);
        
        % Print stack trace
        for i = 1:length(ME.stack)
            fprintf('  File: %s, Function: %s, Line: %d\n', ...
                    ME.stack(i).file, ME.stack(i).name, ME.stack(i).line);
        end
        
        rethrow(ME);
    end
end

% Run the main function if this script is executed directly
if ~exist('OCTAVE_VERSION', 'builtin')
    % MATLAB
    if strcmp(mfilename, 'main_pipeline')
        main();
    end
else
    % Octave (if needed)
    main();
end
