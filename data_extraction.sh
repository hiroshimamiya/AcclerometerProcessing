
## 1. Extract the columns we want

# Note: We need "csvkit"

# Extract the columns from the "current.csv" file - only the first 1000 rows:

cat /lustre03/project/6008063/neurohub/UKB/Tabular/current.csv | head -1000 | csvcut -c 1,27,28,97,941,949,957,1045,7008,10795,12128,12132,19789,8425-8560,19114-19160,17991-18018,\
18229-18258,17621,17622,17623-17652,18855-19113,17911-1799,18019-18228\
> /home/yalap95/current_df/current_subset.csv

#*** Does not include Townsend index ***#


# Extract the Townsend index column seperately because it is not in the "current.csv" file - first 1000 rows:

cat /lustre03/project/6008063/neurohub/UKB/Tabular/RAP/ukb_field_22189.csv| head -1000 > /home/yalap95/current_df/townsend.csv

#*** I then merged current_subset.csv and townsend.csv using python: "pd.merge(current_df, ukb_field_22189_df, on='eid')"



## 2. Extract only the columns used  replica of OxWearables

cat /lustre03/project/6008063/neurohub/UKB/Tabular/current.csv | head -1000 | csvcut -c 1,27,28,97,1045,7008,10795,12128,12132,103,786,479,7244,7245,7246,98,99,100,19802,19968,\
19970,19972,19801,19799,19798 > /home/yalap95/current_df/current_subset_2.csv

#*** Again: We need to merge with the Townsend index ***#
