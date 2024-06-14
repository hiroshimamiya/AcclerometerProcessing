# libraries
import os
import pandas as pd

# set path
os.chdir('/home/yalap95/current_df')
print(os.getcwd())

# fetch current.csv
current_df = pd.read_csv('current_subset_2.csv')


# rename columns

field_list_aliases = {
    "eid" : "eid",
    "31-0.0" :  "sex",
    "52-0.0" : "month_birth",
    "34-0.0" : "year_birth",
    "54-1.0" : "ukb_assess_cent",
    "21000-0.0" : "ethnicity_raw",
    "22189-0.0" : "tdi_raw",
    "6138-0.0" : "qualif_raw",
    "845-0.0" : "age_education_raw",
    "20116-0.0" : "smoking_raw",
    "1558-0.0" : "alcohol_raw",
    "21001-0.0" : "BMI_raw",
    "191-0.0" : "date_lost_followup",
    "6150-0.0" : "self_report_cvd_baseline",
    "6150-0.1" : "self_report_cvd_inst_1",
    "6150-0.2" : "self_report_cvd_inst_2",
    "53-0.0" : "date_baseline",
    "53-1.0" : "date_inst_1",
    "53-2.0" : "date_inst_2",
    "90016-0.0" : "quality_good_calibration",
    "90183-0.0" : "clips_before_cal",
    "90185-0.0" : "clips_after_cal",
    "90187-0.0" : "total_reads",
    "90015-0.0" : "quality_good_wear_time",
    "90012-0.0" : "overall_activity",
    "90011-0.0" : "date_end_accel"
    }

current_df.rename(columns=field_list_aliases, inplace=True)

print(current_df.head(10))

current_df.to_csv('/home/yalap95/current_df/current_df_ox.csv')
print(current_df.info())
