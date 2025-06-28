function EEG = EMD_OA_rm(EEG)
    for chanIdx = 1:EEG.nbchan
        [imf, residual] = emd(EEG.data(chanIdx, :), "MaxNumIMF", 5, ...
                                                          "Interpolation", 'pchip', ...
                                                          "SiftRelativeTolerance", 0.2);
        if size(imf, 1) >= 5
            EEG.data(chanIdx, :) = sum(imf(:, [1, 2, 5]), 2) + residual; % Reconstruct the signal from the filtered IMFs and residual
        else
            warning('Channel %d: Not enough IMFs generated. Using all available IMFs.', chanIdx);
            EEG.data(chanIdx, :) = sum(imf, 2) + residual; % Use all available IMFs if fewer than 5
        end
        %plot(EEG.data(chanIdx, :), 'r');
    end
end    
        %{
        for i = 1:size(imf, 2)
            c_imf = imf(:, i);
            % Apply wavelet thresholding to the current IMF
            threshold_high = mean(c_imf) + 3*std(c_imf);
            %figure;
            %plot(c_imf, 'b'), hold on;
            r_imf = wthresh(c_imf, 's', threshold_high); 
            %plot(r_imf, 'r');
            filt_imf = c_imf - r_imf; % Subtract the thresholded IMF from the original IMF
            %figure, plot(filt_imf, 'g');
            imf(:, i) = filt_imf; % Replace the IMF with the filtered version
        end
        figure, plot(EEG.data(chanIdx, :)), hold on;
        %}