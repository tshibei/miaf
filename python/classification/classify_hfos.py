# classify_hfos.py — HFO classification utilities
#
# Implements logistic-regression-based classification for detected HFO events.
#
# Author: Shi-Bei (Ashley) Tan (tashibei@umich.edu)
# Copyright (c) 2025 Shi-Bei Tan
# License: CC BY-NC 4.0

import numpy as np
from scipy.special import expit

def classify_hfos(X, model):
    """Classify HFO events using a logistic-regression model.

    This helper applies the same normalization and decision rule that were
    used during model training:

    1. Normalize each feature using the model's stored mean and standard
       deviation.
    2. Apply a linear model (weights + intercept).
    3. Pass the result through a sigmoid to obtain per-event probabilities.
    4. Threshold the probabilities to obtain binary labels.

    Parameters
    ----------
    X : array-like of shape (n_events, n_features)
        Per-event feature matrix. Features must be ordered and scaled in
        the same way as during training.
    model : dict-like
        Trained model parameters with at least the following keys:

        - ``'coefficients'``: array-like of shape (1, n_features) or
          (n_classes, n_features)
        - ``'intercept'``: scalar or array-like broadcastable to ``z``
        - ``'threshold'``: scalar decision threshold in probability space
        - ``'mean'``: array-like of shape (n_features,) used to normalize ``X``
        - ``'std'``: array-like of shape (n_features,) used to normalize ``X``

    Returns
    -------
    labels : ndarray
        Binary predictions for each event, squeezed to remove singleton
        dimensions. Values are ``0.0`` or ``1.0``; any entries corresponding
        to ``NaN`` scores remain ``NaN``.
    scores : ndarray
        Sigmoid probabilities for each event, squeezed to remove singleton
        dimensions.
    """

    # Extract model data
    coef = model['coefficients']
    intercept = model['intercept']
    threshold = model['threshold']
    mean = model['mean']
    std = model['std']

    # Normalize input
    X_norm = (X - mean) / std

    # Linear model
    z = np.dot(X_norm, coef.T) + intercept

    # Sigmoid function
    scores = expit(z)

    # Prediction
    labels = np.full(scores.shape, np.nan)  # Initialize labels with NaN
    labels[~np.isnan(scores)] = scores[~np.isnan(scores)] > threshold  # Set labels based on threshold for non-NaN scores
    labels = labels.astype(float)  # Convert logical array to ones and zeros

    return labels.squeeze(), scores.squeeze()