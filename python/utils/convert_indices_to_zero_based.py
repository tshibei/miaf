def convert_indices_to_zero_based(dict, keys):
    """
    Convert specified fields in the dict to 0-based indexing.

    Args:
        dict (dict): Dictionary containing fields to convert
        keys (list): List of keys in the dict whose values should be converted

    Returns:
        dict: Updated dictionary with specified fields converted to 0-based indexing
    """
    for key in keys:
        if key in dict:
            dict[key] = dict[key] - 1
    return dict