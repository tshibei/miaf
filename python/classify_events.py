# classify_events.py — Run the HFO classification step on precomputed detections and features
#
# This script demonstrates the HFO classification step of the pipeline.
# It classifies HFO events using a pretrained model.
#
# Output:
#   - Classification results saved as 'example_classified_hfo_events.csv' in 'outputs/' folder
#
# Author: Shi-Bei (Ashley) Tan (tashibei@umich.edu)
# Copyright (c) 2025 Shi-Bei Tan
# License: CC BY-NC 4.0

import os
import time
from dataclasses import dataclass

import h5py
import numpy as np
import tyro
from scipy.io import loadmat

from classification.classify_hfos import classify_hfos
from utils.convert_indices_to_zero_based import convert_indices_to_zero_based
from utils.load_and_validate_model import load_and_validate_model
from utils.save_classification_results import save_classification_results
from utils.validateAndCheckType import validate_and_check_type
from utils.validateAndConvertIntFields import validate_and_convert_int_fields

def classify_events(
    *,
    input_data_dir,
    detected_hfo_events_file,
    sampling_rate_file,
    model_dir,
    model_file,
    output_dir,
    preprocessed_eeg_file,
    preprocessed_channel_info_file,
    classified_hfo_events_file,
    hfo_event_features_file,
):
    """Run the HFO classification step on precomputed detections and features.

    This function ties together several steps of the pipeline:

    1. Load detected HFO events and convert indices to 0-based.
    2. Load the sampling rate and a pretrained classification model.
    3. Load preprocessed EEG and channel information (exported from MATLAB).
    4. Load per-event feature matrix ``X`` from a MATLAB ``.mat`` file.
    5. Classify each event and save the results as a CSV file.

    All file paths are interpreted relative to the repository root using the
    provided directory and filename arguments. The function assumes that
    preprocessing and feature extraction have already been run.

    Parameters
    ----------
    input_data_dir : str
        Directory containing input EEG- and event-related ``.mat`` files
        (e.g., detections and sampling rate).
    detected_hfo_events_file : str
        Filename of the detected HFO events ``.mat`` file. Must contain
        integer fields ``start_idx``, ``end_idx`` and ``chan_idx``.
    sampling_rate_file : str
        Filename of the ``.mat`` file that stores the sampling rate under the
        variable name ``fs``.
    model_dir : str
        Directory containing the pretrained classification model.
    model_file : str
        Filename of the model file (e.g., ``.json`` or ``.mat``) that can be
        loaded by ``load_and_validate_model``.
    output_dir : str
        Directory where intermediate preprocessed data, features, and final
        classification results are stored.
    preprocessed_eeg_file : str
        Filename of the preprocessed EEG ``.mat`` file located in
        ``output_dir``. Expected to contain fields
        ``ecog_hfo_raw``, ``ecog_car_raw``, ``depth_hfo_raw``,
        ``depth_car_raw``, ``ecog_hfo_filt``, ``ecog_car_filt``,
        ``depth_hfo_filt``, and ``depth_car_filt`` with shape
        ``[time x channel]`` or be empty.
    preprocessed_channel_info_file : str
        Filename of the preprocessed channel info ``.mat`` file located in
        ``output_dir``. Must contain integer fields ``ecog_chan_idx``,
        ``depth_chan_idx`` and ``good_chan_mask``.
    classified_hfo_events_file : str
        Output filename (CSV) for the classified HFO events, written into
        ``output_dir``.
    hfo_event_features_file : str
        Filename of the MATLAB ``.mat`` file located in ``output_dir`` that
        stores the per-event feature matrix ``X``.

    Raises
    ------
    ValueError
        If any required parameter is missing or empty.
    AssertionError
        If expected files are missing or the data shapes are inconsistent.
    KeyError
        If the feature matrix ``X`` is not found in ``hfo_event_features_file``.
    """

    print("--- HFO Classification ---")
    start = time.time()

    # Validate required parameters
    params = [
        input_data_dir,
        detected_hfo_events_file,
        sampling_rate_file,
        model_dir,
        model_file,
        output_dir,
        preprocessed_eeg_file,
        preprocessed_channel_info_file,
        classified_hfo_events_file,
        hfo_event_features_file,
    ]
    if any(p is None or p == "" for p in params):
        raise ValueError("All required parameters must be provided.")

    # Load and validate HFO events
    detected_hfo_events_filepath = os.path.join("..", input_data_dir, detected_hfo_events_file)
    events = validate_and_convert_int_fields(detected_hfo_events_filepath, ['start_idx', 'end_idx', 'chan_idx'])
    events = convert_indices_to_zero_based(events, ['start_idx', 'end_idx', 'chan_idx'])

    # Load and validate sampling rate
    sampling_rate_path = os.path.join("..", input_data_dir, sampling_rate_file)
    fs = validate_and_check_type(sampling_rate_path, 'fs', float)
    fs = float(np.squeeze(fs))

    # Load and validate model (fixed)
    model_filepath = os.path.join("..", model_dir, model_file)
    model = load_and_validate_model(model_filepath)

    # Load and validate preprocessed data
    preprocessed_eeg_path = os.path.join("..", output_dir, preprocessed_eeg_file)
    assert os.path.isfile(preprocessed_eeg_path), f"Preprocessed EEG file not found: {preprocessed_eeg_path}"
    fields = [
        'ecog_hfo_raw', 
        'ecog_car_raw', 
        'depth_hfo_raw', 
        'depth_car_raw', 
        'ecog_hfo_filt', 
        'ecog_car_filt', 
        'depth_hfo_filt', 
        'depth_car_filt'
    ]
    with h5py.File(preprocessed_eeg_path, "r") as f:
        preprocessed_eeg = {name: f[name][:].T for name in fields}

    # Assert that each field in preprocessed_eeg is [time x channel] by 
    # checking if they are either empty or shape[0] > shape[1]
    for field_name, data in preprocessed_eeg.items():
        if data.size == 0 or np.array_equal( data, np.array([0, 0])):
            preprocessed_eeg[field_name] = np.array([])  # Standardize empty representation
            continue  # Empty is allowed

        assert data.shape[0] > data.shape[1], \
            f"Field '{field_name}' must have shape[0] > shape[1], got shape {data.shape}"
        
    # Load channel info (from separate file)
    preprocessed_channel_info_path = os.path.join("..", output_dir, preprocessed_channel_info_file)
    preprocessed_channel_info = validate_and_convert_int_fields(
        preprocessed_channel_info_path, 
        {'ecog_chan_idx', 'depth_chan_idx', 'good_chan_mask'}
    )
    if np.array_equal( preprocessed_channel_info["depth_chan_idx"], np.array([0, 0])):
        preprocessed_channel_info["depth_chan_idx"] = np.array([])
    else: 
        preprocessed_channel_info = convert_indices_to_zero_based(preprocessed_channel_info, ["depth_chan_idx"])
    if np.array_equal( preprocessed_channel_info["ecog_chan_idx"], np.array([0, 0])):
        preprocessed_channel_info["ecog_chan_idx"] = np.array([])
    else:
        preprocessed_channel_info = convert_indices_to_zero_based(preprocessed_channel_info, ["ecog_chan_idx"])

    sampling_rate_path = os.path.join("..", input_data_dir, sampling_rate_file)
    fs = validate_and_check_type(sampling_rate_path, 'fs', float)
    fs = float(np.squeeze(fs))

    # Feature loading (features expected in output_dir)
    features_path = os.path.join("..", output_dir, hfo_event_features_file)
    assert os.path.isfile(features_path), f"Feature file not found: {features_path}"
    data = loadmat(features_path, squeeze_me=True, struct_as_record=False)
    if "X" in data:
        X = data["X"]
    else:
        raise KeyError(f"Feature matrix 'X' not found in {features_path}")

    # Classification
    labels, scores = classify_hfos(X, model)

    # Save results
    save_classification_results(
        events=events,
        labels=labels,
        scores=scores,
        model=model,
        preprocessed_channel_info=preprocessed_channel_info,
        output_dir=output_dir,
        classified_hfo_events_file=classified_hfo_events_file,
    )

    print(f"Done in {time.time() - start:.2f} seconds.")

@dataclass
class Args:
    input_data_dir: str = "input_data"
    detected_hfo_events_file: str = "example_hfo_events.mat"
    sampling_rate_file: str = "example_sampling_rate.mat"
    model_dir: str = "model"
    model_file: str = "model.json"
    output_dir: str = "outputs"
    preprocessed_eeg_file: str = "example_preprocessed_eeg.mat"
    preprocessed_channel_info_file: str = "example_preprocessed_channel_info.mat"
    classified_hfo_events_file: str = "example_classified_hfo_events.csv"
    hfo_event_features_file: str = "example_hfo_event_features.mat"

if __name__ == "__main__":
    args = tyro.cli(Args)

    classify_events(
        input_data_dir=args.input_data_dir,
        detected_hfo_events_file=args.detected_hfo_events_file,
        sampling_rate_file=args.sampling_rate_file,
        model_dir=args.model_dir,
        model_file=args.model_file,
        output_dir=args.output_dir,
        preprocessed_eeg_file=args.preprocessed_eeg_file,
        preprocessed_channel_info_file=args.preprocessed_channel_info_file,
        classified_hfo_events_file=args.classified_hfo_events_file,
        hfo_event_features_file=args.hfo_event_features_file
    )
