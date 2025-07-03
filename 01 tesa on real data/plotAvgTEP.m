function plotAvgTEP(EEG, plotTitle)
    % 1. Average TEP per channel
    % Average across trials
    TEP = mean(EEG.data, 3);  % [channels x time]
    
    % Time vector
    t = linspace(EEG.xmin, EEG.xmax, EEG.pnts);  % in seconds
    
    % 3. Plot All Channels (Global Comparison)
    figure("Name", plotTitle);
    plot(t, TEP');  % Transpose for time on x-axis
    title(['Average TEP Across Channels - ', char(plotTitle)]);
    xlabel('Time (s)'); ylabel('Amplitude (µV)');
    ylim([-10 10]);
end
