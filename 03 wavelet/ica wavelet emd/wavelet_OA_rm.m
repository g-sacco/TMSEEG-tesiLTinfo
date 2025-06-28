%% Wavelet Ocular Artifacts Removal
function EEG = wavelet_OA_rm(EEG, levels, wname, levelsToRemove)
    % Example: wavelet_OA_rm(EEG, 12, 'db4', 7:12);
    
    for chanIdx = 1:EEG.nbchan
        % decomposizione wavelet
        [c, l] = wavedec(EEG.data(chanIdx, :), levels, wname);

        % costruisco gli indici cumulativi per ogni blocco di coefficienti
        % idx(i) = somma di l(1:i-1), quindi il primo coefficiente di blocco i è idx(i)+1
        idx = [0, cumsum(l)];

        for k = levelsToRemove
            entry = levels - k + 2;
            startIdx = idx(entry) + 1;
            endIdx   = idx(entry+1);
            c(startIdx:endIdx) = 0;
        end

        % ricostruisco il segnale
        EEG.data(chanIdx, :) = waverec(c, l, wname);
    end
end
