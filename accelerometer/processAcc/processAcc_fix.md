###### accelerometer package issue

Problem: when training the model using trainClassificationModel, test-predictions.csv was not being created.
Error:Traceback (most recent call last):
  File "/accelerometer/process_acc.py", line 4, in <module>
    trainClassificationModel(
  File "/people_mobility_origin_dest/.oridest_venv/lib/python3.10/site-packages/accelerometer/classification.py", line 226, in trainClassificationModel
    Ypred = model.predict(Xtest)
  File "/people_mobility_origin_dest/.oridest_venv/lib/python3.10/site-packages/sklearn/ensemble/_forest.py", line 808, in predict
    proba = self.predict_proba(X)
  File "/people_mobility_origin_dest/.oridest_venv/lib/python3.10/site-packages/sklearn/ensemble/_forest.py", line 850, in predict_proba
    X = self._validate_X_predict(X)
  File "/people_mobility_origin_dest/.oridest_venv/lib/python3.10/site-packages/sklearn/ensemble/_forest.py", line 579, in _validate_X_predict
    X = self._validate_data(X, dtype=DTYPE, accept_sparse="csr", reset=False)
  File "/people_mobility_origin_dest/.oridest_venv/lib/python3.10/site-packages/sklearn/base.py", line 566, in _validate_data
    X = check_array(X, **check_params)
  File "/people_mobility_origin_dest/.oridest_venv/lib/python3.10/site-packages/sklearn/utils/validation.py", line 805, in check_array
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

##### Changes:
within classification.py --> def trainClassificationModel method
 
line 157 -->     if testParticipants is not None:
 
test = data[data[participantCol].isin(testPIDs)].copy()
 
check if the data type of the testPIDs is the same as the data type of the entries in the participantCol of the dataframe.
 
float matches float.
 
We were skipping out on entries in our test data frame leading to empty Xtest while testing and calling predict function later on in the trainClassificationModel method

