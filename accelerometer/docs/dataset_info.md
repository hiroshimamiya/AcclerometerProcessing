### Capture24
It contains 151 annotated participants' data across 1 day time period.
Activities are labelled.
Records are made per hundredth of a second.

### UKBB
It contains raw data in cwa format for 100,000 participants collected across 7 days.

### Dataprocessing
accelerometer library needs minimum of 4 columns; time, x, y ,z
These features are used to extract more features upto 67 to obtain epoch files.
Those epoch files along with the labelled dataset can be used to trainClassificationModel.
Later, the trained model can be used for classifying the activities from raw data and directly timeseries classification can be obtained without keeping intermediate epoch files.

This is done using accprocess. Make sure to set the right epoch length if not using 30 seconds.
Set deleteIntermediateFiles to generate epoch files.

Make sure to keep the training data and the testset separate, meaning if P001 to P100 are used for training the model then P101 to P151 should be used for testing.

### Classification
1. walmsley classification: model trained based on features extracted from x,y,z coordinates. Per direction percentiles not used. Vector magnitude percentiles were used.
2. Balanced random forest with per direction features for percentiles: It is the convention to have per direction percentiles in accelerometer classification however we found that using per direction features did not lead to any significant difference.
3. Cut-point based classification: Activities are classified based on the threshold set for each category of activity. (cpSB - sedantary, cpLPA - light, cpMVPA - moderate vigorous)