function plotAvgTEP(EEG)
    % 1. Average TEP per channel
    % Average across trials
    TEP = mean(EEG.data, 3);  % [channels x time]
    
    % Time vector
    t = linspace(EEG.xmin, EEG.xmax, EEG.pnts);  % in seconds
    
    % 3. Plot All Channels (Global Comparison)
    figure;
    plot(t, TEP');  % Transpose for time on x-axis
    title('TEP (mean)');
    xlabel('Time (s)'); ylabel('Amplitude (µV)');
    ylim([-4 4]);
end
