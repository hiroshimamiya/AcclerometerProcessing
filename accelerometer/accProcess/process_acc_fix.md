##### accelerometer package issue

Problem: when training the model using trainClassificationModel, test-predictions.csv was not being created.
Error:Traceback (most recent call last):
  File "/home/aayush/accelerometer/process_acc.py", line 4, in <module>
    trainClassificationModel(
  File "/home/aayush/people_mobility_origin_dest/.oridest_venv/lib/python3.10/site-packages/accelerometer/classification.py", line 226, in trainClassificationModel
    Ypred = model.predict(Xtest)
  File "/home/aayush/people_mobility_origin_dest/.oridest_venv/lib/python3.10/site-packages/sklearn/ensemble/_forest.py", line 808, in predict
    proba = self.predict_proba(X)
  File "/home/aayush/people_mobility_origin_dest/.oridest_venv/lib/python3.10/site-packages/sklearn/ensemble/_forest.py", line 850, in predict_proba
    X = self._validate_X_predict(X)
  File "/home/aayush/people_mobility_origin_dest/.oridest_venv/lib/python3.10/site-packages/sklearn/ensemble/_forest.py", line 579, in _validate_X_predict
    X = self._validate_data(X, dtype=DTYPE, accept_sparse="csr", reset=False)
  File "/home/aayush/people_mobility_origin_dest/.oridest_venv/lib/python3.10/site-packages/sklearn/base.py", line 566, in _validate_data
    X = check_array(X, **check_params)
  File "/home/aayush/people_mobility_origin_dest/.oridest_venv/lib/python3.10/site-packages/sklearn/utils/validation.py", line 805, in check_array
    raise ValueError(
ValueError: Found array with 0 sample(s) (shape=(0, 70)) while a minimum of 1 is required.

Solution: The test dataframe was not having any sample. This was because the filtering being done in def trainClassificationModel() method in classification.py on line 157 was missing the testPIDs because it was comparing floats to string.

Changed the comparison with floats and it populated the testPIDs which made the rest of the pipeline work. So, the code was no longer escaping at testing phase due to empty test dataframe.

    if testParticipants is not None:
        testPIDs = testParticipants.split(',')
        PIDs_float = []
        for i in testPIDs:
            PIDs_float.append(float(i))
        test = data[data[participantCol].isin(PIDs_float)].copy()
        train = data[~data[participantCol].isin(PIDs_float)].copy()
        print(testPIDs)
        print(PIDs_float)
        print(data[participantCol].isin(PIDs_float))
        print(data[participantCol])
        print(test)

We were getting this error, "ValueError: Found array with 0 sample(s) (shape=(0, 70)) while a minimum of 1 is required." from sklearn/utils/validation.py because the test dataframe was not having any sample.
 
Specifically, in the trainClassificationModel() function (within the “classification.py” script), the comparison for "testPIDs" was only reading floats, while our participant IDs were recorded as strings. This caused the function to compare floats to strings, preventing the pipeline from functioning correctly and resulting in an empty Xtest matrix. Consequently, we were unable to obtain prediction results.
 
Therefore, he compared the participant IDs from the input as float datatype for the isin function.
 
Example:
>>> testpids = "37.0, 54.0"
>>> test_pids = testpids.split(",")
>>> test_pids
['37.0', ' 54.0']
>>> pd_data
   participantCol
0            37.0
1            54.0
>>> pd_data.dtypes
participantCol    float64
dtype: object
>>> test = pd_data[pd_data["participantCol"].isin(test_pids)]
>>> test
Empty DataFrame
Columns: [participantCol]
Index: []
>>> test_floats = [float(i) for i in test_pids]
>>> test = pd_data[pd_data["participantCol"].isin(test_floats)]
>>> test
   participantCol
0            37.0
1            54.0


##### Changes:
within classification.py --> def trainClassificationModel method
 
line 157 -->     if testParticipants is not None:
 
test = data[data[participantCol].isin(testPIDs)].copy()
 
check if the data type of the testPIDs is the same as the data type of the entries in the participantCol of the dataframe.
 
float matches float.
 
We were skipping out on entries in our test data frame leading to empty Xtest while testing and calling predict function later on in the trainClassificationModel method

