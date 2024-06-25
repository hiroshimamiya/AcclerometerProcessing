
# libraries
import os
import pandas as pd

os.chdir('/home/yalap95/current_df')
print(os.getcwd())


current_df = pd.read_csv('current_subset_df.csv')
twi = pd.read_csv('townsend.csv')
#c_ox = pd.read_csv('current_df_ox.csv')
strokes_mi = pd.read_csv('strokes_mi.csv')

current_subset_2 = pd.merge(current_df, twi, on='eid')

current_subset_2.to_csv('/home/yalap95/current_df/current_subset_2.csv', index=False)

final_df = pd.merge(current_subset_2, strokes_mi, on='eid')
final_df.to_csv('/home/yalap95/current_df/final_df.csv', index=False)


#current_subset_ox_2 = pd.merge(c_ox, twi, on='eid')



# rename columns as suggested by OxWearables

# set path
os.chdir('/home/yalap95/current_df')
print(os.getcwd())

# fetch current.csv
current_df = pd.read_csv('final_df.csv')


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
    "90011-0.0" : "date_end_accel",
    "1309-0.0" : "fresh_fruit",
    "1289-0.0" : "cooked_vg",
    "1329-0.0" : "oily_fish",
    "42006-0.0" : "stroke_date",
    "42007-0.0" : "stroke_source",
    "42008-0.0" : "ischaemic_stroke_date",
    "42009-0.0" : "ischaemic_stroke_source",
    "42010-0.0" : "intracerebral_haemorrhage_date",
    "42011-0.0" : "intracerebral_haemorrhage_source",
    "42012-0.0" : "subarachnoid_haemorrhage_date",
    "42013-0.0" : "subarachnoid_haemorrhage_source",
    "42000-0.0" : "myocardial_infarction_date",
    "42001-0.0" : "myocardial_infarction_source",
    "42002-0.0" : "STEMI_date",
    "42003-0.0" : "STEMI_source",
    "42004-0.0" : "NSTEMI_date",
    "42005-0.0" : "NSTEMI_source"
    }

final_df.rename(columns=field_list_aliases, inplace=True)

print(final_df.head(10))

final_df.to_csv('/home/yalap95/current_df/final_df.csv')
print(final_df.info())
