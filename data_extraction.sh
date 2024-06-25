#!/bin/bash

#### Columns and the data they are representing:
# Column(s) : UDI
# 1 : eid
# 27 : 31-0.0 (Sex)
# 28 : 34-0.0 (Birth year)
# 97 : 52-0.0 (Month of birth)
# 941 : 1289-0.0 (Cooked vegetable intake) 
# 949 : 1309-0.0 (Fresh Fruit Intake)
# 957 : 1329-0.0 (Oily fish consumption)
# 1045 : 1558-0.0 (Alcohol consumption (frequency))
# 7008 : 6138-0.0 (Education)
# 10795 : 20116-0.0 (Smoking status)
# 12128 : 21000-0.0 (Education)
# 12132 : 21001-0.0 (BMI) 
# 19789 : 90001-0.0 (Raw Accelerometry Data)
# 8425-8560 : 20002-X.XX; Instances: [0,3]; Arrays: [0,33] (Non-cancer illness code, self-reported) 
# 17621-1722 : 40001-0.XX; Arrays: [0,2] (Underlying (primary) cause of death)
# 17623-17652 : 40002-0.XX; Instances: [0,1]; Arrays: [0,14] (Contributory (secondary) causes of death - ICD10)
### Strokes
# 19757 : 42006-0.0 (Date of stroke)
# 19758 : 42007-0.0 (Source of stroke report)
# 19759 : 42008-0.0 (Date of ischaemic stroke)
# 19760 : 42009-0.0 (Source of ischaemic stroke report)
# 19761 : 42010-0.0 (Date of intracerebral haemorrhage)
# 19762 : 42011-0.0 (Source of intracerebral haemorrhage report)
# 19763 : 42012-0.0 (Date of subarachnoid haemorrhage)
# 19762 : 42013-0.0 (Source of subarachnoid haemorrhage report)
### Myocardial Infarction
# 19751 : 42000-0.0 (Date of myocardial infarction)
# 19752 : 42001-0.0 (Source of myocardial infarction report)
# 19753 : 42002-0.0 (Date of STEMI)
# 19753 : 42003-0.0 (Source of STEMI report)
# 19754 : 42004-0.0 (Date of NSTEMI)
# 19755 : 42005-0.0 (Source of NSTEMI report)

### Other ICD9 and ICD10 codes we won't use for now
# 19114-19160 : 41271-0.XX; Arrays: [0,46] (Diagnoses - ICD9)
# 17991-18018 : 41203-0.XX; Arrays: [0,27] (Diagnoses - main ICD9)
# 18229-18258 : 41205-0.XX; Arrays: [0,29] (Diagnoses - secondary ICD9)
# 17621-1722 : 40001-0.XX; Arrays: [0,2] (Underlying (primary) cause of death)
# 17623-17652 : 40002-0.XX; Instances: [0,1]; Arrays: [0,14] (Contributory (secondary) causes of death - ICD10)
# 18855-19113 : 41270-0.XX; Arrays: [0,258] (Diagnoses - ICD10)
# 17911-1799 : 41202-0.XX; Arrays: [0,79] (Diagnoses - main ICD10)
# 18019-18228 : 41204-0.XXX; Arrays: [0,209] (Diagnoses - secondary ICD10)
####



## 1. Extract the columns we wanted as well as the ones extracted by OxWearables

# Note: We need "csvkit"

# Extract the columns from the "current.csv" file - only the first 1000 rows:

cat /lustre03/project/6008063/neurohub/UKB/Tabular/current.csv | head -1000 | csvcut -c 1,27,28,97,941,949,957,1045,7008,10795,12128,12132,19789,8425-8560,19114-19160,17991-18018,\
18229-18258,17621,17622,17623-17652,19757-19762,19751-19755\
> /home/yalap95/current_df/current_subset.csv

#*** Does not include Townsend index ***#

# Extract the Townsend index column seperately because it is not in the "current.csv" file - first 1000 rows:
cat /lustre03/project/6008063/neurohub/UKB/Tabular/RAP/ukb_field_22189.csv| head -1000 > /home/yalap95/current_df/townsend.csv
#*** I then merged current_subset.csv and townsend.csv using python: "pd.merge(current_df, ukb_field_22189_df, on='eid')"


# 3. Extract only the columns that contains strokes and MI information
cat /lustre03/project/6008063/neurohub/UKB/Tabular/current.csv | head -1000 | csvcut -c 1,19757-19762,19751-19755 > /home/yalap95/current_df/strokes_mi.csv


## 2. Extract only the columns used by OxWearables

cat /lustre03/project/6008063/neurohub/UKB/Tabular/current.csv | head -1000 | csvcut -c 1,27,28,97,1045,7008,10795,12128,12132,103,786,479,7244,7245,7246,98,99,100,19802,19968,\
19970,19972,19801,19799,19798 > /home/yalap95/current_df/current_subset_2.csv

#*** Again: We need to merge with the Townsend index ***#
