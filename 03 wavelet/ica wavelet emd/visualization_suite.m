function visualization_suite(results, config)
    %% Create comprehensive visualizations for method comparison
    % Input: results - structure containing all EEG data
    %        config - configuration structure
    
    chan_name = results.EEG_original.chanlocs(1).labels;
    
    % 1. Individual PSD plots (4 subplots)
    plot_individual_psd(results, chan_name, config);
    
    % 2. Overlaid PSD comparison
    plot_overlaid_psd(results, chan_name, config);
    
    % 3. RMSE comparison
    plot_rmse_comparison(results, chan_name);
    
    % 4. EEG plot comparisons (after filtering)
    plot_eeg_comparisons(results, config);

    % 5. Difference signal plots
    plot_eeg_signal_differences(results);
end

function plot_individual_psd(results, chan_name, config)
    %% Plot individual PSD for each method
    
    figure('Name', 'Individual PSD Comparison', 'NumberTitle', 'off');
    tiledlayout(4, 1);
    
    methods = {'original', 'wavelet', 'ICA', 'EMD'};
    titles = {'before artifact removal', 'after wavelet artifact removal', ...
             'after ICA artifact removal', 'after EMD artifact removal'};
    
    for i = 1:4
        nexttile;
        field_name = sprintf('EEG_%s', methods{i});
        pwelch(results.(field_name).data(1, :), [], [], [], ...
               results.(field_name).srate);
        xlim(config.plot.freq_limit);
        ylim(config.plot.psd_limit);
        title(sprintf("EEG channel %s - %s", chan_name, titles{i}));
        grid on;
    end
end

function plot_overlaid_psd(results, chan_name, config)
    %% Plot overlaid PSD for direct comparison
    
    figure('Name', 'Overlaid PSD Comparison', 'NumberTitle', 'off');
    
    % Plot all PSDs on the same axes
    [pxx_orig, f] = pwelch(results.EEG_original.data(1, :), [], [], [], ...
                          results.EEG_original.srate);
    [pxx_wave, ~] = pwelch(results.EEG_wavelet.data(1, :), [], [], [], ...
                          results.EEG_wavelet.srate);
    [pxx_ica, ~] = pwelch(results.EEG_ICA.data(1, :), [], [], [], ...
                         results.EEG_ICA.srate);
    [pxx_emd, ~] = pwelch(results.EEG_EMD.data(1, :), [], [], [], ...
                         results.EEG_EMD.srate);
    
    semilogy(f, pxx_orig, 'k-', 'LineWidth', 1.5); hold on;
    semilogy(f, pxx_wave, 'b-', 'LineWidth', 1.5);
    semilogy(f, pxx_ica, 'r-', 'LineWidth', 1.5);
    semilogy(f, pxx_emd, 'g-', 'LineWidth', 1.5);
    
    xlim(config.plot.freq_limit);
    xlabel('Frequency (Hz)');
    ylabel('Power Spectral Density (dB/Hz)');
    title(sprintf("EEG channel %s - PSD Comparison", chan_name));
    legend({'Raw EEG', 'Wavelet', 'ICA', 'EMD'}, 'Location', 'best');
    grid on;
    hold off;
end

function plot_rmse_comparison(results, chan_name)
    %% Calculate and plot RMSE comparison
    
    % Calculate RMSE values
    rmse_values = calculate_rmse_metrics(results);
    
    % Create bar chart
    figure('Name', 'RMSE Comparison', 'NumberTitle', 'off');
    bar(rmse_values, 'FaceColor', [0.2 0.6 0.8]);
    set(gca, 'XTickLabel', {'Wavelet', 'ICA', 'EMD'});
    ylabel('RMSE (μV)');
    title(sprintf('RMSE Comparison for Channel %s', chan_name));
    grid on;
    
    % Display values on bars
    for i = 1:length(rmse_values)
        text(i, rmse_values(i) + max(rmse_values)*0.02, ...
             sprintf('%.3f', rmse_values(i)), ...
             'HorizontalAlignment', 'center');
    end
end

function rmse_values = calculate_rmse_metrics(results)
    %% Calculate RMSE between processed and original data
    
    rmse_values = zeros(1, 3);
    rmse_values(1) = rmse(results.EEG_wavelet.data(1, :), results.EEG_original.data(1, :));
    rmse_values(2) = rmse(results.EEG_ICA.data(1, :), results.EEG_original.data(1, :));
    rmse_values(3) = rmse(results.EEG_EMD.data(1, :), results.EEG_original.data(1, :));
    
    % Display RMSE values in command window
    fprintf('\nRMSE Analysis:\n');
    fprintf('RMSE between wavelet and original: %.4f μV\n', rmse_values(1));
    fprintf('RMSE between ICA and original: %.4f μV\n', rmse_values(2));
    fprintf('RMSE between EMD and original: %.4f μV\n', rmse_values(3));
end

function plot_eeg_comparisons(results, config)
    %% Apply filtering and create EEG plots
    
    % Apply bandpass filter to all datasets
    fprintf('Applying bandpass filter (%d-%d Hz)...\n', ...
            config.filter.low_freq, config.filter.high_freq);
    
    results_filtered = apply_bandpass_filter(results, config);
    
    % Create EEG plots
    pop_eegplot(results_filtered.EEG_original, 1, 1, 1, 1, 'title', 'Original EEG');
    pop_eegplot(results_filtered.EEG_wavelet, 1, 1, 1, 1, 'title', 'EEG - Wavelet Artifact Removal');
    pop_eegplot(results_filtered.EEG_ICA, 1, 1, 1, 1, 'title', 'EEG - ICA Artifact Removal');
    pop_eegplot(results_filtered.EEG_EMD, 1, 1, 1, 1, 'title', 'EEG - EMD Artifact Removal');
end

function results_filtered = apply_bandpass_filter(results, config)
    %% Apply bandpass filter to all EEG datasets
    
    results_filtered.EEG_original = pop_tesa_filtbutter(results.EEG_original, ...
        config.filter.low_freq, config.filter.high_freq, config.filter.order, config.filter.type);
    
    results_filtered.EEG_wavelet = pop_tesa_filtbutter(results.EEG_wavelet, ...
        config.filter.low_freq, config.filter.high_freq, config.filter.order, config.filter.type);
    
    results_filtered.EEG_ICA = pop_tesa_filtbutter(results.EEG_ICA, ...
        config.filter.low_freq, config.filter.high_freq, config.filter.order, config.filter.type);
    
    results_filtered.EEG_EMD = pop_tesa_filtbutter(results.EEG_EMD, ...
        config.filter.low_freq, config.filter.high_freq, config.filter.order, config.filter.type);
end

function plot_eeg_signal_differences(results)
    %% Plot difference signals between original and processed EEG
 
    % Calculate differences
    diff_wavelet = EEG_difference(results.EEG_original, results.EEG_wavelet);
    diff_ica = EEG_difference(results.EEG_original, results.EEG_ICA);
    diff_emd = EEG_difference(results.EEG_original, results.EEG_EMD);
    
    % Plot differences
    pop_eegplot(diff_wavelet, 1, 1, 1, 1, 'title', 'Signal removed - Wavelet');
    pop_eegplot(diff_ica, 1, 1, 1, 1, 'title', 'Signal removed - ICA');
    pop_eegplot(diff_emd, 1, 1, 1, 1, 'title', 'Signal removed - EMD');
end

function EEG_diff = EEG_difference(EEG_original, EEG_processed)
    % Compute the difference between the original EEG and the processed EEG
    EEG_diff = EEG_original;
    EEG_diff.data = EEG_original.data - EEG_processed.data;
    EEG_diff.setname = 'Difference Signal';
end