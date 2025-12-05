import os
import scipy.io as sio
import numpy as np
from utils.load_and_validate_eeg import validate_and_convert_int_fields


def load_and_validate_events(events_file):
    """
    Load and validate HFO event metadata from a .mat file.

    Args:
        events_file (str): Path to .mat file containing HFO events. The file
                           must contain fields:
                             - start_idx : event start indices
                             - end_idx   : event end indices
                             - chan_idx  : channel indices

    Returns:
        dict: Validated events with integer fields and 0-based indexing
    """

    if not os.path.isfile(events_file):
        raise FileNotFoundError(f"Events file not found: {events_file}")

    mat_contents = sio.loadmat(events_file)
    events = {k: v for k, v in mat_contents.items() if not k.startswith("__")}

    # Verify required fields
    required_fields = ['start_idx', 'end_idx', 'chan_idx']
    for f in required_fields:
        if f not in events:
            raise ValueError(f"Events missing field: {f}")

    # Convert to integer arrays
    events = validate_and_convert_int_fields(events, required_fields)

    # Adjust for 0-based indexing (MATLAB → Python)
    events['start_idx'] = events['start_idx'] - 1
    events['end_idx'] = events['end_idx'] - 1
    events['chan_idx'] = events['chan_idx'] - 1

    return events