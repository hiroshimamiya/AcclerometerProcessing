# Script to simulate time-to event and pwer analysis in our UKBB data 
#Refresh environment 
rm(list= ls())
library(dplyr)
library(survival)
library(data.table)
library(readr)
library(dvmisc)
library(gtsummary)
library(gt)
library(kableExtra)
library(broom.helpers)
library(flextable)
library(officer)
library(ggplot2)
library(coxed)
library(parallel)




dt <- readRDS("./prepped_dt.rds")
dt$MVPA_2 <- dt$MVPA_min_PA2 /20
dt$MVPA_1 <- dt$`MVPA min/week`/ 20






f_cov <- "Sex + Age + Race + `Deprivation index` + Education + `Household Income` + Smoking + Alcohol + `Processed meat` + `Fresh fruit` + `Cooked vegetables` + `Oily fish` + `Non-oily fish` + `Type II Diabetes` + `Body Mass Index`"

f_cov_noMediator <- "Sex + Age + Race + `Deprivation index` + Education + `Household Income` + Smoking + Alcohol + `Processed meat` + `Fresh fruit` + `Cooked vegetables` + `Oily fish` + `Non-oily fish`"

f_stroke <-   "Surv(`Follow_up time`,`Myocardial Infarction`)"

f_MI <- "Surv(`Follow_up time`,`Stroke`)"






fitDf1 <- coxph(as.formula(paste(f_stroke, " ~" ,  "MVPA_1 + ",  f_cov)), data = dt)
tb1<- tbl_regression(fitDf1, exponentiate = TRUE)
coefEst <- fitDf1$coefficients


fitDf2 <- coxph(as.formula(paste(f_stroke, " ~" ,  "MVPA_2 + ",  f_cov)), data = dt)
tb2<- tbl_regression(fitDf2, exponentiate = TRUE)


sim <- FALSE
if(sim == TRUE){
  started.at=proc.time()
  s1 <- sim.survdata(
    T = 150,
    X=data.frame(dt$MVPA_1), 
    num.data.frames = 200, 
    #beta = coefEst, 
    beta = 0.01
  ) 
  cat("Finished in",timetaken(started.at),"\n")
  
  saveRDS(s1, "sim/simDataHR_large_002.rds")
  
  
  started.at=proc.time()
  s1 <- sim.survdata(
    T = 150,
    X=data.frame(dt$MVPA_1), 
    num.data.frames = 500, 
    #beta = coefEst, 
    beta = -0.01
  ) 
  cat("Finished in",timetaken(started.at),"\n")
  
  saveRDS(s1, "sim/simDataHR001_large.rds")
}


ind <- list()
ind[[1]] <- dt$Sex == "Female"
ind[[2]] <- dt$`Deprivation index`  == "Quarter 4"
ind[[3]] <- dt$Education  == "O levels/GCSEs or equivalent, CSEs or equivalent" | dt$Education  == "None of the above" 
ind[[4]] <- dt$`Household Income`  == "Less than 18,000" | dt$`Household Income`  == "18,000 to 30,999" 






fSurv <- function(s, index){
  fsim <- list()
  d <- s$data[index[[1]], ]
  fi <- coxph(Surv(y,failed) ~ dt.MVPA_1, data = d)
  fsim[[1]] <-data.frame(fi$coefficients, confint(fi))
  
  d <- s$data[index[[2]], ]
  fi <- coxph(Surv(y,failed) ~ dt.MVPA_1, data = d)
  fsim[[2]] <-data.frame(fi$coefficients, confint(fi))
  
  d <- s$data[index[[3]], ]
  fi <- coxph(Surv(y,failed) ~ dt.MVPA_1, data = d)
  fsim[[3]] <-data.frame(fi$coefficients, confint(fi))
  
  d <- s$data[index[[4]], ]
  fi <- coxph(Surv(y,failed) ~ dt.MVPA_1, data = d)
  fsim[[4]] <-data.frame(fi$coefficients, confint(fi))

  return(fsim)
}

funcGetRange <- function(x, indStrata, lower = TRUE){
  if(lower){
    lower = x[[indStrata]]["X2.5.."]
  }else{
    upper = x[[indStrata]]["X97.5.."]
  }
}



#https://rpubs.com/uky994/838620
# Generate fit to all sim data 
fits <- mclapply(sData,FUN = fSurv, mc.cores = 10, ind)


indicatorStrata = 1 # strata 
rangeSimEst <- cbind(
  lapply(fits, funcGetRange,  indStrata = indicatorStrata, lower = TRUE) %>% unlist, 
  lapply(fits, funcGetRange,  indStrata = indicatorStrata, lower = FALSE) %>% unlist
)

rangeSimEst[, 2] %>% max
rangeSimEst[, 2] %>% min




indicatorStrata = 2 # strata 
rangeSimEst <- cbind(
  lapply(fits, funcGetRange,  indStrata = indicatorStrata, lower = TRUE) %>% unlist, 
  lapply(fits, funcGetRange,  indStrata = indicatorStrata, lower = FALSE) %>% unlist
)

rangeSimEst[, 2] %>% max
rangeSimEst[, 2] %>% min


indicatorStrata = 3 # strata 
rangeSimEst <- cbind(
  lapply(fits, funcGetRange,  indStrata = indicatorStrata, lower = TRUE) %>% unlist, 
  lapply(fits, funcGetRange,  indStrata = indicatorStrata, lower = FALSE) %>% unlist
)

rangeSimEst[, 2] %>% max
rangeSimEst[, 2] %>% min


indicatorStrata = 4 # strata 
rangeSimEst <- cbind(
  lapply(fits, funcGetRange,  indStrata = indicatorStrata, lower = TRUE) %>% unlist, 
  lapply(fits, funcGetRange,  indStrata = indicatorStrata, lower = FALSE) %>% unlist
)

rangeSimEst[, 2] %>% max
rangeSimEst[, 2] %>% min


