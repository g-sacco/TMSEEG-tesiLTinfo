function EEG = wavelet_OA_rm(EEG, levels, wname, levelsToRemove)
    %% Wavelet-based Ocular Artifact Removal
    % Removes ocular artifacts from EEG data using wavelet decomposition
    %
    % Inputs:
    %   EEG            - EEGLAB EEG structure
    %   levels         - Number of decomposition levels (e.g., 12)
    %   wname          - Wavelet name (e.g., 'db4')
    %   levelsToRemove - Array of levels to zero out (e.g., 7:12)
    %
    % Output:
    %   EEG            - EEG structure with artifacts removed
    %
    % Example: EEG_clean = wavelet_OA_rm(EEG, 12, 'db4', 7:12);
    
    % Input validation
    if nargin < 4
        error('wavelet_OA_rm:InvalidInput', 'All four input arguments are required');
    end
    
    if ~isstruct(EEG) || ~isfield(EEG, 'data')
        error('wavelet_OA_rm:InvalidEEG', 'First argument must be a valid EEG structure');
    end
    
    if levels <= 0 || ~isscalar(levels)
        error('wavelet_OA_rm:InvalidLevels', 'Levels must be a positive scalar');
    end
    
    fprintf('Applying wavelet artifact removal using %s wavelet with %d levels...\n', wname, levels);
    
    for chanIdx = 1:EEG.nbchan
        % Wavelet decomposition
        [c, l] = wavedec(EEG.data(chanIdx, :), levels, wname);

        % Build cumulative indices for each coefficient block
        % idx(i) = sum of l(1:i-1), so first coefficient of block i is idx(i)+1
        idx = [0, cumsum(l)];

        % Zero out specified levels
        for k = levelsToRemove
            entry = levels - k + 2;
            
            % Bounds checking
            if entry > length(idx) - 1
                warning('wavelet_OA_rm:InvalidLevel', ...
                       'Level %d is out of bounds for channel %d', k, chanIdx);
                continue;
            end
            
            startIdx = idx(entry) + 1;
            endIdx   = idx(entry + 1);
            c(startIdx:endIdx) = 0;
        end

        % Reconstruct signal
        EEG.data(chanIdx, :) = waverec(c, l, wname);
    end
    
    fprintf('Wavelet artifact removal completed for %d channels.\n', EEG.nbchan);
end
