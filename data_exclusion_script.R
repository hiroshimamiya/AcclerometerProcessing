
# Load/Install packages
#library(dplyr)
#library(readr)

# Import all data for participants with accelerometer data
#dat <- read.csv("/home/yalap95/current_df/final_df/final_df.csv") # head -1000 sample data
dat <- read.csv("/home/yalap95/current_df/final_df/final_df_full.csv")


# Exclusions: these following commands will only keep the data we are not seeking to exclude
## 1. Low quality accelerometer data
### 1.1. Devices poorly calibrated
dat <- dat[dat$quality_good_calibration == "Yes", ]

### 1.2 Participants for whom \>1% of values were clipped (fell outside the 
###    sensor's range) before or after calibration:
dat <- dat[(dat$clips_before_cal < 0.01*dat$total_reads) & (dat$clips_after_cal < 0.01*dat$total_reads) , ]

### 1.3 Insufficient wear time
dat <- dat[dat$quality_good_wear_time == "Yes", ] # OxWearable note: Note that this has already been calculated in UKB, 
# we don't need to manually calculate it: https://biobank.ndph.ox.ac.uk/showcase/field.cgi?id=90015

### 1.4 Unrealistically high acceleration values
dat <- dat[dat$overall_activity < 100, ]


## 2. Cardiovascular disease diagnosis in HES prior to accelerometer wear (2013)

### 2.1 Participants that reported having a stroke < 2013
#### 2.1.1 stroke < 2013-01-01
keep_rows <- !is.na(dat$stroke_date) & dat$stroke_date >= as.Date("2013-01-01") | is.na(dat$stroke_date)
dat <- dat[keep_rows, ]

#### 2.1.2 ischaemic stroke < 2013-01-01 
keep_rows <- !is.na(dat$ischaemic_stroke_date) & dat$ischaemic_stroke_date >= as.Date("2013-01-01") | is.na(dat$ischaemic_stroke_date)
dat <- dat[keep_rows, ]

#### 2.1.3 intracerebral haemorrhage < 2013-01-01 
keep_rows <- !is.na(dat$intracerebral_haemorrhage_date) & dat$intracerebral_haemorrhage_date >= as.Date("2013-01-01") | is.na(dat$intracerebral_haemorrhage_date)
dat <- dat[keep_rows, ]

### 2.2 Participants that reported having a MI < 2013
#### 2.2.1 MI < 2013-01-01
keep_rows <- !is.na(dat$myocardial_infarction_date) & dat$myocardial_infarction_date >= as.Date("2013-01-01") | is.na(dat$myocardial_infarction_date)
dat <- dat[keep_rows, ]

#### 2.2.2 STEMI < 2013-01-01
keep_rows <- !is.na(dat$STEMI_date) & dat$STEMI_date >= as.Date("2013-01-01") | is.na(dat$STEMI_date)
dat <- dat[keep_rows, ]

#### 2.2.3 NSTEMI < 2013-01-01
keep_rows <- !is.na(dat$NSTEMI_date) & dat$NSTEMI_date >= as.Date("2013-01-01") | is.na(dat$NSTEMI_date)
dat <- dat[keep_rows, ]

## 3. Missing data for ethnicity, education*, smoking status, alcohol consumption, or
##    Townsend Deprivation Index
keep_cols <- c('smoking_raw', 'alcohol_raw', 'ethnicity_raw', 'tdi_raw', 'education_raw', 'oily_fish', 'fresh_fruit', 'cooked_vg', 'BMI_raw', 'sex', 'month_birth', 'year_birth')
dat <- dat[complete.cases(dat[, keep_cols]), ]

print(dat)

###### *Note: Education is currently missing






