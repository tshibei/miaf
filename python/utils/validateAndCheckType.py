import os
import numpy as np
from scipy.io import loadmat

def validate_and_check_type(file, field, type_check):
    """
    Load a variable from a .mat file and validate its type.
    
    Parameters
    ----------
    file : str
        Path to a .mat file.
    field : str
        Name of the variable to extract from the file.
    type_check : str
        Expected type of the variable. Supported values:
        'numeric' : checks that the variable is numeric.
        'float'   : checks that the variable is floating-point.
    
    Returns
    -------
    variable : array-like
        The extracted variable if all validations pass.
    
    Raises
    ------
    FileNotFoundError
        If the file does not exist.
    KeyError
        If the specified field is not found in the MAT-file.
    TypeError
        If the variable does not match the requested type.
    """
    # Check if file exists
    if not os.path.isfile(file):
        raise FileNotFoundError(f'File not found: {file}')
    
    # Load the .mat file
    variable = loadmat(file)
    
    # Check if field exists
    if field not in variable:
        raise KeyError(f'Field {field} does not exist in the loaded variable.')
    
    variable = variable[field]
    
    # Check type of variable
    if type_check == 'numeric':
        if not np.issubdtype(variable.dtype, np.number):
            raise TypeError(f'Variable is not numeric: {field}')
    elif type_check == 'float':
        if not np.issubdtype(variable.dtype, np.floating):
            raise TypeError(f'Variable is not a float: {field}')
    
    return variable