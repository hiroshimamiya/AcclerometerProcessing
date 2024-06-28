## v1.0.0 (2024-06)

[FIX] classification.py:

Fixed an issue where the test split might be left empty due to mismatched data types between participant IDs and the dataframe. The trainClassificationModel function now converts participant IDs to float to match the dataframe's data type.

[FIX/ENH] classification.py:

Improved handling of unknown models in the removeSpuriousSleep method.
Default value for removeSpuriousSleep is now set to "sedantary" for all unknown models.
The model name is logged within the removeSpuriousSleep method for better tracking and debugging.

[ENH] features.java:

Enhanced feature extraction by calculating additional metrics (median, min, max, 25th percentile, and 75th percentile) for each direction (e.g., x, y, z).
The epoch file header has been updated to reflect the newly extracted metrics.
