### acc process command
this is the file: /accel/capture24/participants/P001.csv
command:

--mgCpLPA 45 --mgCpMPA 100 --mgCpVPA 400 --activityClassification True --outputFolder results --verbose True --deleteIntermediateFiles False --csvTimeFormat "yyyy-MM-dd HH:mm:ss.SSSSSS '['VV']'"


  --mgCpLPA 45          LPA threshold for cut point based activity definition
                        (default : 45)
  --mgCpMPA 100          MPA threshold for cut point based activity definition
                        (default : 100)
  --mgCpVPA 400          VPA threshold for cut point based activity definition
                        (default : 400)
  --activityClassification True
                        Use pre-trained random forest to predict activity type
                        (default : True)

  # --activityModel ACTIVITYMODEL
                        trained activity model .tar file
  --outputFolder results
                        folder for all of the output files (default : None)
  --verbose True  enable verbose logging? (default : False)
  --deleteIntermediateFiles False
                        True will remove extra "helper" files created by the
                        program (default : True)                        

accProcess /accelerometer/accprocess/P001_m.csv --mgCpLPA 45 --mgCpMPA 100 --mgCpVPA 400 --activityClassification True --outputFolder results --verbose True --deleteIntermediateFiles False


### this worked!!
accProcess /accel/capture24/participants/P001.csv --csvTimeFormat 'yyyy-MM-dd HH:mm:ss.SSSSSS' --csvTimeXYZTempColsIndex 0,1,2,3 --outputFolder /accelerometer/accprocess/results


### parallel processAcc jobs
I have processed the data files for all participants for making confusion matrix. That day it took 82 seconds for one participant which means sequentially it should have taken about ~3.5 hours. Using GNU parallel, I was able to get it done by 17.5 minutes for all in total because I was thinking about how we will do it for 100,000 participants. I am currently thinking of some more ways to get this number down even further anticipating 100,000 participants. I will do it again now to check a different approach. I will make the confusion matrix part tomorrow.

##### get the list of all jobs
TOTAL_JOBS=$(wc -l < /accelerometer/accprocess/all_files.txt)
export TOTAL_JOBS

##### use GNU parallel
cat /accelerometer/accprocess/all_files.txt | parallel "accProcess {} --csvTimeFormat 'yyyy-MM-dd HH:mm:ss.SSSSSS' --csvTimeXYZTempColsIndex 0,1,2,3 --outputFolder /accelerometer/accprocess/results > /accelerometer/accprocess/logs/{/}.log; echo Job {#} of $TOTAL_JOBS" > output_log.txt 2> error_log.txt

**It is doing in batches of 48.**
Max number of threads = 48
    Thread(s) per core:  2
    Core(s) per socket:  12
    Socket(s):           2

##### piping the errors and outputs to different files
TOTAL_JOBS=$(wc -l < /accelerometer/accProcess2-test/all_files.txt)
export TOTAL_JOBS
cat /accelerometer/accProcess2-test/all_files.txt | parallel -j 40 "accProcess {} --csvTimeFormat 'yyyy-MM-dd HH:mm:ss.SSSSSS' --csvTimeXYZTempColsIndex 0,1,2,3 --outputFolder /accelerometer/accProcess2-test/results > /accelerometer/accProcess2-test/logs/{/}.log; echo Job {#} of $TOTAL_JOBS" > output_log.txt 2> error_log.txt

##### counting the time taken along with piping the output and errors to different files
time cat /accelerometer/accProcess2-test/all_files.txt | parallel -j 38 "accProcess {} --csvTimeFor
mat 'yyyy-MM-dd HH:mm:ss.SSSSSS' --csvTimeXYZTempColsIndex 0,1,2,3 --outputFolder /accelerometer/accProcess2-test/results > /accelerometer/accProcess2-test/logs/{/}.log; echo Job {#} of $TOTAL_JOBS" > output_log.txt 2> error_log.txt

    real    11m49.972s
    user    388m29.309s
    sys     41m13.279s



TOTAL_JOBS=$(wc -l < /home/aayush/accelerometer/accprocess/all_files.txt)
export TOTAL_JOBS
time cat /home/aayush/accelerometer/accprocess/all_files.txt | parallel -j 10 "accProcess {} --extractFeatures True --csvTimeFormat 'yyyy-MM-dd HH:mm:ss.SSSSSS' --csvTimeXYZTempColsIndex 0,1,2,3 --epochPeriod 30 --outputFolder /home/aayush/accelerometer/compare_classification/accProcess_output/30_sec/original_features/predicted_output --deleteIntermediateFiles True --activityModel /home/aayush/accelerometer/compare_classification/accProcess_output/30_sec/original_features/model_used/30s_without_extra_model.tar; echo Job {#} of $TOTAL_JOBS" > output_log.txt 2> error_log.txt



time cat /home/aayush/accelerometer/accprocess/all_files.txt | parallel -j 10 "accProcess {} --extractFeatures True --csvTimeFormat 'yyyy-MM-dd HH:mm:ss.SSSSSS' --csvTimeXYZTempColsIndex 0,1,2,3 --epochPeriod 30 --outputFolder /home/aayush/accelerometer/compare_classification/accProcess_output/30_sec/extra_features/predicted_output --deleteIntermediateFiles True --activityModel /home/aayush/accelerometer/compare_classification/accProcess_output/30_sec/extra_features/model_used/30s_extra_model.tar; echo Job {#} of $TOTAL_JOBS" > output_log.txt 2> error_log.txt