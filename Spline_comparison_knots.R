# Comparison of the number of spline knots - 3 vs 4 

fit_pa1_stroke <- coxph(Surv(fu_time, Stroke) ~ rcs(mvpa1, 4) + Sex + Age + Race +  deprivation_index + Education +  hh_income + Smoking + Alcohol + pro_meat + fresh_fruit + cooked_vg + oily_fish + non_oily_fish + red_meat , data = dt)
fit_pa1_stroke_df4 <- coxph(Surv(fu_time, Stroke) ~ rcs(mvpa1, 3) + Sex + Age + Race +  deprivation_index + Education +  hh_income + Smoking + Alcohol + pro_meat + fresh_fruit + cooked_vg + oily_fish + non_oily_fish + red_meat , data = dt)

fit_pa1_MI <- coxph(Surv(fu_time, MI) ~ rcs(mvpa1, 3) + Sex + Age + Race +  deprivation_index + Education +  hh_income + Smoking + Alcohol + pro_meat + fresh_fruit + cooked_vg + oily_fish + non_oily_fish +red_meat , data = dt)
fit_pa1_MI_df4 <- coxph(Surv(fu_time, MI) ~ rcs(mvpa1, 4) + Sex + Age + Race +  deprivation_index + Education +  hh_income + Smoking + Alcohol + pro_meat + fresh_fruit + cooked_vg + oily_fish + non_oily_fish +red_meat , data = dt)




#Difference in AIC is very minor 
AIC(fit_pa1_stroke)
AIC(fit_pa1_stroke_df4)

AIC(fit_pa1_MI)
AIC(fit_pa1_MI_df4)


# Plot for PA1
par(mfrow=c(2,2))
plotHR2(fit_pa1_stroke,
        rescaleHR = T,
        term = 1,
        #xlab = "MVPA (minutes/week)",
        ylab = "Hazard ratio (stroke)",
        adj = 0,
        xlim = c(0, 1500),
        ylim = c(0.1, 1.3),
        plot.bty = "U",
        cex.axis = 1,
        cex.lab = 1.2,
        lwd.term = 1.5,
        lty.term = 1,
        col.se = "lightgrey",
        col.dens = "grey"
)
fig_label("A", pos = "topleft", cex = 1.5, x_adj = -0.1, y_adj = -0.03)
plotHR2(fit_pa1_stroke_df4,
        rescaleHR = T,
        term = 1,
        #xlab = "MVPA (minutes/week)",
        ylab = "Hazard ratio (stroke)",
        adj = 0,
        xlim = c(0, 1500),
        ylim = c(0.1, 1.3),
        plot.bty = "U",
        cex.axis = 1,
        cex.lab = 1.2,
        lwd.term = 1.5,
        lty.term = 1,
        col.se = "lightgrey",
        col.dens = "grey"
)
fig_label("A_df4", pos = "topleft", cex = 1.5, x_adj = -0.1, y_adj = -0.03)
plotHR2(fit_pa1_MI,
        rescaleHR = T,
        term = 1,
        ylab = "Hazard ratio (MI)",
        #xlab = "MVPA (minutes/week)",
        xlim = c(0, 1500),
        ylim = c(0.1, 1.3),
        plot.bty = "U",
        cex.axis = 1,
        cex.lab = 1.2,
        lwd.term = 1.5,
        lty.term = 1,
        col.se = "lightgrey",
        col.dens = "grey"
)
fig_label("B", pos = "topleft", cex = 1.5, x_adj = -0.1, y_adj = -0.03)
plotHR2(fit_pa1_MI_df4,
        rescaleHR = T,
        term = 1,
        ylab = "Hazard ratio (MI)",
        #xlab = "MVPA (minutes/week)",
        xlim = c(0, 1500),
        ylim = c(0.1, 1.3),
        plot.bty = "U",
        cex.axis = 1,
        cex.lab = 1.2,
        lwd.term = 1.5,
        lty.term = 1,
        col.se = "lightgrey",
        col.dens = "grey"
)
fig_label("B_df4", pos = "topleft", cex = 1.5, x_adj = -0.1, y_adj = -0.03)









#PA4 
fit_pa4_stroke_sa1 <- coxph(Surv(fu_time, Stroke) ~ rcs(mvpa4, 3) + Sex + Age + Race +  deprivation_index + Education +  hh_income + Smoking + Alcohol + pro_meat + fresh_fruit + cooked_vg + oily_fish + red_meat +non_oily_fish , data = dt2)
fit_pa4_stroke_sa1_df4 <- coxph(Surv(fu_time, Stroke) ~ rcs(mvpa4, 4) + Sex + Age + Race +  deprivation_index + Education +  hh_income + Smoking + Alcohol + pro_meat + fresh_fruit + cooked_vg + oily_fish + red_meat +non_oily_fish , data = dt2)

fit_pa4_mi_sa1 <- coxph(Surv(fu_time, MI) ~ rcs(mvpa4, 3) + Sex + Age + Race +  deprivation_index + Education +  hh_income + Smoking + Alcohol + pro_meat + fresh_fruit + cooked_vg + oily_fish + red_meat +non_oily_fish , data = dt2)
fit_pa4_mi_sa1_df4 <- coxph(Surv(fu_time, MI) ~ rcs(mvpa4, 4) + Sex + Age + Race +  deprivation_index + Education +  hh_income + Smoking + Alcohol + pro_meat + fresh_fruit + cooked_vg + oily_fish + red_meat +non_oily_fish , data = dt2)






# PA4 
AIC(fit_pa4_stroke_sa1_df4)
AIC(fit_pa4_stroke_sa1)

AIC(fit_pa4_mi_sa1_df4)
AIC(fit_pa4_mi_sa1)

par(family = "Arial", ps = 12, cex = 1, mfrow = c(2, 2), oma = c(0, 0, 2, 0), mar = c(4, 4, 2, 1))
# PA4
## Stroke
plotHR2(fit_pa4_stroke_sa1,
        term = 1,
        rescaleHR = T, 
        xlab = "MVPA (minutes/week)", 
        ylab = "Hazard ratio (Stroke)", 
        xlim = c(0, 800), 
        ylim = c(0.1, 2), 
        plot.bty = "U", 
        cex.axis = 1, 
        cex.lab = 1.2, 
        lwd.term = 1.5,
        lty.term = 1,
        col.se = "lightgrey", 
        col.dens = "grey")
fig_label("A", pos = "topleft", cex = 1.5, x_adj = -0.1, y_adj = -0.03)

plotHR2(fit_pa4_stroke_sa1_df4,
        term = 1,
        rescaleHR = T, 
        xlab = "MVPA (minutes/week)", 
        ylab = "Hazard ratio (Stroke)", 
        xlim = c(0, 800), 
        ylim = c(0.1, 2), 
        plot.bty = "U", 
        cex.axis = 1, 
        cex.lab = 1.2, 
        lwd.term = 1.5,
        lty.term = 1,
        col.se = "lightgrey", 
        col.dens = "grey")
fig_label("A_df4", pos = "topleft", cex = 1.5, x_adj = -0.1, y_adj = -0.03)


## MI
plotHR2(fit_pa4_mi_sa1,
        term = 1,
        rescaleHR = T, 
        xlab = "MVPA (minutes/week)", 
        ylab = "Hazard ratio (MI)", 
        xlim = c(0, 800), 
        ylim = c(0.1, 2), 
        plot.bty = "U", 
        cex.axis = 1, 
        cex.lab = 1.2, 
        lwd.term = 1.5,
        lty.term = 1,
        col.se = "lightgrey", 
        col.dens = "grey")
fig_label("B", pos = "topleft", cex = 1.5, x_adj = -0.1, y_adj = -0.03)

plotHR2(fit_pa4_mi_sa1_df4,
        term = 1,
        rescaleHR = T, 
        xlab = "MVPA (minutes/week)", 
        ylab = "Hazard ratio (MI)", 
        xlim = c(0, 800), 
        ylim = c(0.1, 2), 
        plot.bty = "U", 
        cex.axis = 1, 
        cex.lab = 1.2, 
        lwd.term = 1.5,
        lty.term = 1,
        col.se = "lightgrey", 
        col.dens = "grey")
fig_label("B_df4", pos = "topleft", cex = 1.5, x_adj = -0.1, y_adj = -0.03)

dev.off()







### Female ------------
fit_pa1_stroke_sa3 <- coxph(Surv(fu_time, Stroke) ~ rcs(mvpa1, 3) + Age + Race +  deprivation_index + Education +  hh_income + Smoking + Alcohol + pro_meat + fresh_fruit + cooked_vg + oily_fish + non_oily_fish +red_meat , data = dt[dt$Sex == "Female", ])
fit_pa1_stroke_sa3_df4 <- coxph(Surv(fu_time, Stroke) ~ rcs(mvpa1, 4) + Age + Race +  deprivation_index + Education +  hh_income + Smoking + Alcohol + pro_meat + fresh_fruit + cooked_vg + oily_fish + non_oily_fish +red_meat , data = dt[dt$Sex == "Female", ])

fit_pa1_MI_sa3 <- coxph(Surv(fu_time, MI) ~ rcs(mvpa1, 3) + Age + Race +  deprivation_index + Education +  hh_income + Smoking + Alcohol + pro_meat + fresh_fruit + cooked_vg + oily_fish + non_oily_fish +red_meat , data = dt[dt$Sex == "Female", ])
fit_pa1_MI_sa3_df4 <- coxph(Surv(fu_time, MI) ~ rcs(mvpa1, 4) + Age + Race +  deprivation_index + Education +  hh_income + Smoking + Alcohol + pro_meat + fresh_fruit + cooked_vg + oily_fish + non_oily_fish +red_meat , data = dt[dt$Sex == "Female", ])

fit_pa1_stroke_sa3_m <- coxph(Surv(fu_time, Stroke) ~ rcs(mvpa1, 3) + Age + Race +  deprivation_index + Education +  hh_income + Smoking + Alcohol + pro_meat + fresh_fruit + cooked_vg + oily_fish + non_oily_fish +red_meat , data = dt[dt$Sex == "Male", ])
fit_pa1_stroke_sa3_m_df4 <- coxph(Surv(fu_time, Stroke) ~ rcs(mvpa1, 4) + Age + Race +  deprivation_index + Education +  hh_income + Smoking + Alcohol + pro_meat + fresh_fruit + cooked_vg + oily_fish + non_oily_fish +red_meat , data = dt[dt$Sex == "Male", ])

fit_pa1_MI_sa3_m <- coxph(Surv(fu_time, MI) ~ rcs(mvpa1, 3) + Age + Race +  deprivation_index + Education +  hh_income + Smoking + Alcohol + pro_meat + fresh_fruit + cooked_vg + oily_fish + non_oily_fish +red_meat  , data = dt[dt$Sex == "Male", ])
fit_pa1_MI_sa3_m_df4 <- coxph(Surv(fu_time, MI) ~ rcs(mvpa1, 4) + Age + Race +  deprivation_index + Education +  hh_income + Smoking + Alcohol + pro_meat + fresh_fruit + cooked_vg + oily_fish + non_oily_fish +red_meat  , data = dt[dt$Sex == "Male", ])

AIC(fit_pa1_stroke_sa3)
AIC(fit_pa1_stroke_sa3_df4)

AIC(fit_pa1_MI_sa3)
AIC(fit_pa1_MI_sa3_df4)

AIC(fit_pa1_stroke_sa3_m)
AIC(fit_pa1_stroke_sa3_m_df4)

AIC(fit_pa1_MI_sa3_m)
AIC(fit_pa1_MI_sa3_m_df4)





par(family = "Arial", ps = 12, cex = 1, mfrow = c(2, 2), oma = c(0, 0, 2, 0), mar = c(4, 4, 2, 1))
## Stroke - Female
plotHR2(fit_pa1_stroke_sa3,
        term = 1,
        rescaleHR = T, 
        xlab = "MVPA (minutes/week)", 
        ylab = "Hazard ratio (Stroke)", 
        xlim = c(0, 1500), 
        ylim = c(0.1, 1.3), 
        plot.bty = "U", 
        cex.axis = 1, 
        cex.lab = 1.2, 
        lwd.term = 1.5,
        lty.term = 1,
        col.se = "lightgreen", 
        col.dens = "grey")
fig_label("A", pos = "topleft", cex = 1.5, x_adj = -0.1, y_adj = -0.03)

## Stroke - Female
plotHR2(fit_pa1_stroke_sa3_df4,
        term = 1,
        rescaleHR = T, 
        xlab = "MVPA (minutes/week)", 
        ylab = "Hazard ratio (Stroke)", 
        xlim = c(0, 1500), 
        ylim = c(0.1, 1.3), 
        plot.bty = "U", 
        cex.axis = 1, 
        cex.lab = 1.2, 
        lwd.term = 1.5,
        lty.term = 1,
        col.se = "lightgreen", 
        col.dens = "grey")
fig_label("A_df4", pos = "topleft", cex = 1.5, x_adj = -0.1, y_adj = -0.03)




## MI - Female
plotHR2(fit_pa1_MI_sa3,
        term = 1,
        rescaleHR = T, 
        xlab = "MVPA (minutes/week)", 
        ylab = "Hazard ratio (MI)", 
        xlim = c(0, 1500), 
        ylim = c(0.1, 1.3), 
        plot.bty = "U", 
        cex.axis = 1, 
        cex.lab = 1.2, 
        lwd.term = 1.5,
        lty.term = 1,
        col.se = "lightgreen", 
        col.dens = "grey")
fig_label("B", pos = "topleft", cex = 1.5, x_adj = -0.1, y_adj = -0.03)

plotHR2(fit_pa1_MI_sa3_df4,
        term = 1,
        rescaleHR = T, 
        xlab = "MVPA (minutes/week)", 
        ylab = "Hazard ratio (MI)", 
        xlim = c(0, 1500), 
        ylim = c(0.1, 1.3), 
        plot.bty = "U", 
        cex.axis = 1, 
        cex.lab = 1.2, 
        lwd.term = 1.5,
        lty.term = 1,
        col.se = "lightgreen", 
        col.dens = "grey")
fig_label("B", pos = "topleft", cex = 1.5, x_adj = -0.1, y_adj = -0.03)

dev.off()
