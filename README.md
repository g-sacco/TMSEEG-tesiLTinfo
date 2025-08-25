# TMSEEG-tesiLTinfo

A collection of MATLAB scripts and pipelines for TMS-EEG signal processing and artifact removal. This repository contains various approaches for cleaning TMS-EEG data, including FastICA, SOUND SSP-SIR, and wavelet-based methods.

## 01 TESA on real data
The folder contains the first implementation of a two-step FastICA pipeline and some script for result comparison.

**Main Scripts:**
- `fastICA_2step.m`: Two-step FastICA implementation using TESA on MATLAB
- `nxe2eeglabset.m`: Script to convert the original .nxe dataset to the EEGLAB compatible .set format, using FieldTrip
- `compare_data_ba_pipeline.m`: Compare the signal before and after the pipeline application
- `plotAvgTEP.m`: Plots the averaged TEP (TMS-evoked potential) of every channel on the same plot

**Data Files (not included in the repo):**
- `alberto8_tdcs_before.set/.fdt`: Original raw data
- `alberto8_tdcs.set/.fdt`: Preprocessed data
- `alberto8_tdcs_tesa_cleaned.set/.fdt`: Data after TESA pipeline cleaning

## 02 SOUND SSP-SIR
The folder contains the implementation of the SOUND SSP-SIR (Signal-space Separation and Signal-space Projection with Source-informed Reconstruction) pipeline for artifact removal.

**Main Scripts:**
- `sound_sspsir.m`: Main implementation of the SOUND SSP-SIR pipeline
- `eegplot_results.m`: Script for plotting EEG results
- `psd.m`: Power spectral density analysis
- `plotAvgTEP.m`: Averaged TEP plotting function

**Data Files:**
- `alberto8_tdcs_epoched.set/.fdt`: Epoched data around TMS pulses
- `alberto8_tdcs_soundsspsir_before.set/.fdt`: Data before SOUND SSP-SIR processing
- `alberto8_tdcs_soundsspsir_cleaned.set/.fdt`: Data after SOUND SSP-SIR cleaning

## 03 Wavelet
The folder contains wavelet-based approaches for ocular artifact removal and comparison studies between different artifact removal methods.

**Subfolders:**
- `compare ICA wavelet/`: Comparison between ICA and wavelet methods
  - `compare_ICA_wavelet.m`: Main comparison script
  - `ICA_OA_rm.m`: ICA-based ocular artifact removal
  - `wavelet_OA_rm.m`: Wavelet-based ocular artifact removal

- `ica wavelet emd/`: Comprehensive comparison of ICA, wavelet, and EMD methods
  - `main_pipeline.m`: Main pipeline orchestrating all methods
  - `artifact_removal_pipeline.m`: Core artifact removal pipeline
  - `compare_ICA_wavelet_EMD.m`: Three-way comparison script
  - `config.m`: Configuration settings
  - `ICA_OA_rm.m`: ICA implementation
  - `wavelet_OA_rm.m`: Wavelet implementation
  - `EMD_OA_rm.m`: Empirical Mode Decomposition implementation
  - `preprocess_eeg.m`: EEG preprocessing utilities
  - `visualization_suite.m`: Comprehensive visualization tools

- `relazione/`: LaTeX documentation and report
## 04 SOUND SSP-SIR with OA wavelet
Integration of SOUND SSP-SIR pipeline with wavelet-based ocular artifact removal.

**Scripts:**
- `sound_sspsir.m`: SOUND SSP-SIR implementation
- `wavelet_OA_rm.m`: Wavelet ocular artifact removal
- `plotAvgTEP.m`: TEP visualization
## Usage
Each folder contains standalone implementations that can be run independently. Make sure you have MATLAB with EEGLAB installed. Some scripts may require additional toolboxes:
- EEGLAB
- FieldTrip (for data conversion)
- TESA (TMS-EEG Signal Analyzer)
- Wavelet Toolbox
- Signal Processing Toolbox