# demo.py - Demonstration of HFO classification step
#
# This script demonstrates the HFO classification step of the pipeline.
# It classifies HFO events using a pretrained model.
#
# Output:
#   - Classification results saved as 'example_classified_hfo_events.csv' in 'outputs/' folder
#
# Written by Shi-Bei (Ashley) Tan (tashibei@umich.edu) in 2025
# Copyright © 2025
# Licensed under CC BY-NC 4.0

from classify_events import classify_events


def main():
    # Step 3: HFO Classification
    classify_events(
        input_data_dir="input_data",
        detected_hfo_events_file="example_detected_hfo_events.mat",
        sampling_rate_file="example_sampling_rate.mat",
        model_dir="model",
        model_file="model.json",
        output_dir="outputs",
        preprocessed_eeg_file="example_preprocessed_eeg.mat",
        preprocessed_channel_info_file="example_preprocessed_channel_info.mat",
        classified_hfo_events_file="example_classified_hfo_events.csv",
        hfo_event_features_file="example_hfo_event_features.mat"
    )

    print("HFO classification pipeline completed successfully.\n")

if __name__ == "__main__":
    main()