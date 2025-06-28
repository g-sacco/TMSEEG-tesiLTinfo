clear; close all; clc;

filepath = 'C:\\Users\\Utente\OneDrive - Università degli Studi di Milano-Bicocca\\unimib\\Stage\\codice\\tesa on real data\\';
fileprefix = 'alberto8_tdcs_before';
filename = [fileprefix, '.set'];

EEG_before = pop_loadset('filename', filename, 'filepath', filepath);


filepath = 'C:\\Users\\Utente\OneDrive - Università degli Studi di Milano-Bicocca\\unimib\\Stage\\codice\\tesa on real data\\';
fileprefix = 'alberto8_tdcs_cleaned';
filename = [fileprefix, '.set'];

EEG_after = pop_loadset('filename', filename, 'filepath', filepath);

%% 1. Average TEP per channel
% Average across trials
TEP_before = mean(EEG_before.data, 3);  % [channels x time]
TEP_after  = mean(EEG_after.data, 3);   % [channels x time]

% Time vector
t = linspace(EEG_before.xmin, EEG_before.xmax, EEG_before.pnts);  % in seconds

%% 2. Plot Example TEP at Cz or Another Electrode

% Select electrode (e.g., Cz)
chanLabel = 'Cz';
chanIdx = find(strcmpi({EEG_before.chanlocs.labels}, chanLabel));

figure;
plot(t, TEP_before(chanIdx, :), 'r-', 'LineWidth', 2); hold on;
plot(t, TEP_after(chanIdx, :), 'b-', 'LineWidth', 2);
legend('Before Preprocessing', 'After Preprocessing');
xlabel('Time (s)');
ylabel('Amplitude (µV)');
title(['TEP at ' chanLabel]);
grid on;

%% 3. Plot All Channels (Global Comparison)
figure;
subplot(2,1,1);
plot(t, TEP_before');  % Transpose for time on x-axis
title('TEP Before Preprocessing');
xlabel('Time (s)'); ylabel('Amplitude (µV)');
ylim([-4 4]);

subplot(2,1,2);
plot(t, TEP_after');
title('TEP After Preprocessing');
xlabel('Time (s)'); ylabel('Amplitude (µV)');
ylim([-4 4]);

%% 4. Topographic Plots of TEP at Specific Timepoints (Optional)
latency_ms = 100;
[~, idx] = min(abs(t*1000 - latency_ms));  % Time index near 100 ms

% Get common color scale limits
vmin = min([TEP_before(:,idx); TEP_after(:,idx)]);
vmax = max([TEP_before(:,idx); TEP_after(:,idx)]);

figure;

% --- BEFORE ---
subplot(1,2,1);
topoplot(TEP_before(:,idx), EEG_before.chanlocs, ...
    'maplimits', [vmin vmax]);
title('Before - 100 ms');
cb1 = colorbar;
ylabel(cb1, 'Amplitude (μV)');

% --- AFTER ---
subplot(1,2,2);
topoplot(TEP_after(:,idx), EEG_after.chanlocs, ...
    'maplimits', [vmin vmax]);
title('After - 100 ms');
cb2 = colorbar;
ylabel(cb2, 'Amplitude (μV)');
