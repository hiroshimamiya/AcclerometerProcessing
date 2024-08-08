survival_analysis_prep
================
yacine
2024-07-16

We load and/or install the packages we will be using:

We load the data:

``` r
#full_df <- read.csv("/home/yacine/final_df_full.csv") # full df w/o exclusions
#full_df <- read.csv("/home/yacine/UKBB_beluga/df_exc.csv") # full df with exclusions
full_df <- read.csv("/home/yacine/UKBB_beluga/df_exc_recode.csv") # full df with exclusions + recoding
```

We change the date format for the start and end accelerometer
variables - which will be crucial for later steps:

``` r
full_df$date_start_accel <- as.Date(full_df$date_start_accel)
full_df$date_end_accel <- as.Date(full_df$date_end_accel)
```

## Follow-up time:

First we create the “end_of_fu” variable, which can be classified as
date of stroke/MI, date of death or the end of the study (i.e. 2022):

``` r
# we find out which death date is the latest which we will set as the "end of the study" 
# date
max_death_date_0 <- max(full_df$'date_of_death_0', na.rm = TRUE)
max_death_date_1 <- max(full_df$'date_of_death_1', na.rm = TRUE)
```

    ## Warning in max(full_df$date_of_death_1, na.rm = TRUE): no non-missing arguments
    ## to max; returning -Inf

``` r
print(max_death_date_0)
```

    ## [1] "2022-12-17"

``` r
print(max_death_date_1)
```

    ## [1] -Inf

``` r
# given that we see that the max(death_date) is "2022-12-17", this will serve as 
# our "end of study" date

# we create a "end_of_study" column which indicates the end of the whole data collection:
full_df$end_of_study_date <- as.Date('2022-12-17')

# we reate a vector of all the date columns:
date_cols <- c('stroke_date', 'ischaemic_stroke_date', 'intracerebral_haemorrhage_date',
               'myocardial_infarction_date', 'STEMI_date', 'NSTEMI_date',
               'date_of_death_0', 'date_of_death_1', 'date_lost_followup',
               'end_of_study_date')



# we make sure all values within the date columns are in date format:
full_df[date_cols] <- lapply(full_df[date_cols], as.Date)

# we create the end_of_fu column by only keeping the earliest date from each rows
# within each date columns:
full_df$end_of_fu <- apply(full_df[date_cols], 1, function(x) min(x[!is.na(x)]))

#print(full_df$end_of_fu)
```

We can now create the “follow-up time” column by calculating the
difference (in months) between the “end of follow up” and “end time of
wear” columns:

``` r
# remove NA data from date_end_accel (to do in data exclusion UKBB script?)
full_df <- full_df[!is.na(full_df$date_end_accel), ]

difftime_weeks <- difftime(full_df$end_of_fu, full_df$date_end_accel, units = "weeks")

# because the "difftime" function only allows a maximum of units in weeks, we 
# devide by 4.345 to convert to difference months
full_df$fu_time <- as.numeric(difftime_weeks) / 4.345

head(full_df$fu_time) 
```

    ## [1] 108.47307 103.57417  97.62316  88.45005 103.04811  96.20938

``` r
#print(full_df$date_start_accel)
```

##### Create binary variable for CVD (strokes and MI)

``` r
# First we create a new column which will indicate if a participant has had: 
## a) a stroke == 1; or not == 0:
stroke_cols <- c('stroke_date', 'ischaemic_stroke_date', 'intracerebral_haemorrhage_date')

# Create the 'stroke' column
full_df$stroke <- ifelse(rowSums(!is.na(full_df[, stroke_cols ])) > 0, 1, 0)


## b) a MI == 1; or not == 0:
MI_cols <- c('myocardial_infarction_date', 'STEMI_date', 'NSTEMI_date')
full_df$MI <- ifelse(rowSums(!is.na(full_df[, MI_cols ])) > 0, 1, 0)


head(full_df$stroke)
```

    ## [1] 0 0 0 0 0 0

``` r
head(full_df$MI)
```

    ## [1] 0 0 0 0 0 0

``` r
# We now create a "CVD" column which indicates if the participants has had a
# stroke and/or MI (==1) or not (==0)
full_df <- full_df %>%
  mutate(CVD = ifelse(stroke == 1 | MI == 1, 1, 0))
```

## Associations with risk of incident cardiovascular disease

In the data preparation step, we added an event status indicator at exit
and a follow-up time variable. Using these, we can run a Cox model to
associate overall activity with risk of incident cardiovascular disease.
We’ll start by using time-on-study as the timescale and set it up using
the ‘survival’ package in R. We’ll also adjust for various possible
confounding variables (following the confounders used by [Ramakrishnan
et
al.](https://journals.plos.org/plosmedicine/article?id=10.1371/journal.pmed.1003487)):

``` r
#cox_model <- coxph(
  #Surv(fu_time, stroke, MI) ~ overall_activity_quarters + age_entry_years + sex + ethnicity + tdi_quarters + age_education + smoking + alcohol,
 # data = full_df
#)
#summary(cox_model)
```

################ GitHub PA code

# Now link data with acclerometer weekly minutes, for LPA, MVPA, and sedendary behavior.

- There are 3 diferent accelerometric measures
  1.  PA1 - Vector magnitude based measures as calcuated from
      time-series of vector magnitude by UKBB
  2.  PA2 - machine-learning derived mesared, for Field ID 1020
  3.  PA3 (pending) - Actigraph count-based measure, based on Freedson
      cutoff

\#Load derived accelerometer from UKBB, PA2 data

# Files from parallel processing of time-series (FieldID 90004) to generate ENMO summary of 100,000 ppl, PA1 data

We merge the full_df and PA1 and PA2 df by eids

``` r
full_df_PA1 <- inner_join(full_df, enmoTSParallel_PA1, by = "eid")
full_df_incl_PA1_PA2 <- inner_join(full_df_PA1, ML_derived_PA2, by = "eid")

names(full_df_incl_PA1_PA2) <- gsub("\\.x$", "_PA1", names(full_df_incl_PA1_PA2))
names(full_df_incl_PA1_PA2) <- gsub("\\.y$", "_PA2", names(full_df_incl_PA1_PA2))

write.csv(full_df_incl_PA1_PA2, "/home/yacine/survival_analysis/full_df_with_PA.csv", row.names = FALSE)
```

####### Create Summary of Baseline Characteristics Table

``` r
# recode binary variables 
full_df_incl_PA1_PA2 <- full_df_incl_PA1_PA2 %>%
  mutate(sex = recode(sex, `1` = "Man", `0` = "Woman"))

MVPA_coding <- c(
  '[0,99]' = 'MVPA Quarter 1', 
  '(99,222]' = 'MVPA Quarter 2', 
  '(222,395]' = 'MVPA Quarter 3', 
  '(395,1.01e+04]' = 'MVPA Quarter 4'
)


full_df_incl_PA1_PA2 <- full_df_incl_PA1_PA2 %>%
  mutate(MVPA_Quant_PA2 = recode(as.character(MVPA_Quant_PA2), !!!MVPA_coding))


# we seperate the full_df_incl_PA1_PA2 in 4 tables based off MVPA quarters:
df_MVPA_quarter1 <- full_df_incl_PA1_PA2 %>% filter(MVPA_Quant_PA2 == "MVPA Quarter 1")

df_MVPA_quarter2 <- full_df_incl_PA1_PA2 %>% filter(MVPA_Quant_PA2 == "MVPA Quarter 2")

df_MVPA_quarter3 <- full_df_incl_PA1_PA2 %>% filter(MVPA_Quant_PA2 == "MVPA Quarter 3")

df_MVPA_quarter4 <- full_df_incl_PA1_PA2 %>% filter(MVPA_Quant_PA2 == "MVPA Quarter 4")
```

## We create a table of summary baseline characteristics for each quarters:

### MVPA Quarter 1:

``` r
summ_base_char_MVPA_quarter1 <- df_MVPA_quarter1 %>%
  tbl_summary(
    include = c(stroke, MI, sex, fresh_fruit, oily_fish, cooked_vg, alcohol_raw, 
                processed_meat, alcohol, smoking, ethnicity, education_level,  
                diabetes, BMI),
    statistic = list(all_continuous() ~ "{mean} ± {sd}")
  ) %>%
  bold_labels()

# Print the summary table
print(summ_base_char_MVPA_quarter1)
```

    ## <div id="ojqlfajhue" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
    ##   <style>#ojqlfajhue table {
    ##   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
    ##   -webkit-font-smoothing: antialiased;
    ##   -moz-osx-font-smoothing: grayscale;
    ## }
    ## 
    ## #ojqlfajhue thead, #ojqlfajhue tbody, #ojqlfajhue tfoot, #ojqlfajhue tr, #ojqlfajhue td, #ojqlfajhue th {
    ##   border-style: none;
    ## }
    ## 
    ## #ojqlfajhue p {
    ##   margin: 0;
    ##   padding: 0;
    ## }
    ## 
    ## #ojqlfajhue .gt_table {
    ##   display: table;
    ##   border-collapse: collapse;
    ##   line-height: normal;
    ##   margin-left: auto;
    ##   margin-right: auto;
    ##   color: #333333;
    ##   font-size: 16px;
    ##   font-weight: normal;
    ##   font-style: normal;
    ##   background-color: #FFFFFF;
    ##   width: auto;
    ##   border-top-style: solid;
    ##   border-top-width: 2px;
    ##   border-top-color: #A8A8A8;
    ##   border-right-style: none;
    ##   border-right-width: 2px;
    ##   border-right-color: #D3D3D3;
    ##   border-bottom-style: solid;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #A8A8A8;
    ##   border-left-style: none;
    ##   border-left-width: 2px;
    ##   border-left-color: #D3D3D3;
    ## }
    ## 
    ## #ojqlfajhue .gt_caption {
    ##   padding-top: 4px;
    ##   padding-bottom: 4px;
    ## }
    ## 
    ## #ojqlfajhue .gt_title {
    ##   color: #333333;
    ##   font-size: 125%;
    ##   font-weight: initial;
    ##   padding-top: 4px;
    ##   padding-bottom: 4px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   border-bottom-color: #FFFFFF;
    ##   border-bottom-width: 0;
    ## }
    ## 
    ## #ojqlfajhue .gt_subtitle {
    ##   color: #333333;
    ##   font-size: 85%;
    ##   font-weight: initial;
    ##   padding-top: 3px;
    ##   padding-bottom: 5px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   border-top-color: #FFFFFF;
    ##   border-top-width: 0;
    ## }
    ## 
    ## #ojqlfajhue .gt_heading {
    ##   background-color: #FFFFFF;
    ##   text-align: center;
    ##   border-bottom-color: #FFFFFF;
    ##   border-left-style: none;
    ##   border-left-width: 1px;
    ##   border-left-color: #D3D3D3;
    ##   border-right-style: none;
    ##   border-right-width: 1px;
    ##   border-right-color: #D3D3D3;
    ## }
    ## 
    ## #ojqlfajhue .gt_bottom_border {
    ##   border-bottom-style: solid;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ## }
    ## 
    ## #ojqlfajhue .gt_col_headings {
    ##   border-top-style: solid;
    ##   border-top-width: 2px;
    ##   border-top-color: #D3D3D3;
    ##   border-bottom-style: solid;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ##   border-left-style: none;
    ##   border-left-width: 1px;
    ##   border-left-color: #D3D3D3;
    ##   border-right-style: none;
    ##   border-right-width: 1px;
    ##   border-right-color: #D3D3D3;
    ## }
    ## 
    ## #ojqlfajhue .gt_col_heading {
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   font-size: 100%;
    ##   font-weight: normal;
    ##   text-transform: inherit;
    ##   border-left-style: none;
    ##   border-left-width: 1px;
    ##   border-left-color: #D3D3D3;
    ##   border-right-style: none;
    ##   border-right-width: 1px;
    ##   border-right-color: #D3D3D3;
    ##   vertical-align: bottom;
    ##   padding-top: 5px;
    ##   padding-bottom: 6px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   overflow-x: hidden;
    ## }
    ## 
    ## #ojqlfajhue .gt_column_spanner_outer {
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   font-size: 100%;
    ##   font-weight: normal;
    ##   text-transform: inherit;
    ##   padding-top: 0;
    ##   padding-bottom: 0;
    ##   padding-left: 4px;
    ##   padding-right: 4px;
    ## }
    ## 
    ## #ojqlfajhue .gt_column_spanner_outer:first-child {
    ##   padding-left: 0;
    ## }
    ## 
    ## #ojqlfajhue .gt_column_spanner_outer:last-child {
    ##   padding-right: 0;
    ## }
    ## 
    ## #ojqlfajhue .gt_column_spanner {
    ##   border-bottom-style: solid;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ##   vertical-align: bottom;
    ##   padding-top: 5px;
    ##   padding-bottom: 5px;
    ##   overflow-x: hidden;
    ##   display: inline-block;
    ##   width: 100%;
    ## }
    ## 
    ## #ojqlfajhue .gt_spanner_row {
    ##   border-bottom-style: hidden;
    ## }
    ## 
    ## #ojqlfajhue .gt_group_heading {
    ##   padding-top: 8px;
    ##   padding-bottom: 8px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   font-size: 100%;
    ##   font-weight: initial;
    ##   text-transform: inherit;
    ##   border-top-style: solid;
    ##   border-top-width: 2px;
    ##   border-top-color: #D3D3D3;
    ##   border-bottom-style: solid;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ##   border-left-style: none;
    ##   border-left-width: 1px;
    ##   border-left-color: #D3D3D3;
    ##   border-right-style: none;
    ##   border-right-width: 1px;
    ##   border-right-color: #D3D3D3;
    ##   vertical-align: middle;
    ##   text-align: left;
    ## }
    ## 
    ## #ojqlfajhue .gt_empty_group_heading {
    ##   padding: 0.5px;
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   font-size: 100%;
    ##   font-weight: initial;
    ##   border-top-style: solid;
    ##   border-top-width: 2px;
    ##   border-top-color: #D3D3D3;
    ##   border-bottom-style: solid;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ##   vertical-align: middle;
    ## }
    ## 
    ## #ojqlfajhue .gt_from_md > :first-child {
    ##   margin-top: 0;
    ## }
    ## 
    ## #ojqlfajhue .gt_from_md > :last-child {
    ##   margin-bottom: 0;
    ## }
    ## 
    ## #ojqlfajhue .gt_row {
    ##   padding-top: 8px;
    ##   padding-bottom: 8px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   margin: 10px;
    ##   border-top-style: solid;
    ##   border-top-width: 1px;
    ##   border-top-color: #D3D3D3;
    ##   border-left-style: none;
    ##   border-left-width: 1px;
    ##   border-left-color: #D3D3D3;
    ##   border-right-style: none;
    ##   border-right-width: 1px;
    ##   border-right-color: #D3D3D3;
    ##   vertical-align: middle;
    ##   overflow-x: hidden;
    ## }
    ## 
    ## #ojqlfajhue .gt_stub {
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   font-size: 100%;
    ##   font-weight: initial;
    ##   text-transform: inherit;
    ##   border-right-style: solid;
    ##   border-right-width: 2px;
    ##   border-right-color: #D3D3D3;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ## }
    ## 
    ## #ojqlfajhue .gt_stub_row_group {
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   font-size: 100%;
    ##   font-weight: initial;
    ##   text-transform: inherit;
    ##   border-right-style: solid;
    ##   border-right-width: 2px;
    ##   border-right-color: #D3D3D3;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   vertical-align: top;
    ## }
    ## 
    ## #ojqlfajhue .gt_row_group_first td {
    ##   border-top-width: 2px;
    ## }
    ## 
    ## #ojqlfajhue .gt_row_group_first th {
    ##   border-top-width: 2px;
    ## }
    ## 
    ## #ojqlfajhue .gt_summary_row {
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   text-transform: inherit;
    ##   padding-top: 8px;
    ##   padding-bottom: 8px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ## }
    ## 
    ## #ojqlfajhue .gt_first_summary_row {
    ##   border-top-style: solid;
    ##   border-top-color: #D3D3D3;
    ## }
    ## 
    ## #ojqlfajhue .gt_first_summary_row.thick {
    ##   border-top-width: 2px;
    ## }
    ## 
    ## #ojqlfajhue .gt_last_summary_row {
    ##   padding-top: 8px;
    ##   padding-bottom: 8px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   border-bottom-style: solid;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ## }
    ## 
    ## #ojqlfajhue .gt_grand_summary_row {
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   text-transform: inherit;
    ##   padding-top: 8px;
    ##   padding-bottom: 8px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ## }
    ## 
    ## #ojqlfajhue .gt_first_grand_summary_row {
    ##   padding-top: 8px;
    ##   padding-bottom: 8px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   border-top-style: double;
    ##   border-top-width: 6px;
    ##   border-top-color: #D3D3D3;
    ## }
    ## 
    ## #ojqlfajhue .gt_last_grand_summary_row_top {
    ##   padding-top: 8px;
    ##   padding-bottom: 8px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   border-bottom-style: double;
    ##   border-bottom-width: 6px;
    ##   border-bottom-color: #D3D3D3;
    ## }
    ## 
    ## #ojqlfajhue .gt_striped {
    ##   background-color: rgba(128, 128, 128, 0.05);
    ## }
    ## 
    ## #ojqlfajhue .gt_table_body {
    ##   border-top-style: solid;
    ##   border-top-width: 2px;
    ##   border-top-color: #D3D3D3;
    ##   border-bottom-style: solid;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ## }
    ## 
    ## #ojqlfajhue .gt_footnotes {
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   border-bottom-style: none;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ##   border-left-style: none;
    ##   border-left-width: 2px;
    ##   border-left-color: #D3D3D3;
    ##   border-right-style: none;
    ##   border-right-width: 2px;
    ##   border-right-color: #D3D3D3;
    ## }
    ## 
    ## #ojqlfajhue .gt_footnote {
    ##   margin: 0px;
    ##   font-size: 90%;
    ##   padding-top: 4px;
    ##   padding-bottom: 4px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ## }
    ## 
    ## #ojqlfajhue .gt_sourcenotes {
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   border-bottom-style: none;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ##   border-left-style: none;
    ##   border-left-width: 2px;
    ##   border-left-color: #D3D3D3;
    ##   border-right-style: none;
    ##   border-right-width: 2px;
    ##   border-right-color: #D3D3D3;
    ## }
    ## 
    ## #ojqlfajhue .gt_sourcenote {
    ##   font-size: 90%;
    ##   padding-top: 4px;
    ##   padding-bottom: 4px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ## }
    ## 
    ## #ojqlfajhue .gt_left {
    ##   text-align: left;
    ## }
    ## 
    ## #ojqlfajhue .gt_center {
    ##   text-align: center;
    ## }
    ## 
    ## #ojqlfajhue .gt_right {
    ##   text-align: right;
    ##   font-variant-numeric: tabular-nums;
    ## }
    ## 
    ## #ojqlfajhue .gt_font_normal {
    ##   font-weight: normal;
    ## }
    ## 
    ## #ojqlfajhue .gt_font_bold {
    ##   font-weight: bold;
    ## }
    ## 
    ## #ojqlfajhue .gt_font_italic {
    ##   font-style: italic;
    ## }
    ## 
    ## #ojqlfajhue .gt_super {
    ##   font-size: 65%;
    ## }
    ## 
    ## #ojqlfajhue .gt_footnote_marks {
    ##   font-size: 75%;
    ##   vertical-align: 0.4em;
    ##   position: initial;
    ## }
    ## 
    ## #ojqlfajhue .gt_asterisk {
    ##   font-size: 100%;
    ##   vertical-align: 0;
    ## }
    ## 
    ## #ojqlfajhue .gt_indent_1 {
    ##   text-indent: 5px;
    ## }
    ## 
    ## #ojqlfajhue .gt_indent_2 {
    ##   text-indent: 10px;
    ## }
    ## 
    ## #ojqlfajhue .gt_indent_3 {
    ##   text-indent: 15px;
    ## }
    ## 
    ## #ojqlfajhue .gt_indent_4 {
    ##   text-indent: 20px;
    ## }
    ## 
    ## #ojqlfajhue .gt_indent_5 {
    ##   text-indent: 25px;
    ## }
    ## 
    ## #ojqlfajhue .katex-display {
    ##   display: inline-flex !important;
    ##   margin-bottom: 0.75em !important;
    ## }
    ## 
    ## #ojqlfajhue div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
    ##   height: 0px !important;
    ## }
    ## </style>
    ##   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
    ##   <thead>
    ##     <tr class="gt_col_headings">
    ##       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="&lt;span class='gt_from_md'&gt;&lt;strong&gt;Characteristic&lt;/strong&gt;&lt;/span&gt;"><span class='gt_from_md'><strong>Characteristic</strong></span></th>
    ##       <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="&lt;span class='gt_from_md'&gt;&lt;strong&gt;N = 20,116&lt;/strong&gt;&lt;/span&gt;&lt;span class=&quot;gt_footnote_marks&quot; style=&quot;white-space:nowrap;font-style:italic;font-weight:normal;line-height: 0;&quot;&gt;&lt;sup&gt;1&lt;/sup&gt;&lt;/span&gt;"><span class='gt_from_md'><strong>N = 20,116</strong></span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height: 0;"><sup>1</sup></span></th>
    ##     </tr>
    ##   </thead>
    ##   <tbody class="gt_table_body">
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">stroke</td>
    ## <td headers="stat_0" class="gt_row gt_center">382 (1.9%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">MI</td>
    ## <td headers="stat_0" class="gt_row gt_center">639 (3.2%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">sex</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Man</td>
    ## <td headers="stat_0" class="gt_row gt_center">6,082 (30%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Woman</td>
    ## <td headers="stat_0" class="gt_row gt_center">14,034 (70%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">fresh_fruit</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    &lt; 2 servings/day</td>
    ## <td headers="stat_0" class="gt_row gt_center">5,324 (28%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    2 or 3 servings/day</td>
    ## <td headers="stat_0" class="gt_row gt_center">5,794 (31%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    3 or 4 servings/day</td>
    ## <td headers="stat_0" class="gt_row gt_center">4,025 (21%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    More than 4 servings/day</td>
    ## <td headers="stat_0" class="gt_row gt_center">3,676 (20%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Unknown</td>
    ## <td headers="stat_0" class="gt_row gt_center">1,297</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">oily_fish</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    2 to 4 servings/week</td>
    ## <td headers="stat_0" class="gt_row gt_center">3,221 (16%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    More than 4 servings/week</td>
    ## <td headers="stat_0" class="gt_row gt_center">16,895 (84%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">cooked_vg</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    &lt; 2 servings/day</td>
    ## <td headers="stat_0" class="gt_row gt_center">2,749 (14%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    2 or 3 servings/day</td>
    ## <td headers="stat_0" class="gt_row gt_center">6,859 (35%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    3 or 4 servings/day</td>
    ## <td headers="stat_0" class="gt_row gt_center">5,603 (29%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    More than 4 servings/day</td>
    ## <td headers="stat_0" class="gt_row gt_center">4,376 (22%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Unknown</td>
    ## <td headers="stat_0" class="gt_row gt_center">529</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">alcohol_raw</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Daily or almost daily</td>
    ## <td headers="stat_0" class="gt_row gt_center">3,853 (19%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Never</td>
    ## <td headers="stat_0" class="gt_row gt_center">1,575 (7.8%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Once or twice a week</td>
    ## <td headers="stat_0" class="gt_row gt_center">5,049 (25%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    One to three times a month</td>
    ## <td headers="stat_0" class="gt_row gt_center">2,666 (13%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Prefer not to answer</td>
    ## <td headers="stat_0" class="gt_row gt_center">9 (&lt;0.1%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Special occasions only</td>
    ## <td headers="stat_0" class="gt_row gt_center">2,753 (14%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Three or four times a week</td>
    ## <td headers="stat_0" class="gt_row gt_center">4,211 (21%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">processed_meat</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    2 to 4 servings/week</td>
    ## <td headers="stat_0" class="gt_row gt_center">5,086 (25%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    More than 4 servings/week</td>
    ## <td headers="stat_0" class="gt_row gt_center">15,030 (75%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">alcohol</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Daily or almost daily</td>
    ## <td headers="stat_0" class="gt_row gt_center">3,853 (24%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Less than once a week</td>
    ## <td headers="stat_0" class="gt_row gt_center">5,419 (34%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Never</td>
    ## <td headers="stat_0" class="gt_row gt_center">1,575 (9.9%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Once or twice a week</td>
    ## <td headers="stat_0" class="gt_row gt_center">5,049 (32%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Prefer not to answer</td>
    ## <td headers="stat_0" class="gt_row gt_center">9 (&lt;0.1%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Unknown</td>
    ## <td headers="stat_0" class="gt_row gt_center">4,211</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">smoking</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Current</td>
    ## <td headers="stat_0" class="gt_row gt_center">1,908 (9.5%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Never</td>
    ## <td headers="stat_0" class="gt_row gt_center">10,835 (54%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Previous</td>
    ## <td headers="stat_0" class="gt_row gt_center">7,319 (36%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Unknown</td>
    ## <td headers="stat_0" class="gt_row gt_center">54</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">ethnicity</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Nonwhite</td>
    ## <td headers="stat_0" class="gt_row gt_center">697 (3.5%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    White</td>
    ## <td headers="stat_0" class="gt_row gt_center">19,362 (97%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Unknown</td>
    ## <td headers="stat_0" class="gt_row gt_center">57</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">education_level</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    A levels/AS levels or equivalent, NVQ or HND or HNC or equivalent, other professional qualifications</td>
    ## <td headers="stat_0" class="gt_row gt_center">5,118 (26%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    College or University degree</td>
    ## <td headers="stat_0" class="gt_row gt_center">6,511 (33%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    None of the above</td>
    ## <td headers="stat_0" class="gt_row gt_center">2,340 (12%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    O levels/GCSEs or equivalent, CSEs or equivalent</td>
    ## <td headers="stat_0" class="gt_row gt_center">6,019 (30%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Unknown</td>
    ## <td headers="stat_0" class="gt_row gt_center">128</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">diabetes</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Do not know</td>
    ## <td headers="stat_0" class="gt_row gt_center">28 (0.1%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    No</td>
    ## <td headers="stat_0" class="gt_row gt_center">1,154 (5.7%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Prefer not to answer</td>
    ## <td headers="stat_0" class="gt_row gt_center">4 (&lt;0.1%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Yes</td>
    ## <td headers="stat_0" class="gt_row gt_center">18,930 (94%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">BMI</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Normal (18.5 kg/m2 to &lt; 25 kg/m2)</td>
    ## <td headers="stat_0" class="gt_row gt_center">5,565 (28%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Obesity Class I, II or III (&gt; 30 kg/m2)</td>
    ## <td headers="stat_0" class="gt_row gt_center">6,531 (32%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Overweight (25 kg/m2 to &lt; 30 kg/m2)</td>
    ## <td headers="stat_0" class="gt_row gt_center">7,943 (39%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Underweight (&lt; 18.5 kg/m2)</td>
    ## <td headers="stat_0" class="gt_row gt_center">77 (0.4%)</td></tr>
    ##   </tbody>
    ##   
    ##   <tfoot class="gt_footnotes">
    ##     <tr>
    ##       <td class="gt_footnote" colspan="2"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height: 0;"><sup>1</sup></span> <span class='gt_from_md'>n (%)</span></td>
    ##     </tr>
    ##   </tfoot>
    ## </table>
    ## </div>

### MVPA Quarter 2:

``` r
summ_base_char_MVPA_quarter2 <- df_MVPA_quarter2 %>%
  tbl_summary(
    include = c(stroke, MI, sex, fresh_fruit, oily_fish, cooked_vg, alcohol_raw, 
                processed_meat, alcohol, smoking, ethnicity, education_level,  
                diabetes, BMI),
    statistic = list(all_continuous() ~ "{mean} ± {sd}")
  ) %>%
  bold_labels()

# Print the summary table
print(summ_base_char_MVPA_quarter2)
```

    ## <div id="mgfevukybf" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
    ##   <style>#mgfevukybf table {
    ##   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
    ##   -webkit-font-smoothing: antialiased;
    ##   -moz-osx-font-smoothing: grayscale;
    ## }
    ## 
    ## #mgfevukybf thead, #mgfevukybf tbody, #mgfevukybf tfoot, #mgfevukybf tr, #mgfevukybf td, #mgfevukybf th {
    ##   border-style: none;
    ## }
    ## 
    ## #mgfevukybf p {
    ##   margin: 0;
    ##   padding: 0;
    ## }
    ## 
    ## #mgfevukybf .gt_table {
    ##   display: table;
    ##   border-collapse: collapse;
    ##   line-height: normal;
    ##   margin-left: auto;
    ##   margin-right: auto;
    ##   color: #333333;
    ##   font-size: 16px;
    ##   font-weight: normal;
    ##   font-style: normal;
    ##   background-color: #FFFFFF;
    ##   width: auto;
    ##   border-top-style: solid;
    ##   border-top-width: 2px;
    ##   border-top-color: #A8A8A8;
    ##   border-right-style: none;
    ##   border-right-width: 2px;
    ##   border-right-color: #D3D3D3;
    ##   border-bottom-style: solid;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #A8A8A8;
    ##   border-left-style: none;
    ##   border-left-width: 2px;
    ##   border-left-color: #D3D3D3;
    ## }
    ## 
    ## #mgfevukybf .gt_caption {
    ##   padding-top: 4px;
    ##   padding-bottom: 4px;
    ## }
    ## 
    ## #mgfevukybf .gt_title {
    ##   color: #333333;
    ##   font-size: 125%;
    ##   font-weight: initial;
    ##   padding-top: 4px;
    ##   padding-bottom: 4px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   border-bottom-color: #FFFFFF;
    ##   border-bottom-width: 0;
    ## }
    ## 
    ## #mgfevukybf .gt_subtitle {
    ##   color: #333333;
    ##   font-size: 85%;
    ##   font-weight: initial;
    ##   padding-top: 3px;
    ##   padding-bottom: 5px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   border-top-color: #FFFFFF;
    ##   border-top-width: 0;
    ## }
    ## 
    ## #mgfevukybf .gt_heading {
    ##   background-color: #FFFFFF;
    ##   text-align: center;
    ##   border-bottom-color: #FFFFFF;
    ##   border-left-style: none;
    ##   border-left-width: 1px;
    ##   border-left-color: #D3D3D3;
    ##   border-right-style: none;
    ##   border-right-width: 1px;
    ##   border-right-color: #D3D3D3;
    ## }
    ## 
    ## #mgfevukybf .gt_bottom_border {
    ##   border-bottom-style: solid;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ## }
    ## 
    ## #mgfevukybf .gt_col_headings {
    ##   border-top-style: solid;
    ##   border-top-width: 2px;
    ##   border-top-color: #D3D3D3;
    ##   border-bottom-style: solid;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ##   border-left-style: none;
    ##   border-left-width: 1px;
    ##   border-left-color: #D3D3D3;
    ##   border-right-style: none;
    ##   border-right-width: 1px;
    ##   border-right-color: #D3D3D3;
    ## }
    ## 
    ## #mgfevukybf .gt_col_heading {
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   font-size: 100%;
    ##   font-weight: normal;
    ##   text-transform: inherit;
    ##   border-left-style: none;
    ##   border-left-width: 1px;
    ##   border-left-color: #D3D3D3;
    ##   border-right-style: none;
    ##   border-right-width: 1px;
    ##   border-right-color: #D3D3D3;
    ##   vertical-align: bottom;
    ##   padding-top: 5px;
    ##   padding-bottom: 6px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   overflow-x: hidden;
    ## }
    ## 
    ## #mgfevukybf .gt_column_spanner_outer {
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   font-size: 100%;
    ##   font-weight: normal;
    ##   text-transform: inherit;
    ##   padding-top: 0;
    ##   padding-bottom: 0;
    ##   padding-left: 4px;
    ##   padding-right: 4px;
    ## }
    ## 
    ## #mgfevukybf .gt_column_spanner_outer:first-child {
    ##   padding-left: 0;
    ## }
    ## 
    ## #mgfevukybf .gt_column_spanner_outer:last-child {
    ##   padding-right: 0;
    ## }
    ## 
    ## #mgfevukybf .gt_column_spanner {
    ##   border-bottom-style: solid;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ##   vertical-align: bottom;
    ##   padding-top: 5px;
    ##   padding-bottom: 5px;
    ##   overflow-x: hidden;
    ##   display: inline-block;
    ##   width: 100%;
    ## }
    ## 
    ## #mgfevukybf .gt_spanner_row {
    ##   border-bottom-style: hidden;
    ## }
    ## 
    ## #mgfevukybf .gt_group_heading {
    ##   padding-top: 8px;
    ##   padding-bottom: 8px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   font-size: 100%;
    ##   font-weight: initial;
    ##   text-transform: inherit;
    ##   border-top-style: solid;
    ##   border-top-width: 2px;
    ##   border-top-color: #D3D3D3;
    ##   border-bottom-style: solid;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ##   border-left-style: none;
    ##   border-left-width: 1px;
    ##   border-left-color: #D3D3D3;
    ##   border-right-style: none;
    ##   border-right-width: 1px;
    ##   border-right-color: #D3D3D3;
    ##   vertical-align: middle;
    ##   text-align: left;
    ## }
    ## 
    ## #mgfevukybf .gt_empty_group_heading {
    ##   padding: 0.5px;
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   font-size: 100%;
    ##   font-weight: initial;
    ##   border-top-style: solid;
    ##   border-top-width: 2px;
    ##   border-top-color: #D3D3D3;
    ##   border-bottom-style: solid;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ##   vertical-align: middle;
    ## }
    ## 
    ## #mgfevukybf .gt_from_md > :first-child {
    ##   margin-top: 0;
    ## }
    ## 
    ## #mgfevukybf .gt_from_md > :last-child {
    ##   margin-bottom: 0;
    ## }
    ## 
    ## #mgfevukybf .gt_row {
    ##   padding-top: 8px;
    ##   padding-bottom: 8px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   margin: 10px;
    ##   border-top-style: solid;
    ##   border-top-width: 1px;
    ##   border-top-color: #D3D3D3;
    ##   border-left-style: none;
    ##   border-left-width: 1px;
    ##   border-left-color: #D3D3D3;
    ##   border-right-style: none;
    ##   border-right-width: 1px;
    ##   border-right-color: #D3D3D3;
    ##   vertical-align: middle;
    ##   overflow-x: hidden;
    ## }
    ## 
    ## #mgfevukybf .gt_stub {
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   font-size: 100%;
    ##   font-weight: initial;
    ##   text-transform: inherit;
    ##   border-right-style: solid;
    ##   border-right-width: 2px;
    ##   border-right-color: #D3D3D3;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ## }
    ## 
    ## #mgfevukybf .gt_stub_row_group {
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   font-size: 100%;
    ##   font-weight: initial;
    ##   text-transform: inherit;
    ##   border-right-style: solid;
    ##   border-right-width: 2px;
    ##   border-right-color: #D3D3D3;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   vertical-align: top;
    ## }
    ## 
    ## #mgfevukybf .gt_row_group_first td {
    ##   border-top-width: 2px;
    ## }
    ## 
    ## #mgfevukybf .gt_row_group_first th {
    ##   border-top-width: 2px;
    ## }
    ## 
    ## #mgfevukybf .gt_summary_row {
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   text-transform: inherit;
    ##   padding-top: 8px;
    ##   padding-bottom: 8px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ## }
    ## 
    ## #mgfevukybf .gt_first_summary_row {
    ##   border-top-style: solid;
    ##   border-top-color: #D3D3D3;
    ## }
    ## 
    ## #mgfevukybf .gt_first_summary_row.thick {
    ##   border-top-width: 2px;
    ## }
    ## 
    ## #mgfevukybf .gt_last_summary_row {
    ##   padding-top: 8px;
    ##   padding-bottom: 8px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   border-bottom-style: solid;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ## }
    ## 
    ## #mgfevukybf .gt_grand_summary_row {
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   text-transform: inherit;
    ##   padding-top: 8px;
    ##   padding-bottom: 8px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ## }
    ## 
    ## #mgfevukybf .gt_first_grand_summary_row {
    ##   padding-top: 8px;
    ##   padding-bottom: 8px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   border-top-style: double;
    ##   border-top-width: 6px;
    ##   border-top-color: #D3D3D3;
    ## }
    ## 
    ## #mgfevukybf .gt_last_grand_summary_row_top {
    ##   padding-top: 8px;
    ##   padding-bottom: 8px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   border-bottom-style: double;
    ##   border-bottom-width: 6px;
    ##   border-bottom-color: #D3D3D3;
    ## }
    ## 
    ## #mgfevukybf .gt_striped {
    ##   background-color: rgba(128, 128, 128, 0.05);
    ## }
    ## 
    ## #mgfevukybf .gt_table_body {
    ##   border-top-style: solid;
    ##   border-top-width: 2px;
    ##   border-top-color: #D3D3D3;
    ##   border-bottom-style: solid;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ## }
    ## 
    ## #mgfevukybf .gt_footnotes {
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   border-bottom-style: none;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ##   border-left-style: none;
    ##   border-left-width: 2px;
    ##   border-left-color: #D3D3D3;
    ##   border-right-style: none;
    ##   border-right-width: 2px;
    ##   border-right-color: #D3D3D3;
    ## }
    ## 
    ## #mgfevukybf .gt_footnote {
    ##   margin: 0px;
    ##   font-size: 90%;
    ##   padding-top: 4px;
    ##   padding-bottom: 4px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ## }
    ## 
    ## #mgfevukybf .gt_sourcenotes {
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   border-bottom-style: none;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ##   border-left-style: none;
    ##   border-left-width: 2px;
    ##   border-left-color: #D3D3D3;
    ##   border-right-style: none;
    ##   border-right-width: 2px;
    ##   border-right-color: #D3D3D3;
    ## }
    ## 
    ## #mgfevukybf .gt_sourcenote {
    ##   font-size: 90%;
    ##   padding-top: 4px;
    ##   padding-bottom: 4px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ## }
    ## 
    ## #mgfevukybf .gt_left {
    ##   text-align: left;
    ## }
    ## 
    ## #mgfevukybf .gt_center {
    ##   text-align: center;
    ## }
    ## 
    ## #mgfevukybf .gt_right {
    ##   text-align: right;
    ##   font-variant-numeric: tabular-nums;
    ## }
    ## 
    ## #mgfevukybf .gt_font_normal {
    ##   font-weight: normal;
    ## }
    ## 
    ## #mgfevukybf .gt_font_bold {
    ##   font-weight: bold;
    ## }
    ## 
    ## #mgfevukybf .gt_font_italic {
    ##   font-style: italic;
    ## }
    ## 
    ## #mgfevukybf .gt_super {
    ##   font-size: 65%;
    ## }
    ## 
    ## #mgfevukybf .gt_footnote_marks {
    ##   font-size: 75%;
    ##   vertical-align: 0.4em;
    ##   position: initial;
    ## }
    ## 
    ## #mgfevukybf .gt_asterisk {
    ##   font-size: 100%;
    ##   vertical-align: 0;
    ## }
    ## 
    ## #mgfevukybf .gt_indent_1 {
    ##   text-indent: 5px;
    ## }
    ## 
    ## #mgfevukybf .gt_indent_2 {
    ##   text-indent: 10px;
    ## }
    ## 
    ## #mgfevukybf .gt_indent_3 {
    ##   text-indent: 15px;
    ## }
    ## 
    ## #mgfevukybf .gt_indent_4 {
    ##   text-indent: 20px;
    ## }
    ## 
    ## #mgfevukybf .gt_indent_5 {
    ##   text-indent: 25px;
    ## }
    ## 
    ## #mgfevukybf .katex-display {
    ##   display: inline-flex !important;
    ##   margin-bottom: 0.75em !important;
    ## }
    ## 
    ## #mgfevukybf div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
    ##   height: 0px !important;
    ## }
    ## </style>
    ##   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
    ##   <thead>
    ##     <tr class="gt_col_headings">
    ##       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="&lt;span class='gt_from_md'&gt;&lt;strong&gt;Characteristic&lt;/strong&gt;&lt;/span&gt;"><span class='gt_from_md'><strong>Characteristic</strong></span></th>
    ##       <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="&lt;span class='gt_from_md'&gt;&lt;strong&gt;N = 24,236&lt;/strong&gt;&lt;/span&gt;&lt;span class=&quot;gt_footnote_marks&quot; style=&quot;white-space:nowrap;font-style:italic;font-weight:normal;line-height: 0;&quot;&gt;&lt;sup&gt;1&lt;/sup&gt;&lt;/span&gt;"><span class='gt_from_md'><strong>N = 24,236</strong></span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height: 0;"><sup>1</sup></span></th>
    ##     </tr>
    ##   </thead>
    ##   <tbody class="gt_table_body">
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">stroke</td>
    ## <td headers="stat_0" class="gt_row gt_center">345 (1.4%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">MI</td>
    ## <td headers="stat_0" class="gt_row gt_center">541 (2.2%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">sex</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Man</td>
    ## <td headers="stat_0" class="gt_row gt_center">8,996 (37%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Woman</td>
    ## <td headers="stat_0" class="gt_row gt_center">15,240 (63%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">fresh_fruit</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    &lt; 2 servings/day</td>
    ## <td headers="stat_0" class="gt_row gt_center">6,205 (27%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    2 or 3 servings/day</td>
    ## <td headers="stat_0" class="gt_row gt_center">7,145 (31%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    3 or 4 servings/day</td>
    ## <td headers="stat_0" class="gt_row gt_center">5,284 (23%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    More than 4 servings/day</td>
    ## <td headers="stat_0" class="gt_row gt_center">4,506 (19%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Unknown</td>
    ## <td headers="stat_0" class="gt_row gt_center">1,096</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">oily_fish</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    2 to 4 servings/week</td>
    ## <td headers="stat_0" class="gt_row gt_center">4,069 (17%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    More than 4 servings/week</td>
    ## <td headers="stat_0" class="gt_row gt_center">20,167 (83%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">cooked_vg</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    &lt; 2 servings/day</td>
    ## <td headers="stat_0" class="gt_row gt_center">3,266 (14%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    2 or 3 servings/day</td>
    ## <td headers="stat_0" class="gt_row gt_center">8,518 (36%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    3 or 4 servings/day</td>
    ## <td headers="stat_0" class="gt_row gt_center">6,824 (29%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    More than 4 servings/day</td>
    ## <td headers="stat_0" class="gt_row gt_center">5,147 (22%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Unknown</td>
    ## <td headers="stat_0" class="gt_row gt_center">481</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">alcohol_raw</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Daily or almost daily</td>
    ## <td headers="stat_0" class="gt_row gt_center">5,278 (22%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Never</td>
    ## <td headers="stat_0" class="gt_row gt_center">1,408 (5.8%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Once or twice a week</td>
    ## <td headers="stat_0" class="gt_row gt_center">6,209 (26%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    One to three times a month</td>
    ## <td headers="stat_0" class="gt_row gt_center">2,809 (12%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Prefer not to answer</td>
    ## <td headers="stat_0" class="gt_row gt_center">10 (&lt;0.1%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Special occasions only</td>
    ## <td headers="stat_0" class="gt_row gt_center">2,481 (10%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Three or four times a week</td>
    ## <td headers="stat_0" class="gt_row gt_center">6,041 (25%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">processed_meat</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    2 to 4 servings/week</td>
    ## <td headers="stat_0" class="gt_row gt_center">6,040 (25%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    More than 4 servings/week</td>
    ## <td headers="stat_0" class="gt_row gt_center">18,196 (75%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">alcohol</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Daily or almost daily</td>
    ## <td headers="stat_0" class="gt_row gt_center">5,278 (29%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Less than once a week</td>
    ## <td headers="stat_0" class="gt_row gt_center">5,290 (29%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Never</td>
    ## <td headers="stat_0" class="gt_row gt_center">1,408 (7.7%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Once or twice a week</td>
    ## <td headers="stat_0" class="gt_row gt_center">6,209 (34%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Prefer not to answer</td>
    ## <td headers="stat_0" class="gt_row gt_center">10 (&lt;0.1%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Unknown</td>
    ## <td headers="stat_0" class="gt_row gt_center">6,041</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">smoking</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Current</td>
    ## <td headers="stat_0" class="gt_row gt_center">1,619 (6.7%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Never</td>
    ## <td headers="stat_0" class="gt_row gt_center">14,075 (58%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Previous</td>
    ## <td headers="stat_0" class="gt_row gt_center">8,499 (35%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Unknown</td>
    ## <td headers="stat_0" class="gt_row gt_center">43</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">ethnicity</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Nonwhite</td>
    ## <td headers="stat_0" class="gt_row gt_center">828 (3.4%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    White</td>
    ## <td headers="stat_0" class="gt_row gt_center">23,334 (97%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Unknown</td>
    ## <td headers="stat_0" class="gt_row gt_center">74</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">education_level</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    A levels/AS levels or equivalent, NVQ or HND or HNC or equivalent, other professional qualifications</td>
    ## <td headers="stat_0" class="gt_row gt_center">5,816 (24%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    College or University degree</td>
    ## <td headers="stat_0" class="gt_row gt_center">9,886 (41%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    None of the above</td>
    ## <td headers="stat_0" class="gt_row gt_center">2,115 (8.8%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    O levels/GCSEs or equivalent, CSEs or equivalent</td>
    ## <td headers="stat_0" class="gt_row gt_center">6,322 (26%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Unknown</td>
    ## <td headers="stat_0" class="gt_row gt_center">97</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">diabetes</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Do not know</td>
    ## <td headers="stat_0" class="gt_row gt_center">39 (0.2%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    No</td>
    ## <td headers="stat_0" class="gt_row gt_center">764 (3.2%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Prefer not to answer</td>
    ## <td headers="stat_0" class="gt_row gt_center">1 (&lt;0.1%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Yes</td>
    ## <td headers="stat_0" class="gt_row gt_center">23,432 (97%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">BMI</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Normal (18.5 kg/m2 to &lt; 25 kg/m2)</td>
    ## <td headers="stat_0" class="gt_row gt_center">8,907 (37%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Obesity Class I, II or III (&gt; 30 kg/m2)</td>
    ## <td headers="stat_0" class="gt_row gt_center">4,930 (20%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Overweight (25 kg/m2 to &lt; 30 kg/m2)</td>
    ## <td headers="stat_0" class="gt_row gt_center">10,301 (43%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Underweight (&lt; 18.5 kg/m2)</td>
    ## <td headers="stat_0" class="gt_row gt_center">98 (0.4%)</td></tr>
    ##   </tbody>
    ##   
    ##   <tfoot class="gt_footnotes">
    ##     <tr>
    ##       <td class="gt_footnote" colspan="2"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height: 0;"><sup>1</sup></span> <span class='gt_from_md'>n (%)</span></td>
    ##     </tr>
    ##   </tfoot>
    ## </table>
    ## </div>

### MVPA Quarter 3:

``` r
# Quarter 3
summ_base_char_MVPA_quarter3 <- df_MVPA_quarter3 %>%
  tbl_summary(
    include = c(stroke, MI, sex, fresh_fruit, oily_fish, cooked_vg, alcohol_raw, 
                processed_meat, alcohol, smoking, ethnicity, education_level,  
                diabetes, BMI),
    statistic = list(all_continuous() ~ "{mean} ± {sd}")
  ) %>%
  bold_labels()

# Print the summary table
print(summ_base_char_MVPA_quarter3)
```

    ## <div id="casvjekxat" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
    ##   <style>#casvjekxat table {
    ##   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
    ##   -webkit-font-smoothing: antialiased;
    ##   -moz-osx-font-smoothing: grayscale;
    ## }
    ## 
    ## #casvjekxat thead, #casvjekxat tbody, #casvjekxat tfoot, #casvjekxat tr, #casvjekxat td, #casvjekxat th {
    ##   border-style: none;
    ## }
    ## 
    ## #casvjekxat p {
    ##   margin: 0;
    ##   padding: 0;
    ## }
    ## 
    ## #casvjekxat .gt_table {
    ##   display: table;
    ##   border-collapse: collapse;
    ##   line-height: normal;
    ##   margin-left: auto;
    ##   margin-right: auto;
    ##   color: #333333;
    ##   font-size: 16px;
    ##   font-weight: normal;
    ##   font-style: normal;
    ##   background-color: #FFFFFF;
    ##   width: auto;
    ##   border-top-style: solid;
    ##   border-top-width: 2px;
    ##   border-top-color: #A8A8A8;
    ##   border-right-style: none;
    ##   border-right-width: 2px;
    ##   border-right-color: #D3D3D3;
    ##   border-bottom-style: solid;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #A8A8A8;
    ##   border-left-style: none;
    ##   border-left-width: 2px;
    ##   border-left-color: #D3D3D3;
    ## }
    ## 
    ## #casvjekxat .gt_caption {
    ##   padding-top: 4px;
    ##   padding-bottom: 4px;
    ## }
    ## 
    ## #casvjekxat .gt_title {
    ##   color: #333333;
    ##   font-size: 125%;
    ##   font-weight: initial;
    ##   padding-top: 4px;
    ##   padding-bottom: 4px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   border-bottom-color: #FFFFFF;
    ##   border-bottom-width: 0;
    ## }
    ## 
    ## #casvjekxat .gt_subtitle {
    ##   color: #333333;
    ##   font-size: 85%;
    ##   font-weight: initial;
    ##   padding-top: 3px;
    ##   padding-bottom: 5px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   border-top-color: #FFFFFF;
    ##   border-top-width: 0;
    ## }
    ## 
    ## #casvjekxat .gt_heading {
    ##   background-color: #FFFFFF;
    ##   text-align: center;
    ##   border-bottom-color: #FFFFFF;
    ##   border-left-style: none;
    ##   border-left-width: 1px;
    ##   border-left-color: #D3D3D3;
    ##   border-right-style: none;
    ##   border-right-width: 1px;
    ##   border-right-color: #D3D3D3;
    ## }
    ## 
    ## #casvjekxat .gt_bottom_border {
    ##   border-bottom-style: solid;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ## }
    ## 
    ## #casvjekxat .gt_col_headings {
    ##   border-top-style: solid;
    ##   border-top-width: 2px;
    ##   border-top-color: #D3D3D3;
    ##   border-bottom-style: solid;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ##   border-left-style: none;
    ##   border-left-width: 1px;
    ##   border-left-color: #D3D3D3;
    ##   border-right-style: none;
    ##   border-right-width: 1px;
    ##   border-right-color: #D3D3D3;
    ## }
    ## 
    ## #casvjekxat .gt_col_heading {
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   font-size: 100%;
    ##   font-weight: normal;
    ##   text-transform: inherit;
    ##   border-left-style: none;
    ##   border-left-width: 1px;
    ##   border-left-color: #D3D3D3;
    ##   border-right-style: none;
    ##   border-right-width: 1px;
    ##   border-right-color: #D3D3D3;
    ##   vertical-align: bottom;
    ##   padding-top: 5px;
    ##   padding-bottom: 6px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   overflow-x: hidden;
    ## }
    ## 
    ## #casvjekxat .gt_column_spanner_outer {
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   font-size: 100%;
    ##   font-weight: normal;
    ##   text-transform: inherit;
    ##   padding-top: 0;
    ##   padding-bottom: 0;
    ##   padding-left: 4px;
    ##   padding-right: 4px;
    ## }
    ## 
    ## #casvjekxat .gt_column_spanner_outer:first-child {
    ##   padding-left: 0;
    ## }
    ## 
    ## #casvjekxat .gt_column_spanner_outer:last-child {
    ##   padding-right: 0;
    ## }
    ## 
    ## #casvjekxat .gt_column_spanner {
    ##   border-bottom-style: solid;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ##   vertical-align: bottom;
    ##   padding-top: 5px;
    ##   padding-bottom: 5px;
    ##   overflow-x: hidden;
    ##   display: inline-block;
    ##   width: 100%;
    ## }
    ## 
    ## #casvjekxat .gt_spanner_row {
    ##   border-bottom-style: hidden;
    ## }
    ## 
    ## #casvjekxat .gt_group_heading {
    ##   padding-top: 8px;
    ##   padding-bottom: 8px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   font-size: 100%;
    ##   font-weight: initial;
    ##   text-transform: inherit;
    ##   border-top-style: solid;
    ##   border-top-width: 2px;
    ##   border-top-color: #D3D3D3;
    ##   border-bottom-style: solid;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ##   border-left-style: none;
    ##   border-left-width: 1px;
    ##   border-left-color: #D3D3D3;
    ##   border-right-style: none;
    ##   border-right-width: 1px;
    ##   border-right-color: #D3D3D3;
    ##   vertical-align: middle;
    ##   text-align: left;
    ## }
    ## 
    ## #casvjekxat .gt_empty_group_heading {
    ##   padding: 0.5px;
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   font-size: 100%;
    ##   font-weight: initial;
    ##   border-top-style: solid;
    ##   border-top-width: 2px;
    ##   border-top-color: #D3D3D3;
    ##   border-bottom-style: solid;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ##   vertical-align: middle;
    ## }
    ## 
    ## #casvjekxat .gt_from_md > :first-child {
    ##   margin-top: 0;
    ## }
    ## 
    ## #casvjekxat .gt_from_md > :last-child {
    ##   margin-bottom: 0;
    ## }
    ## 
    ## #casvjekxat .gt_row {
    ##   padding-top: 8px;
    ##   padding-bottom: 8px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   margin: 10px;
    ##   border-top-style: solid;
    ##   border-top-width: 1px;
    ##   border-top-color: #D3D3D3;
    ##   border-left-style: none;
    ##   border-left-width: 1px;
    ##   border-left-color: #D3D3D3;
    ##   border-right-style: none;
    ##   border-right-width: 1px;
    ##   border-right-color: #D3D3D3;
    ##   vertical-align: middle;
    ##   overflow-x: hidden;
    ## }
    ## 
    ## #casvjekxat .gt_stub {
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   font-size: 100%;
    ##   font-weight: initial;
    ##   text-transform: inherit;
    ##   border-right-style: solid;
    ##   border-right-width: 2px;
    ##   border-right-color: #D3D3D3;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ## }
    ## 
    ## #casvjekxat .gt_stub_row_group {
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   font-size: 100%;
    ##   font-weight: initial;
    ##   text-transform: inherit;
    ##   border-right-style: solid;
    ##   border-right-width: 2px;
    ##   border-right-color: #D3D3D3;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   vertical-align: top;
    ## }
    ## 
    ## #casvjekxat .gt_row_group_first td {
    ##   border-top-width: 2px;
    ## }
    ## 
    ## #casvjekxat .gt_row_group_first th {
    ##   border-top-width: 2px;
    ## }
    ## 
    ## #casvjekxat .gt_summary_row {
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   text-transform: inherit;
    ##   padding-top: 8px;
    ##   padding-bottom: 8px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ## }
    ## 
    ## #casvjekxat .gt_first_summary_row {
    ##   border-top-style: solid;
    ##   border-top-color: #D3D3D3;
    ## }
    ## 
    ## #casvjekxat .gt_first_summary_row.thick {
    ##   border-top-width: 2px;
    ## }
    ## 
    ## #casvjekxat .gt_last_summary_row {
    ##   padding-top: 8px;
    ##   padding-bottom: 8px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   border-bottom-style: solid;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ## }
    ## 
    ## #casvjekxat .gt_grand_summary_row {
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   text-transform: inherit;
    ##   padding-top: 8px;
    ##   padding-bottom: 8px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ## }
    ## 
    ## #casvjekxat .gt_first_grand_summary_row {
    ##   padding-top: 8px;
    ##   padding-bottom: 8px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   border-top-style: double;
    ##   border-top-width: 6px;
    ##   border-top-color: #D3D3D3;
    ## }
    ## 
    ## #casvjekxat .gt_last_grand_summary_row_top {
    ##   padding-top: 8px;
    ##   padding-bottom: 8px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   border-bottom-style: double;
    ##   border-bottom-width: 6px;
    ##   border-bottom-color: #D3D3D3;
    ## }
    ## 
    ## #casvjekxat .gt_striped {
    ##   background-color: rgba(128, 128, 128, 0.05);
    ## }
    ## 
    ## #casvjekxat .gt_table_body {
    ##   border-top-style: solid;
    ##   border-top-width: 2px;
    ##   border-top-color: #D3D3D3;
    ##   border-bottom-style: solid;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ## }
    ## 
    ## #casvjekxat .gt_footnotes {
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   border-bottom-style: none;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ##   border-left-style: none;
    ##   border-left-width: 2px;
    ##   border-left-color: #D3D3D3;
    ##   border-right-style: none;
    ##   border-right-width: 2px;
    ##   border-right-color: #D3D3D3;
    ## }
    ## 
    ## #casvjekxat .gt_footnote {
    ##   margin: 0px;
    ##   font-size: 90%;
    ##   padding-top: 4px;
    ##   padding-bottom: 4px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ## }
    ## 
    ## #casvjekxat .gt_sourcenotes {
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   border-bottom-style: none;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ##   border-left-style: none;
    ##   border-left-width: 2px;
    ##   border-left-color: #D3D3D3;
    ##   border-right-style: none;
    ##   border-right-width: 2px;
    ##   border-right-color: #D3D3D3;
    ## }
    ## 
    ## #casvjekxat .gt_sourcenote {
    ##   font-size: 90%;
    ##   padding-top: 4px;
    ##   padding-bottom: 4px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ## }
    ## 
    ## #casvjekxat .gt_left {
    ##   text-align: left;
    ## }
    ## 
    ## #casvjekxat .gt_center {
    ##   text-align: center;
    ## }
    ## 
    ## #casvjekxat .gt_right {
    ##   text-align: right;
    ##   font-variant-numeric: tabular-nums;
    ## }
    ## 
    ## #casvjekxat .gt_font_normal {
    ##   font-weight: normal;
    ## }
    ## 
    ## #casvjekxat .gt_font_bold {
    ##   font-weight: bold;
    ## }
    ## 
    ## #casvjekxat .gt_font_italic {
    ##   font-style: italic;
    ## }
    ## 
    ## #casvjekxat .gt_super {
    ##   font-size: 65%;
    ## }
    ## 
    ## #casvjekxat .gt_footnote_marks {
    ##   font-size: 75%;
    ##   vertical-align: 0.4em;
    ##   position: initial;
    ## }
    ## 
    ## #casvjekxat .gt_asterisk {
    ##   font-size: 100%;
    ##   vertical-align: 0;
    ## }
    ## 
    ## #casvjekxat .gt_indent_1 {
    ##   text-indent: 5px;
    ## }
    ## 
    ## #casvjekxat .gt_indent_2 {
    ##   text-indent: 10px;
    ## }
    ## 
    ## #casvjekxat .gt_indent_3 {
    ##   text-indent: 15px;
    ## }
    ## 
    ## #casvjekxat .gt_indent_4 {
    ##   text-indent: 20px;
    ## }
    ## 
    ## #casvjekxat .gt_indent_5 {
    ##   text-indent: 25px;
    ## }
    ## 
    ## #casvjekxat .katex-display {
    ##   display: inline-flex !important;
    ##   margin-bottom: 0.75em !important;
    ## }
    ## 
    ## #casvjekxat div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
    ##   height: 0px !important;
    ## }
    ## </style>
    ##   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
    ##   <thead>
    ##     <tr class="gt_col_headings">
    ##       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="&lt;span class='gt_from_md'&gt;&lt;strong&gt;Characteristic&lt;/strong&gt;&lt;/span&gt;"><span class='gt_from_md'><strong>Characteristic</strong></span></th>
    ##       <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="&lt;span class='gt_from_md'&gt;&lt;strong&gt;N = 24,412&lt;/strong&gt;&lt;/span&gt;&lt;span class=&quot;gt_footnote_marks&quot; style=&quot;white-space:nowrap;font-style:italic;font-weight:normal;line-height: 0;&quot;&gt;&lt;sup&gt;1&lt;/sup&gt;&lt;/span&gt;"><span class='gt_from_md'><strong>N = 24,412</strong></span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height: 0;"><sup>1</sup></span></th>
    ##     </tr>
    ##   </thead>
    ##   <tbody class="gt_table_body">
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">stroke</td>
    ## <td headers="stat_0" class="gt_row gt_center">321 (1.3%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">MI</td>
    ## <td headers="stat_0" class="gt_row gt_center">473 (1.9%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">sex</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Man</td>
    ## <td headers="stat_0" class="gt_row gt_center">10,819 (44%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Woman</td>
    ## <td headers="stat_0" class="gt_row gt_center">13,593 (56%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">fresh_fruit</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    &lt; 2 servings/day</td>
    ## <td headers="stat_0" class="gt_row gt_center">6,228 (27%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    2 or 3 servings/day</td>
    ## <td headers="stat_0" class="gt_row gt_center">7,287 (31%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    3 or 4 servings/day</td>
    ## <td headers="stat_0" class="gt_row gt_center">5,248 (22%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    More than 4 servings/day</td>
    ## <td headers="stat_0" class="gt_row gt_center">4,724 (20%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Unknown</td>
    ## <td headers="stat_0" class="gt_row gt_center">925</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">oily_fish</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    2 to 4 servings/week</td>
    ## <td headers="stat_0" class="gt_row gt_center">4,086 (17%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    More than 4 servings/week</td>
    ## <td headers="stat_0" class="gt_row gt_center">20,326 (83%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">cooked_vg</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    &lt; 2 servings/day</td>
    ## <td headers="stat_0" class="gt_row gt_center">3,515 (15%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    2 or 3 servings/day</td>
    ## <td headers="stat_0" class="gt_row gt_center">8,666 (36%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    3 or 4 servings/day</td>
    ## <td headers="stat_0" class="gt_row gt_center">6,614 (28%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    More than 4 servings/day</td>
    ## <td headers="stat_0" class="gt_row gt_center">5,185 (22%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Unknown</td>
    ## <td headers="stat_0" class="gt_row gt_center">432</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">alcohol_raw</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Daily or almost daily</td>
    ## <td headers="stat_0" class="gt_row gt_center">5,723 (23%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Never</td>
    ## <td headers="stat_0" class="gt_row gt_center">1,170 (4.8%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Once or twice a week</td>
    ## <td headers="stat_0" class="gt_row gt_center">6,237 (26%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    One to three times a month</td>
    ## <td headers="stat_0" class="gt_row gt_center">2,542 (10%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Prefer not to answer</td>
    ## <td headers="stat_0" class="gt_row gt_center">7 (&lt;0.1%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Special occasions only</td>
    ## <td headers="stat_0" class="gt_row gt_center">1,975 (8.1%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Three or four times a week</td>
    ## <td headers="stat_0" class="gt_row gt_center">6,758 (28%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">processed_meat</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    2 to 4 servings/week</td>
    ## <td headers="stat_0" class="gt_row gt_center">6,090 (25%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    More than 4 servings/week</td>
    ## <td headers="stat_0" class="gt_row gt_center">18,322 (75%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">alcohol</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Daily or almost daily</td>
    ## <td headers="stat_0" class="gt_row gt_center">5,723 (32%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Less than once a week</td>
    ## <td headers="stat_0" class="gt_row gt_center">4,517 (26%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Never</td>
    ## <td headers="stat_0" class="gt_row gt_center">1,170 (6.6%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Once or twice a week</td>
    ## <td headers="stat_0" class="gt_row gt_center">6,237 (35%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Prefer not to answer</td>
    ## <td headers="stat_0" class="gt_row gt_center">7 (&lt;0.1%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Unknown</td>
    ## <td headers="stat_0" class="gt_row gt_center">6,758</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">smoking</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Current</td>
    ## <td headers="stat_0" class="gt_row gt_center">1,470 (6.0%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Never</td>
    ## <td headers="stat_0" class="gt_row gt_center">14,464 (59%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Previous</td>
    ## <td headers="stat_0" class="gt_row gt_center">8,420 (35%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Unknown</td>
    ## <td headers="stat_0" class="gt_row gt_center">58</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">ethnicity</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Nonwhite</td>
    ## <td headers="stat_0" class="gt_row gt_center">744 (3.1%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    White</td>
    ## <td headers="stat_0" class="gt_row gt_center">23,611 (97%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Unknown</td>
    ## <td headers="stat_0" class="gt_row gt_center">57</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">education_level</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    A levels/AS levels or equivalent, NVQ or HND or HNC or equivalent, other professional qualifications</td>
    ## <td headers="stat_0" class="gt_row gt_center">5,600 (23%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    College or University degree</td>
    ## <td headers="stat_0" class="gt_row gt_center">11,557 (47%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    None of the above</td>
    ## <td headers="stat_0" class="gt_row gt_center">1,638 (6.7%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    O levels/GCSEs or equivalent, CSEs or equivalent</td>
    ## <td headers="stat_0" class="gt_row gt_center">5,541 (23%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Unknown</td>
    ## <td headers="stat_0" class="gt_row gt_center">76</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">diabetes</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Do not know</td>
    ## <td headers="stat_0" class="gt_row gt_center">22 (&lt;0.1%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    No</td>
    ## <td headers="stat_0" class="gt_row gt_center">588 (2.4%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Prefer not to answer</td>
    ## <td headers="stat_0" class="gt_row gt_center">2 (&lt;0.1%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Yes</td>
    ## <td headers="stat_0" class="gt_row gt_center">23,800 (97%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">BMI</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Normal (18.5 kg/m2 to &lt; 25 kg/m2)</td>
    ## <td headers="stat_0" class="gt_row gt_center">10,483 (43%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Obesity Class I, II or III (&gt; 30 kg/m2)</td>
    ## <td headers="stat_0" class="gt_row gt_center">3,665 (15%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Overweight (25 kg/m2 to &lt; 30 kg/m2)</td>
    ## <td headers="stat_0" class="gt_row gt_center">10,089 (41%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Underweight (&lt; 18.5 kg/m2)</td>
    ## <td headers="stat_0" class="gt_row gt_center">175 (0.7%)</td></tr>
    ##   </tbody>
    ##   
    ##   <tfoot class="gt_footnotes">
    ##     <tr>
    ##       <td class="gt_footnote" colspan="2"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height: 0;"><sup>1</sup></span> <span class='gt_from_md'>n (%)</span></td>
    ##     </tr>
    ##   </tfoot>
    ## </table>
    ## </div>

``` r
# Quarter 4
summ_base_char_MVPA_quarter4 <- df_MVPA_quarter4 %>%
  tbl_summary(
    include = c(stroke, MI, sex, fresh_fruit, oily_fish, cooked_vg, alcohol_raw, 
                processed_meat, alcohol, smoking, ethnicity, education_level,  
                diabetes, BMI),
    statistic = list(all_continuous() ~ "{mean} ± {sd}")
  ) %>%
  bold_labels()

# Print the summary table
print(summ_base_char_MVPA_quarter4)
```

    ## <div id="amfljwurzi" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
    ##   <style>#amfljwurzi table {
    ##   font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
    ##   -webkit-font-smoothing: antialiased;
    ##   -moz-osx-font-smoothing: grayscale;
    ## }
    ## 
    ## #amfljwurzi thead, #amfljwurzi tbody, #amfljwurzi tfoot, #amfljwurzi tr, #amfljwurzi td, #amfljwurzi th {
    ##   border-style: none;
    ## }
    ## 
    ## #amfljwurzi p {
    ##   margin: 0;
    ##   padding: 0;
    ## }
    ## 
    ## #amfljwurzi .gt_table {
    ##   display: table;
    ##   border-collapse: collapse;
    ##   line-height: normal;
    ##   margin-left: auto;
    ##   margin-right: auto;
    ##   color: #333333;
    ##   font-size: 16px;
    ##   font-weight: normal;
    ##   font-style: normal;
    ##   background-color: #FFFFFF;
    ##   width: auto;
    ##   border-top-style: solid;
    ##   border-top-width: 2px;
    ##   border-top-color: #A8A8A8;
    ##   border-right-style: none;
    ##   border-right-width: 2px;
    ##   border-right-color: #D3D3D3;
    ##   border-bottom-style: solid;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #A8A8A8;
    ##   border-left-style: none;
    ##   border-left-width: 2px;
    ##   border-left-color: #D3D3D3;
    ## }
    ## 
    ## #amfljwurzi .gt_caption {
    ##   padding-top: 4px;
    ##   padding-bottom: 4px;
    ## }
    ## 
    ## #amfljwurzi .gt_title {
    ##   color: #333333;
    ##   font-size: 125%;
    ##   font-weight: initial;
    ##   padding-top: 4px;
    ##   padding-bottom: 4px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   border-bottom-color: #FFFFFF;
    ##   border-bottom-width: 0;
    ## }
    ## 
    ## #amfljwurzi .gt_subtitle {
    ##   color: #333333;
    ##   font-size: 85%;
    ##   font-weight: initial;
    ##   padding-top: 3px;
    ##   padding-bottom: 5px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   border-top-color: #FFFFFF;
    ##   border-top-width: 0;
    ## }
    ## 
    ## #amfljwurzi .gt_heading {
    ##   background-color: #FFFFFF;
    ##   text-align: center;
    ##   border-bottom-color: #FFFFFF;
    ##   border-left-style: none;
    ##   border-left-width: 1px;
    ##   border-left-color: #D3D3D3;
    ##   border-right-style: none;
    ##   border-right-width: 1px;
    ##   border-right-color: #D3D3D3;
    ## }
    ## 
    ## #amfljwurzi .gt_bottom_border {
    ##   border-bottom-style: solid;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ## }
    ## 
    ## #amfljwurzi .gt_col_headings {
    ##   border-top-style: solid;
    ##   border-top-width: 2px;
    ##   border-top-color: #D3D3D3;
    ##   border-bottom-style: solid;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ##   border-left-style: none;
    ##   border-left-width: 1px;
    ##   border-left-color: #D3D3D3;
    ##   border-right-style: none;
    ##   border-right-width: 1px;
    ##   border-right-color: #D3D3D3;
    ## }
    ## 
    ## #amfljwurzi .gt_col_heading {
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   font-size: 100%;
    ##   font-weight: normal;
    ##   text-transform: inherit;
    ##   border-left-style: none;
    ##   border-left-width: 1px;
    ##   border-left-color: #D3D3D3;
    ##   border-right-style: none;
    ##   border-right-width: 1px;
    ##   border-right-color: #D3D3D3;
    ##   vertical-align: bottom;
    ##   padding-top: 5px;
    ##   padding-bottom: 6px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   overflow-x: hidden;
    ## }
    ## 
    ## #amfljwurzi .gt_column_spanner_outer {
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   font-size: 100%;
    ##   font-weight: normal;
    ##   text-transform: inherit;
    ##   padding-top: 0;
    ##   padding-bottom: 0;
    ##   padding-left: 4px;
    ##   padding-right: 4px;
    ## }
    ## 
    ## #amfljwurzi .gt_column_spanner_outer:first-child {
    ##   padding-left: 0;
    ## }
    ## 
    ## #amfljwurzi .gt_column_spanner_outer:last-child {
    ##   padding-right: 0;
    ## }
    ## 
    ## #amfljwurzi .gt_column_spanner {
    ##   border-bottom-style: solid;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ##   vertical-align: bottom;
    ##   padding-top: 5px;
    ##   padding-bottom: 5px;
    ##   overflow-x: hidden;
    ##   display: inline-block;
    ##   width: 100%;
    ## }
    ## 
    ## #amfljwurzi .gt_spanner_row {
    ##   border-bottom-style: hidden;
    ## }
    ## 
    ## #amfljwurzi .gt_group_heading {
    ##   padding-top: 8px;
    ##   padding-bottom: 8px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   font-size: 100%;
    ##   font-weight: initial;
    ##   text-transform: inherit;
    ##   border-top-style: solid;
    ##   border-top-width: 2px;
    ##   border-top-color: #D3D3D3;
    ##   border-bottom-style: solid;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ##   border-left-style: none;
    ##   border-left-width: 1px;
    ##   border-left-color: #D3D3D3;
    ##   border-right-style: none;
    ##   border-right-width: 1px;
    ##   border-right-color: #D3D3D3;
    ##   vertical-align: middle;
    ##   text-align: left;
    ## }
    ## 
    ## #amfljwurzi .gt_empty_group_heading {
    ##   padding: 0.5px;
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   font-size: 100%;
    ##   font-weight: initial;
    ##   border-top-style: solid;
    ##   border-top-width: 2px;
    ##   border-top-color: #D3D3D3;
    ##   border-bottom-style: solid;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ##   vertical-align: middle;
    ## }
    ## 
    ## #amfljwurzi .gt_from_md > :first-child {
    ##   margin-top: 0;
    ## }
    ## 
    ## #amfljwurzi .gt_from_md > :last-child {
    ##   margin-bottom: 0;
    ## }
    ## 
    ## #amfljwurzi .gt_row {
    ##   padding-top: 8px;
    ##   padding-bottom: 8px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   margin: 10px;
    ##   border-top-style: solid;
    ##   border-top-width: 1px;
    ##   border-top-color: #D3D3D3;
    ##   border-left-style: none;
    ##   border-left-width: 1px;
    ##   border-left-color: #D3D3D3;
    ##   border-right-style: none;
    ##   border-right-width: 1px;
    ##   border-right-color: #D3D3D3;
    ##   vertical-align: middle;
    ##   overflow-x: hidden;
    ## }
    ## 
    ## #amfljwurzi .gt_stub {
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   font-size: 100%;
    ##   font-weight: initial;
    ##   text-transform: inherit;
    ##   border-right-style: solid;
    ##   border-right-width: 2px;
    ##   border-right-color: #D3D3D3;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ## }
    ## 
    ## #amfljwurzi .gt_stub_row_group {
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   font-size: 100%;
    ##   font-weight: initial;
    ##   text-transform: inherit;
    ##   border-right-style: solid;
    ##   border-right-width: 2px;
    ##   border-right-color: #D3D3D3;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   vertical-align: top;
    ## }
    ## 
    ## #amfljwurzi .gt_row_group_first td {
    ##   border-top-width: 2px;
    ## }
    ## 
    ## #amfljwurzi .gt_row_group_first th {
    ##   border-top-width: 2px;
    ## }
    ## 
    ## #amfljwurzi .gt_summary_row {
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   text-transform: inherit;
    ##   padding-top: 8px;
    ##   padding-bottom: 8px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ## }
    ## 
    ## #amfljwurzi .gt_first_summary_row {
    ##   border-top-style: solid;
    ##   border-top-color: #D3D3D3;
    ## }
    ## 
    ## #amfljwurzi .gt_first_summary_row.thick {
    ##   border-top-width: 2px;
    ## }
    ## 
    ## #amfljwurzi .gt_last_summary_row {
    ##   padding-top: 8px;
    ##   padding-bottom: 8px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   border-bottom-style: solid;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ## }
    ## 
    ## #amfljwurzi .gt_grand_summary_row {
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   text-transform: inherit;
    ##   padding-top: 8px;
    ##   padding-bottom: 8px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ## }
    ## 
    ## #amfljwurzi .gt_first_grand_summary_row {
    ##   padding-top: 8px;
    ##   padding-bottom: 8px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   border-top-style: double;
    ##   border-top-width: 6px;
    ##   border-top-color: #D3D3D3;
    ## }
    ## 
    ## #amfljwurzi .gt_last_grand_summary_row_top {
    ##   padding-top: 8px;
    ##   padding-bottom: 8px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ##   border-bottom-style: double;
    ##   border-bottom-width: 6px;
    ##   border-bottom-color: #D3D3D3;
    ## }
    ## 
    ## #amfljwurzi .gt_striped {
    ##   background-color: rgba(128, 128, 128, 0.05);
    ## }
    ## 
    ## #amfljwurzi .gt_table_body {
    ##   border-top-style: solid;
    ##   border-top-width: 2px;
    ##   border-top-color: #D3D3D3;
    ##   border-bottom-style: solid;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ## }
    ## 
    ## #amfljwurzi .gt_footnotes {
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   border-bottom-style: none;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ##   border-left-style: none;
    ##   border-left-width: 2px;
    ##   border-left-color: #D3D3D3;
    ##   border-right-style: none;
    ##   border-right-width: 2px;
    ##   border-right-color: #D3D3D3;
    ## }
    ## 
    ## #amfljwurzi .gt_footnote {
    ##   margin: 0px;
    ##   font-size: 90%;
    ##   padding-top: 4px;
    ##   padding-bottom: 4px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ## }
    ## 
    ## #amfljwurzi .gt_sourcenotes {
    ##   color: #333333;
    ##   background-color: #FFFFFF;
    ##   border-bottom-style: none;
    ##   border-bottom-width: 2px;
    ##   border-bottom-color: #D3D3D3;
    ##   border-left-style: none;
    ##   border-left-width: 2px;
    ##   border-left-color: #D3D3D3;
    ##   border-right-style: none;
    ##   border-right-width: 2px;
    ##   border-right-color: #D3D3D3;
    ## }
    ## 
    ## #amfljwurzi .gt_sourcenote {
    ##   font-size: 90%;
    ##   padding-top: 4px;
    ##   padding-bottom: 4px;
    ##   padding-left: 5px;
    ##   padding-right: 5px;
    ## }
    ## 
    ## #amfljwurzi .gt_left {
    ##   text-align: left;
    ## }
    ## 
    ## #amfljwurzi .gt_center {
    ##   text-align: center;
    ## }
    ## 
    ## #amfljwurzi .gt_right {
    ##   text-align: right;
    ##   font-variant-numeric: tabular-nums;
    ## }
    ## 
    ## #amfljwurzi .gt_font_normal {
    ##   font-weight: normal;
    ## }
    ## 
    ## #amfljwurzi .gt_font_bold {
    ##   font-weight: bold;
    ## }
    ## 
    ## #amfljwurzi .gt_font_italic {
    ##   font-style: italic;
    ## }
    ## 
    ## #amfljwurzi .gt_super {
    ##   font-size: 65%;
    ## }
    ## 
    ## #amfljwurzi .gt_footnote_marks {
    ##   font-size: 75%;
    ##   vertical-align: 0.4em;
    ##   position: initial;
    ## }
    ## 
    ## #amfljwurzi .gt_asterisk {
    ##   font-size: 100%;
    ##   vertical-align: 0;
    ## }
    ## 
    ## #amfljwurzi .gt_indent_1 {
    ##   text-indent: 5px;
    ## }
    ## 
    ## #amfljwurzi .gt_indent_2 {
    ##   text-indent: 10px;
    ## }
    ## 
    ## #amfljwurzi .gt_indent_3 {
    ##   text-indent: 15px;
    ## }
    ## 
    ## #amfljwurzi .gt_indent_4 {
    ##   text-indent: 20px;
    ## }
    ## 
    ## #amfljwurzi .gt_indent_5 {
    ##   text-indent: 25px;
    ## }
    ## 
    ## #amfljwurzi .katex-display {
    ##   display: inline-flex !important;
    ##   margin-bottom: 0.75em !important;
    ## }
    ## 
    ## #amfljwurzi div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
    ##   height: 0px !important;
    ## }
    ## </style>
    ##   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
    ##   <thead>
    ##     <tr class="gt_col_headings">
    ##       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="&lt;span class='gt_from_md'&gt;&lt;strong&gt;Characteristic&lt;/strong&gt;&lt;/span&gt;"><span class='gt_from_md'><strong>Characteristic</strong></span></th>
    ##       <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="&lt;span class='gt_from_md'&gt;&lt;strong&gt;N = 24,076&lt;/strong&gt;&lt;/span&gt;&lt;span class=&quot;gt_footnote_marks&quot; style=&quot;white-space:nowrap;font-style:italic;font-weight:normal;line-height: 0;&quot;&gt;&lt;sup&gt;1&lt;/sup&gt;&lt;/span&gt;"><span class='gt_from_md'><strong>N = 24,076</strong></span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height: 0;"><sup>1</sup></span></th>
    ##     </tr>
    ##   </thead>
    ##   <tbody class="gt_table_body">
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">stroke</td>
    ## <td headers="stat_0" class="gt_row gt_center">288 (1.2%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">MI</td>
    ## <td headers="stat_0" class="gt_row gt_center">444 (1.8%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">sex</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Man</td>
    ## <td headers="stat_0" class="gt_row gt_center">13,855 (58%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Woman</td>
    ## <td headers="stat_0" class="gt_row gt_center">10,221 (42%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">fresh_fruit</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    &lt; 2 servings/day</td>
    ## <td headers="stat_0" class="gt_row gt_center">5,820 (25%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    2 or 3 servings/day</td>
    ## <td headers="stat_0" class="gt_row gt_center">7,125 (31%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    3 or 4 servings/day</td>
    ## <td headers="stat_0" class="gt_row gt_center">5,233 (23%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    More than 4 servings/day</td>
    ## <td headers="stat_0" class="gt_row gt_center">5,059 (22%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Unknown</td>
    ## <td headers="stat_0" class="gt_row gt_center">839</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">oily_fish</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    2 to 4 servings/week</td>
    ## <td headers="stat_0" class="gt_row gt_center">4,011 (17%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    More than 4 servings/week</td>
    ## <td headers="stat_0" class="gt_row gt_center">20,065 (83%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">cooked_vg</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    &lt; 2 servings/day</td>
    ## <td headers="stat_0" class="gt_row gt_center">3,380 (14%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    2 or 3 servings/day</td>
    ## <td headers="stat_0" class="gt_row gt_center">8,325 (35%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    3 or 4 servings/day</td>
    ## <td headers="stat_0" class="gt_row gt_center">6,551 (28%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    More than 4 servings/day</td>
    ## <td headers="stat_0" class="gt_row gt_center">5,338 (23%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Unknown</td>
    ## <td headers="stat_0" class="gt_row gt_center">482</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">alcohol_raw</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Daily or almost daily</td>
    ## <td headers="stat_0" class="gt_row gt_center">6,340 (26%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Never</td>
    ## <td headers="stat_0" class="gt_row gt_center">1,039 (4.3%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Once or twice a week</td>
    ## <td headers="stat_0" class="gt_row gt_center">5,834 (24%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    One to three times a month</td>
    ## <td headers="stat_0" class="gt_row gt_center">2,102 (8.7%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Prefer not to answer</td>
    ## <td headers="stat_0" class="gt_row gt_center">9 (&lt;0.1%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Special occasions only</td>
    ## <td headers="stat_0" class="gt_row gt_center">1,571 (6.5%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Three or four times a week</td>
    ## <td headers="stat_0" class="gt_row gt_center">7,181 (30%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">processed_meat</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    2 to 4 servings/week</td>
    ## <td headers="stat_0" class="gt_row gt_center">6,195 (26%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    More than 4 servings/week</td>
    ## <td headers="stat_0" class="gt_row gt_center">17,881 (74%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">alcohol</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Daily or almost daily</td>
    ## <td headers="stat_0" class="gt_row gt_center">6,340 (38%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Less than once a week</td>
    ## <td headers="stat_0" class="gt_row gt_center">3,673 (22%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Never</td>
    ## <td headers="stat_0" class="gt_row gt_center">1,039 (6.1%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Once or twice a week</td>
    ## <td headers="stat_0" class="gt_row gt_center">5,834 (35%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Prefer not to answer</td>
    ## <td headers="stat_0" class="gt_row gt_center">9 (&lt;0.1%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Unknown</td>
    ## <td headers="stat_0" class="gt_row gt_center">7,181</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">smoking</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Current</td>
    ## <td headers="stat_0" class="gt_row gt_center">1,317 (5.5%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Never</td>
    ## <td headers="stat_0" class="gt_row gt_center">14,021 (58%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Previous</td>
    ## <td headers="stat_0" class="gt_row gt_center">8,689 (36%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Unknown</td>
    ## <td headers="stat_0" class="gt_row gt_center">49</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">ethnicity</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Nonwhite</td>
    ## <td headers="stat_0" class="gt_row gt_center">596 (2.5%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    White</td>
    ## <td headers="stat_0" class="gt_row gt_center">23,391 (98%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Unknown</td>
    ## <td headers="stat_0" class="gt_row gt_center">89</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">education_level</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    A levels/AS levels or equivalent, NVQ or HND or HNC or equivalent, other professional qualifications</td>
    ## <td headers="stat_0" class="gt_row gt_center">5,283 (22%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    College or University degree</td>
    ## <td headers="stat_0" class="gt_row gt_center">12,497 (52%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    None of the above</td>
    ## <td headers="stat_0" class="gt_row gt_center">1,406 (5.9%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    O levels/GCSEs or equivalent, CSEs or equivalent</td>
    ## <td headers="stat_0" class="gt_row gt_center">4,814 (20%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Unknown</td>
    ## <td headers="stat_0" class="gt_row gt_center">76</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">diabetes</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Do not know</td>
    ## <td headers="stat_0" class="gt_row gt_center">28 (0.1%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    No</td>
    ## <td headers="stat_0" class="gt_row gt_center">469 (1.9%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Prefer not to answer</td>
    ## <td headers="stat_0" class="gt_row gt_center">4 (&lt;0.1%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Yes</td>
    ## <td headers="stat_0" class="gt_row gt_center">23,575 (98%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left" style="font-weight: bold;">BMI</td>
    ## <td headers="stat_0" class="gt_row gt_center"><br /></td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Normal (18.5 kg/m2 to &lt; 25 kg/m2)</td>
    ## <td headers="stat_0" class="gt_row gt_center">11,469 (48%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Obesity Class I, II or III (&gt; 30 kg/m2)</td>
    ## <td headers="stat_0" class="gt_row gt_center">2,574 (11%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Overweight (25 kg/m2 to &lt; 30 kg/m2)</td>
    ## <td headers="stat_0" class="gt_row gt_center">9,855 (41%)</td></tr>
    ##     <tr><td headers="label" class="gt_row gt_left">    Underweight (&lt; 18.5 kg/m2)</td>
    ## <td headers="stat_0" class="gt_row gt_center">178 (0.7%)</td></tr>
    ##   </tbody>
    ##   
    ##   <tfoot class="gt_footnotes">
    ##     <tr>
    ##       <td class="gt_footnote" colspan="2"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height: 0;"><sup>1</sup></span> <span class='gt_from_md'>n (%)</span></td>
    ##     </tr>
    ##   </tfoot>
    ## </table>
    ## </div>

############################################################## 

########## 

Kaplan_Meier: - 2 groups: PA1 and PA2 or Stroke and MI? - d_stroke == 1;
d_MI == 1 - end_of_fu = censoring time

``` r
#km_stroke <- coxph(
  #Surv(fu_time, stroke) ~ overall_activity_quarters + age_entry_years + sex + ethnicity + tdi_quarters + education_level + smoking + alcohol,
  #data = full_df_incl_PA1_PA2)
```
