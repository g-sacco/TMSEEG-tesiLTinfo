function visualization_suite(results, config)
    %% Create comprehensive visualizations for method comparison
    % Input: results - structure containing all EEG data
    %        config - configuration structure
    
    chan_name = results.EEG_original.chanlocs(1).labels;
    
    % Pre-calculate PSDs and difference signals to avoid redundancy
    [psd_data, diff_signals] = calculate_common_data(results);
    
    % 1. Individual PSD plots (4 subplots)
    plot_individual_psd(results, chan_name, config);
    
    % 2. Overlaid PSD comparison
    plot_overlaid_psd(psd_data, chan_name, config);
    
    % 3. RMSE comparison
    plot_rmse_comparison(results, chan_name);
    
    % 4. EEG plot comparisons (after filtering)
    plot_eeg_comparisons(results, config);

    % 5. Difference signal plots
    plot_eeg_signal_differences(diff_signals, config);
    
    % 6. PSD of removed signals
    plot_removed_signal_psd(diff_signals, psd_data, chan_name, config);
end

function [psd_data, diff_signals] = calculate_common_data(results)
    %% Pre-calculate PSDs and difference signals to avoid redundancy
    
    % Calculate PSDs for all methods
    [psd_data.pxx_orig, psd_data.f] = pwelch(results.EEG_original.data(1, :), [], [], [], results.EEG_original.srate);
    [psd_data.pxx_wave, ~] = pwelch(results.EEG_wavelet.data(1, :), [], [], [], results.EEG_wavelet.srate);
    [psd_data.pxx_ica, ~] = pwelch(results.EEG_ICA.data(1, :), [], [], [], results.EEG_ICA.srate);
    [psd_data.pxx_emd, ~] = pwelch(results.EEG_EMD.data(1, :), [], [], [], results.EEG_EMD.srate);
    
    % Calculate difference signals
    diff_signals.wavelet = EEG_difference(results.EEG_original, results.EEG_wavelet);
    diff_signals.ica = EEG_difference(results.EEG_original, results.EEG_ICA);
    diff_signals.emd = EEG_difference(results.EEG_original, results.EEG_EMD);
    
    % Calculate PSDs for difference signals
    [psd_data.pxx_diff_wave, ~] = pwelch(diff_signals.wavelet.data(1, :), [], [], [], diff_signals.wavelet.srate);
    [psd_data.pxx_diff_ica, ~] = pwelch(diff_signals.ica.data(1, :), [], [], [], diff_signals.ica.srate);
    [psd_data.pxx_diff_emd, ~] = pwelch(diff_signals.emd.data(1, :), [], [], [], diff_signals.emd.srate);
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

function plot_overlaid_psd(psd_data, chan_name, config)
    %% Plot overlaid PSD for direct comparison using pre-calculated data
    
    figure('Name', 'Overlaid PSD Comparison', 'NumberTitle', 'off');
    
    % Plot all PSDs on the same axes using pre-calculated data
    semilogy(psd_data.f, psd_data.pxx_orig, 'k-', 'LineWidth', 1.5); hold on;
    semilogy(psd_data.f, psd_data.pxx_wave, 'b-', 'LineWidth', 1.5);
    semilogy(psd_data.f, psd_data.pxx_ica, 'r-', 'LineWidth', 1.5);
    semilogy(psd_data.f, psd_data.pxx_emd, 'g-', 'LineWidth', 1.5);
    
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
    
    % Calculate RMSE values directly without separate function
    rmse_values = [
        rmse(results.EEG_wavelet.data(1, :), results.EEG_original.data(1, :));
        rmse(results.EEG_ICA.data(1, :), results.EEG_original.data(1, :));
        rmse(results.EEG_EMD.data(1, :), results.EEG_original.data(1, :))
    ];
    
    % Display RMSE values in command window
    fprintf('\nRMSE Analysis:\n');
    fprintf('RMSE between Wavelet and original: %.4f db/Hz\n', rmse_values(1));
    fprintf('RMSE between ICA and original: %.4f db/Hz\n', rmse_values(2));
    fprintf('RMSE between EMD and original: %.4f db/Hz\n', rmse_values(3));
    
    % Create bar chart
    figure('Name', 'RMSE Comparison', 'NumberTitle', 'off');
    bar(rmse_values, 'FaceColor', [0.2 0.6 0.8]);
    set(gca, 'XTickLabel', {'Wavelet', 'ICA', 'EMD'});
    ylabel('RMSE (db/Hz)');
    title(sprintf('RMSE Comparison for Channel %s', chan_name));
    grid on;
    
    % Display values on bars
    for i = 1:length(rmse_values)
        text(i, rmse_values(i) + max(rmse_values)*0.02, ...
             sprintf('%.3f', rmse_values(i)), ...
             'HorizontalAlignment', 'center');
    end
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
    %% Apply bandpass filter to all EEG datasets using helper function
    
    filter_params = {config.filter.low_freq, config.filter.high_freq, ...
                    config.filter.order, config.filter.type};
    
    results_filtered.EEG_original = pop_tesa_filtbutter(results.EEG_original, filter_params{:});
    results_filtered.EEG_wavelet = pop_tesa_filtbutter(results.EEG_wavelet, filter_params{:});
    results_filtered.EEG_ICA = pop_tesa_filtbutter(results.EEG_ICA, filter_params{:});
    results_filtered.EEG_EMD = pop_tesa_filtbutter(results.EEG_EMD, filter_params{:});
end

function plot_eeg_signal_differences(diff_signals, config)
    %% Plot difference signals between original and processed EEG using pre-calculated data
    
    % Apply filtering to difference signals
    filter_params = {config.filter.low_freq, config.filter.high_freq, ...
                    config.filter.order, config.filter.type};
    
    diff_wavelet_filt = pop_tesa_filtbutter(diff_signals.wavelet, filter_params{:});
    diff_ica_filt = pop_tesa_filtbutter(diff_signals.ica, filter_params{:});
    diff_emd_filt = pop_tesa_filtbutter(diff_signals.emd, filter_params{:});

    % Plot differences
    pop_eegplot(diff_wavelet_filt, 1, 1, 1, 1, 'title', 'Signal removed - Wavelet');
    pop_eegplot(diff_ica_filt, 1, 1, 1, 1, 'title', 'Signal removed - ICA');
    pop_eegplot(diff_emd_filt, 1, 1, 1, 1, 'title', 'Signal removed - EMD');
end

function EEG_diff = EEG_difference(EEG_original, EEG_processed)
    %% Compute the difference between the original EEG and the processed EEG
    EEG_diff = EEG_original;
    EEG_diff.data = EEG_original.data - EEG_processed.data;
    EEG_diff.setname = 'Difference Signal';
end

function plot_removed_signal_psd(diff_signals, psd_data, chan_name, config)
    %% Plot PSD of the removed signals using pre-calculated data
    
    % Individual PSD plots of removed signals
    figure('Name', 'PSD of Removed Signals - Individual', 'NumberTitle', 'off');
    tiledlayout(3, 1);
    
    % Plot individual PSDs using tiledlayout for consistency
    methods = {'wavelet', 'ica', 'emd'};
    titles = {'Wavelet', 'ICA', 'EMD'};
    
    for i = 1:3
        nexttile;
        pwelch(diff_signals.(methods{i}).data(1, :), [], [], [], diff_signals.(methods{i}).srate);
        xlim(config.plot.freq_limit);
        title(sprintf("Channel %s - Signal removed by %s", chan_name, titles{i}));
        ylabel('PSD (dB/Hz)');
        grid on;
    end
    xlabel('Frequency (Hz)');
    
    % Overlaid comparison of removed signals PSD using pre-calculated data
    figure('Name', 'PSD of Removed Signals - Comparison', 'NumberTitle', 'off');
    
    % Plot overlaid PSDs using pre-calculated data
    semilogy(psd_data.f, psd_data.pxx_diff_wave, 'b-', 'LineWidth', 1); hold on;
    semilogy(psd_data.f, psd_data.pxx_diff_ica, 'r-', 'LineWidth', 1);
    semilogy(psd_data.f, psd_data.pxx_diff_emd, 'g-', 'LineWidth', 1);
    
    xlim(config.plot.freq_limit);
    xlabel('Frequency (Hz)');
    ylabel('Power Spectral Density (dB/Hz)');
    title(sprintf("Channel %s - Comparison of Removed Signal PSDs", chan_name));
    legend({'Wavelet Removed', 'ICA Removed', 'EMD Removed'}, 'Location', 'best');
    grid on;
    hold off;
    
    % Print statistics about the removed signals
    fprintf('\nRemoved Signal Analysis:\n');
    fprintf('RMS of signal removed by Wavelet: %.4f μV\n', rms(diff_signals.wavelet.data(1, :)));
    fprintf('RMS of signal removed by ICA: %.4f μV\n', rms(diff_signals.ica.data(1, :)));
    fprintf('RMS of signal removed by EMD: %.4f μV\n', rms(diff_signals.emd.data(1, :)));
    
    % Calculate dominant frequency of removed signals using pre-calculated data
    [~, idx_wave] = max(psd_data.pxx_diff_wave);
    [~, idx_ica] = max(psd_data.pxx_diff_ica);
    [~, idx_emd] = max(psd_data.pxx_diff_emd);
    
    fprintf('Dominant frequency of Wavelet removed signal: %.2f Hz\n', psd_data.f(idx_wave));
    fprintf('Dominant frequency of ICA removed signal: %.2f Hz\n', psd_data.f(idx_ica));
    fprintf('Dominant frequency of EMD removed signal: %.2f Hz\n', psd_data.f(idx_emd));
end
