import os
import numpy as np
from scipy.io import loadmat

def validate_and_convert_int_fields(file, fields):
    """
    Load a MATLAB .mat file, validate that specified fields contain integer values,
    and convert those fields to numpy.int32.

    The function expects the input file to contain a MATLAB struct accessible
    via the loaded object. It will extract that struct into a Python dict of
    fields and then validate/convert each requested field.

    Parameters
    ----------
    file : str
        Path to a .mat file to load with scipy.io.loadmat.
    fields : list of str
        Names of fields within the loaded struct to validate and convert.

    Returns
    -------
    dict
        Dictionary of fields from the loaded struct, with the specified fields
        converted to numpy.int32.

    Raises
    ------
    AssertionError
        If the provided path is not a file or the loaded object does not expose
        a MATLAB struct via __dict__.
    KeyError
        If any requested field is missing from the struct.
    TypeError
        If a requested field is not numeric.
    ValueError
        If a requested field contains non-integer numeric values.

    Example
    -------
    s = validate_and_convert_int_fields('subject.mat', ['ecog_chan_idx', 'depth_chan_idx'])
    events = validate_and_convert_int_fields('events.mat', ['start_idx', 'end_idx', 'chan_idx'])
    """
    assert os.path.isfile(file), f"Input must be a valid file path: {file}"

    # Load the .mat file. We use squeeze_me and struct_as_record to get simpler arrays/objects.
    struct = loadmat(file, squeeze_me=True, struct_as_record=False)

    for f in fields:
        if f not in struct:
            raise KeyError(f'Field "{f}" not found in input dictionary.')

        # Ensure we operate on a numpy array for dtype checks and casting.
        arr = np.array(struct[f])
        # Require numeric dtype (int/float)
        if not np.issubdtype(arr.dtype, np.number):
            raise TypeError(f'Field "{f}" must be numeric.')
        # Ensure all values are integers (no fractional part)
        if not np.all(np.equal(np.mod(arr, 1), 0)):
            raise ValueError(f'Field "{f}" contains non-integer values.')

        # Convert to 32-bit integers for consistency.
        struct[f] = arr.astype(np.int32)

    return struct