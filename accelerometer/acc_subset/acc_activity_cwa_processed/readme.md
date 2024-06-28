Use accprocess to convert the cwa files to timeseries files with activity classification.
You can supply a custom model for classifying data and pick an epoch size as well.

### Use accprocess to convert cwa files to processed timeseries with activity classification:
TOTAL_JOBS=$(wc -l < /home/aayush/accelerometer/accprocess/all_files.txt)
export TOTAL_JOBS
time cat /home/aayush/accelerometer/accprocess/all_files.txt | parallel -j 10 "accProcess {} --extractFeatures True --csvTimeFormat 'yyyy-MM-dd HH:mm:ss.SSSSSS' --csvTimeXYZTempColsIndex 0,1,2,3 --epochPeriod 30 --outputFolder /home/aayush/accelerometer/compare_classification/accProcess_output/30_sec/original_features/predicted_output --deleteIntermediateFiles True --activityModel /home/aayush/accelerometer/compare_classification/accProcess_output/30_sec/original_features/model_used/30s_without_extra_model.tar; echo Job {#} of $TOTAL_JOBS" > output_log.txt 2> error_log.txt


Change the configs in the command based on what is needed.

### csv output process
You can use the predicted output timeseries csv as input for jupyter notebooks and compare the output with proportions.

The data has been processed and graph plotted in this notebook: [accProcess_compare_weekly](../../notebooks/accProcess_compare_weekly.ipynb)