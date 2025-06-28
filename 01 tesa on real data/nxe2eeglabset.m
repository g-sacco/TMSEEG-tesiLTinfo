clear; close all; clc;

filepath = "C:\Users\Utente\OneDrive - Università degli Studi di Milano-Bicocca\unimib\Stage\dati\tDCS Anodica\S1\";
filename = "Alberto_tdcs_8";
ext = ".nxe";

% Read using FieldTrip
cfg = [];
cfg.dataset = filepath + filename + ext;
data = ft_preprocessing(cfg);

% Convert to EEGLAB
EEG = fieldtrip2eeglab(data);

% Fix EEG dimensions
%[nbchan, total_samples] = size(EEG.data);
%EEG.nbchan = nbchan;
%EEG.pnts = total_samples;
%EEG.trials = 1;

% Set filenames correctly
%EEG.filename = [filename + ".set"];
%EEG.filepath = filepath;

% Save EEG set
pop_saveset(EEG);
