%% Wavelet Ocular Artifacts Removal
function EEG = wavelet_OA_rm(EEG)
    levels = 6; % number of levels
    wname = 'db4'; % wavelet name

    for chanIdx = 1:EEG.nbchan
        [c, l] = wavedec(EEG.data(chanIdx, :), levels, wname);

        %{
        approx = appcoef(c,l,"db4");
        cd = detcoef(c,l,[1:10]);
        tiledlayout(11,1)
        nexttile
        plot(approx)
        title("Approximation Coefficients")
        for i = 1:length(cd)
            nexttile
            plot(cd{i})
            title(['Detail Coefficients Level ', num2str(i)])
        end
        %}

        base_value = mean(c(1:l(1)-1));
        % replace the approximation coefficients
        c(1:l(1)-1) = base_value;   
        %c(l(1):l(2)-1) = base_value;
        EEG.data(chanIdx, :) = waverec(c, l, wname);
    end