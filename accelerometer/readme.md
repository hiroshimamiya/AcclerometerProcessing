#### dataflow

We have the raw data for 151 participants. Then we used accProcess to obtain epoch files. We used the epoch files and the label files to trainClassificationModel. Then the custom classificationModel is given to the accProcess for classifying the raw data. This time we will disable retaining intermediate epoch files. Finally, we use the classified output and label files only for the test data to generate confusion matrix.


Notebooks comparing walmsley and custom model with extra features for 10 seconds and 30 seconds epoch can be found here: notebooks/model_comparison_notebooks