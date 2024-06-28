adding more details for my own notes:

Confusion matrix for HMM --> generate model using trainClassification and use it for classifying outputs of accProcess by giving custom model as input.

Strange grey area in accPlot --> load in notebook and analyse data frame



Our findings for dropping rows in dataframes while calculating confusion matrix:

we drop NA items in predicted df
we drop duplicate time stamps in predicted df
we drop timestamps from predicted df which do not exist in actual_labels df
we drop NA items in actual_labels df
we drop timestamps from actual_labels df which do not exist in predicted df

So far, we found that (Number of dropped items from predicted df due to timestamp mismatch with actual_label df) was equal to sum of (Number of dropped items from actual_label df due to NA values) and (Number of dropped items from actual_label df due to timestamp mismatch with predicted df).



With the main drop coming from Number of dropped items from actual_label df due to NA values.

For this, we made the graph of MET values because if no MET value present then no annotation present.



We correlated this graph (as a representation of available actual_label values) with the output of accPlot (as a representation of output of accPlot). We found that there are indeed points in time where there are missing values from actual_label and we cannot do anything about it.



But then we found some values in accPlot which were leading to grey areas in the plot and yet we had records for them. We could not explain it and that is why we are looking explanation as mentioned above.


for the train process - get the processed epochs from /home/yacine/accel/epoch
then combine them for all participants then sort them based on timestamp.

Add these columns - participant,MET,label,annotation, remove time column.

then use it to train the HMM file.

