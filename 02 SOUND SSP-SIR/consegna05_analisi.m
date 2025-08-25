clear; close all; clc;
data = readtable("C:\Users\Utente\OneDrive - Università degli Studi di Milano-Bicocca\unimib\Trattamento e Codifica di Segnali Multimediali\laboratorio\consegna05\gioco_Session1_Shimmer_5E8A_Calibrated_PC.csv", readVariableNames = true);
data = data{:, :};

Fs = 128;
n_sample = size(data, 1);

plot(data{:, 1});

