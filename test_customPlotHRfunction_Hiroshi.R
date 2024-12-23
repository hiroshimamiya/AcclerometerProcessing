

rm(list = ls())

### Library 
library(Greg)
library(dplyr)
library(survival)
library(readr)
library(ggplot2)
library(splines)
library(splines2)
library(rms)
library(Greg)
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
library(splines)
library(splines2)
library(survminer)



# Test data image with "dt" data frame 
#load("survival_analysis/2_test.RData")

source("plotHR_hiroshiFunction.R")



#dt <- dt[complete.cases(dt), ]
#dim(dt)
#f <- coxph(Surv(fu_time, MI) ~ rcs(mvpa3, 4) + Sex + Age + Race +  deprivation_index + Education +  hh_income + Smoking + Alcohol + pro_meat + fresh_fruit + cooked_vg + oily_fish + non_oily_fish +red_meat + greenspace + water_res + natural_env , data = dt)
f <- fit_pa4_stroke_sa1

plotHR(fit_pa4_stroke_sa1,  
       term = 1, 
       xlab = "MVMVPA duration (minutes/week)", 
       adj = 0, 
       xlim = c(0, 1500), 
       ylim = c(0.2, 4), 
       plot.bty = "U", 
       cex.axis = 1, 
       cex.lab = 1.2)
fig_label("A", pos = "topleft", cex = 1.5, x_adj = -0.1, y_adj = -0.03)



### RUN -------------------------
plotHR2(f,  
       term = 1, 
       rescaleHR = T, 
       xlab = "MVMVPA duration (minutes/week)", 
       adj = 0, 
       xlim = c(0, 1500), 
       ylim = c(0.1, 1.3), 
       plot.bty = "U", 
       cex.axis = 1, 
       cex.lab = 1.2)
fig_label("A", pos = "topleft", cex = 1.5, x_adj = -0.1, y_adj = -0.03)


















models=f
term = 1
se = TRUE
cntrst = ifelse(inherits(models, "rms") ||
                  inherits(models[[1]], "rms"), TRUE, FALSE)
polygon_ci = TRUE
rug = "density"
xlab = ""
ylab = "Hazard Ratio"
main = NULL
xlim = c(-1, 2000)
ylim = ylim = c(0.3,3)
col.term = "#08519C"
col.se = "#DEEBF7"
col.dens = grey(.9)
lwd.term = 3
lty.term = 1
lwd.se = lwd.term
lty.se = lty.term
x.ticks = NULL
y.ticks = NULL
ylog = TRUE
cex = 1
y_axis_side = 2
plot.bty = "n"
axes = TRUE
alpha = .05


















x <- list(
  models = models,
  multi_data = multi_data,
  main = main,
  boundaries = boundaries,
  se = se,
  confint_style = confint_style,
  xlab = xlab,
  ylab = ylab,
  ylog = ylog,
  xlim = xlim,
  ylim = ylim,
  plot.bty = plot.bty,
  col.dens = col.dens,
  quantiles = quantiles,
  rug = rug,
  xvalues_4_density = xvalues_4_density,
  ticks = list(
    x = x.ticks,
    y = y.ticks,
    y_axis_side = y_axis_side
  ),
  axes = axes
)





plot(
  y = x$boundaries$y,
  x = x$boundaries$x,
  xlab = x$xlab,
  ylab = x$ylab,
  main = x$main,
  xaxs = "i",
  yaxs = "i",
  type = "n",
  axes = FALSE)
































































