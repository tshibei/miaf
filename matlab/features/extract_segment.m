function segment = extract_segment( data, start_idx, end_idx, ch )
    segment = data(start_idx : end_idx, ch);
end