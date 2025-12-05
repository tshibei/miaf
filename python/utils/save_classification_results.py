import os
import pandas as pd
import numpy as np

def save_classification_results(events, labels, scores, model,
                                preprocessed_channel_info, output_dir, classified_hfo_events_file):
    """
    Save HFO classification outputs to a CSV file.

    Parameters
    ----------
    events : dict
        Dictionary containing validated and standardized HFO event fields
        (expects 'start_idx', 'end_idx', 'chan_idx').
    labels : array-like
        Binary vector (0/1) indicating whether each event is classified as HFO (1)
        or artifact (0) based on model threshold.
    scores : array-like
        Vector of predicted probabilities or confidence scores for each event.
    model : dict
        Dictionary containing classification model parameters (expects 'threshold').
    preprocessed_channel_info : dict
        Dictionary containing channel info (expects 'good_chan_mask').
    output_dir : str
        Folder name for saving output results.
    classified_hfo_events_file : str
        File name for saving output results (e.g. "classified_hfo_events.csv").

    Behavior
    --------
    - Ensures the results directory exists or creates it.
    - Constructs a DataFrame with event indices, classification labels, and scores.
    - Dynamically names the binary classification column based on the threshold.
    - Saves the DataFrame to "{output_dir}/{classified_hfo_events_file}".
    """
    os.makedirs(os.path.join('..', output_dir), exist_ok=True)

    # Get threshold and format for column name
    threshold = model["threshold"]
    thresh_str = f"{threshold:.2f}".replace(".", "_")
    is_HFO_colname = f"is_HFO_thresh_{thresh_str}"

    # Identify bad channels
    bad_chan_mask = ~np.array(preprocessed_channel_info["good_chan_mask"], dtype=bool).squeeze()
    is_bad_chan = bad_chan_mask[np.array(events["chan_idx"], dtype=int)]

    # Set labels and scores as NaN for HFOs on bad channels
    labels[is_bad_chan] = np.nan
    scores[is_bad_chan] = np.nan

    # Set is_bad_chan as NaN if label or score is NaN
    is_nan_mask = np.isnan(labels) | np.isnan(scores)
    is_bad_chan_output = is_bad_chan.astype(float)
    is_bad_chan_output[is_nan_mask] = np.nan

    # Define NaN label or score as NaN event
    is_nan_event = np.isnan(labels) | np.isnan(scores)
    
    # Construct DataFrame
    df = pd.DataFrame({
        "start_idx": np.array(events["start_idx"], dtype=int) + 1, # revert back to 1-based indexing
        "end_idx": np.array(events["end_idx"], dtype=int) + 1, # revert back to 1-based indexing
        "chan_idx": np.array(events["chan_idx"], dtype=int) + 1, # revert back to 1-based indexing
        is_HFO_colname: np.array(labels, dtype=float),
        "prob_HFO": np.array(scores, dtype=float),
        "is_bad_chan": is_bad_chan_output,
        "is_nan_event": is_nan_event.astype(float)
    })

    # Save to CSV
    save_path = os.path.join('..', output_dir, classified_hfo_events_file)
    os.makedirs(os.path.dirname(save_path), exist_ok=True)  # create parent dirs if needed
    df.to_csv(save_path, index=False)
    print(f"Results saved to {save_path}")