import os
import json
import numpy as np

def load_and_validate_model(model_filepath):
    """
    Load and verify an HFO classification model from a JSON file.

    Args:
        model_filepath (str): Path to JSON file containing model parameters.

    Returns:
        dict: Validated model with fields:
              - 'coefficients': list
              - 'intercept': list with one scalar
              - 'threshold': list with one scalar between 0 and 1
              - 'mean': list
              - 'std': list
    """

    if not os.path.isfile(model_filepath):
        raise FileNotFoundError(f"Model file not found: {model_filepath}")

    with open(model_filepath, 'r') as f:
        model = json.load(f)

    if not model:
        raise ValueError("Model file is empty.")

    # Validate required fields
    required_fields = ['coefficients', 'intercept', 'threshold', 'mean', 'std']
    for f in required_fields:
        if f not in model:
            raise ValueError(f"Model missing field: {f}")

    # Validate scalar fields
    intercept = model['intercept'][0]
    threshold = model['threshold'][0]
    if not np.isscalar(intercept):
        raise ValueError("Model intercept must be a scalar.")
    if not np.isscalar(threshold) or not (0 <= threshold <= 1):
        raise ValueError("Model threshold must be a scalar between 0 and 1.")

    # Validate vector fields
    coef = np.array(model['coefficients'], dtype=float).flatten()
    mu   = np.array(model['mean'], dtype=float).flatten()
    sig  = np.array(model['std'], dtype=float).flatten()

    if not (len(coef) == len(mu) == len(sig)):
        raise ValueError("Model vectors (coefficients, mean, std) must be the same length.")

    # Replace original fields with numpy arrays
    model['coefficients'] = coef
    model['mean'] = mu
    model['std'] = sig
    model['intercept'] = intercept
    model['threshold'] = threshold

    return model