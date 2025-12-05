import os
import scipy.io as sio
import numpy as np
import h5py

def validate_and_convert_int_fields(file, fields):
    """
    Convert specified fields in the dict to integer arrays.
    """

    if not os.path.isfile(file):
        raise FileNotFoundError(f"File not found: {file}")

    struct = sio.loadmat(file)
    struct = {k: v for k, v in struct.items() if not k.startswith("__")}

    # Verify required fields
    for f in fields:
        if f not in struct:
            raise ValueError(f"Events missing field: {f}")
        
    for field in fields:
        if field in struct:
            struct[field] = np.array(struct[field], dtype=int).flatten()
    return struct


def load_and_validate_eeg(eeg_file):
    """
    Loads a .mat file and verifies that the EEG struct contains:
        - 'data'           : [time x channels] matrix
        - 'fs'             : sampling frequency (Hz)
        - 'ecog_chan_idx'  : indices of ECoG channels
        - 'depth_chan_idx' : indices of SEEG channels

    Converts ecog/depth channel indices to integers.

    Args:
        eeg_file (str): Path to .mat file containing EEG struct

    Returns:
        dict: Validated EEG struct
    """

    if not os.path.isfile(eeg_file):
        raise FileNotFoundError(f"EEG file not found: {eeg_file}")

    eeg_struct = load_mat73_recursive(eeg_file)

    required_fields = ['data', 'fs', 'ecog_chan_idx', 'depth_chan_idx']
    for f in required_fields:
        if f not in eeg_struct:
            raise ValueError(f"EEG missing field: {f}")

    # Transpose data to [time x channels]
    if eeg_struct['data'].shape[1] > eeg_struct['data'].shape[0]:
        eeg_struct['data'] = eeg_struct['data'].T 

    assert eeg_struct['data'].shape[0] > eeg_struct['data'].shape[1], \
        "EEG data should have more time points (rows) than channels (columns)"
    
    eeg_struct = validate_and_convert_int_fields(eeg_struct, ['ecog_chan_idx', 'depth_chan_idx'])

    # Convert to 0-based indexing (MATLAB → Python)
    if eeg_struct['ecog_chan_idx'].size > 0:
        eeg_struct['ecog_chan_idx'] -= 1
    if eeg_struct['depth_chan_idx'].size > 0:
        eeg_struct['depth_chan_idx'] -= 1

    return eeg_struct

def _read_mat_obj(obj):
    """
    Recursively read a dataset or group from h5py,
    fixing empty arrays saved as [0, 0].
    """
    if isinstance(obj, h5py.Dataset):
        arr = np.array(obj)

        # Check MATLAB_shape attribute
        matlab_shape = obj.attrs.get("MATLAB_shape")
        if matlab_shape is not None:
            arr = arr.reshape(matlab_shape)

        # Catch placeholder [0,0] for empty arrays
        if arr.size == 2 and np.all(arr == 0):
            arr = np.empty((0, 0))

        return arr

    elif isinstance(obj, h5py.Group):
        out = {}
        for k in obj.keys():
            out[k] = _read_mat_obj(obj[k])
        return out

    else:
        return obj  # fallback

def load_mat73_recursive(filename):
    """
    Load a MATLAB v7.3 .mat file into a nested Python dict,
    recursively fixing empty arrays.
    """
    data_dict = {}
    with h5py.File(filename, "r") as f:
        for key in f.keys():
            if not key.startswith("__"):
                data_dict[key] = _read_mat_obj(f[key])
    return data_dict