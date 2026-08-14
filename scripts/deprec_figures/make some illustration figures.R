

library("data.table")
library("ggplot2")
library("patchwork")
library("lubridate")
library("scales")
library("ggpattern")

m1 <- rnorm(n = 50, mean = 7, sd = 1.2)
m2 <- rnorm(n = 50, mean = 15, sd = .9)

hist(m1)
hist(m2)

# Simple:
dt <- data.table(mean = c(mean(m1), mean(m2)), sd = c(sd(m1), sd(m2)),
                 group = c("Control", "Treatment"))
# dt <- 
ggplot(data = dt,
       aes(x = group, y = mean, fill = group))+
  geom_col()+
  geom_errorbar(aes(ymin = mean-sd, ymax = mean+sd),
                width = .5)+
  scale_fill_manual(NULL,
                    values = c("Control" = "dodgerblue2",
                               "Treatment" = "indianred"))+  
  xlab(NULL)+
  ylab("Outcome")+
  theme_bw()+
  theme(panel.grid = element_blank(),
        legend.position = "none")
ggsave("figures/illustration_icons/simple mean.png", width = 3, height = 3)

# Also saving this for illustration in meta cascades:
ggplot(data = dt,
       aes(x = group, y = mean, fill = group))+
  geom_col()+
  geom_errorbar(aes(ymin = mean-sd, ymax = mean+sd),
                width = .5)+
  scale_fill_manual(NULL,
                    values = c("Control" = "indianred",
                               "Treatment" = "forestgreen"))+  
  scale_x_discrete(labels = c("Control" = "Predator absent",
                              "Treatment" = "Predator present"))+
  xlab(NULL)+
  ylab("Plant biomass")+
  theme_bw()+
  theme(panel.grid = element_blank(),
        legend.position = "none")
ggsave("figures/illustration_icons/simple mean trophic cascades.png", width = 3, height = 3)



#
dt <- data.table(group = c(rep("Control", length(m1)),
                           rep("Treatment", length(m2))),
                 Outcome = c(m1, m2))

ggplot(data = dt,
       aes(x = group, y = Outcome, fill = group))+
  geom_boxplot()+
  scale_fill_manual(NULL,
                    values = c("Control" = "dodgerblue2",
                               "Treatment" = "indianred"))+  
  xlab(NULL)+
  ylab("Outcome")+
  theme_bw()+
  theme(panel.grid = element_blank(),
        legend.position = "none")
ggsave("figures/illustration_icons/boxplot.png", width = 3, height = 3)


# Difference:
diff <- m1 - m2

ggplot()+
  geom_boxplot(aes(y = diff, x = "Difference"),
               fill = "purple")+
  ylab("Control - Treatment")+
  xlab(NULL)+
  theme_bw()+
  theme(panel.grid = element_blank(),
        axis.text.x = element_blank())

ggsave("figures/illustration_icons/difference.png", width = 3, height = 3)


#
hist1 <- ggplot()+
  geom_histogram(aes(x = m1), bins = 20,
                 fill = "dodgerblue2", alpha = .75)+
  theme_bw()+
  xlab("Outcome")+
  ylab("Count")+
  theme(panel.grid = element_blank())

hist2 <- ggplot()+
  geom_histogram(aes(x = m2), bins = 20,
                 fill = "indianred", alpha = .75)+
  theme_bw()+
  xlab("Outcome")+
  ylab("Count")+
  theme(panel.grid = element_blank())

ggsave("figures/illustration_icons/hist1.png", hist1, width = 3, height = 3)
ggsave("figures/illustration_icons/hist2.png", hist2, width = 3, height = 3)

violin.dt <- data.table(response = c(m1, m2),
                        type = c(rep("group 1", length(m1)),
                                 rep("group 2", length(m2))))

violin <- ggplot()+
  geom_violin(data = violin.dt, 
              aes(x = type, y = response, fill = type), 
              alpha = .75, color = "transparent")+
  theme_bw()+
  scale_fill_manual(NULL,
                    values = c("group 1" = "dodgerblue2",
                               "group 2" = "indianred"),
                    labels = c("group 1" = "Control",
                               "group 2" = "Treatment"))+  
  xlab(NULL)+
  scale_x_discrete(labels = c("group 1" = "Control",
                               "group 2" = "Treatment"))+  
  ylab("Outcome")+
  theme(panel.grid = element_blank(),
        legend.position = "none")
violin
ggsave("figures/illustration_icons/violin.png", width = 3, height = 3)



dens <- ggplot()+
  geom_density(data = violin.dt, 
              aes(x = response, fill = type), 
              alpha = .55, color = "transparent")+
  theme_bw()+
  scale_fill_manual(NULL,
                    values = c("group 1" = "dodgerblue2",
                               "group 2" = "indianred"),
                    labels = c("group 1" = "Control",
                               "group 2" = "Treatment"))+  
  xlab("Outcome")+
  scale_x_discrete(labels = c("group 1" = "Control",
                              "group 2" = "Treatment"))+  
  ylab("Density")+
  theme(panel.grid = element_blank(),
        legend.position = "none")
dens
ggsave("figures/illustration_icons/dens.png", width = 3, height = 3)


#
bc <- rnorm(n = 50, mean = 7, sd = 1.2)
bi <- rnorm(n = 50, mean = 8.2, sd = .9)

ac <- rnorm(n = 50, mean = 7.3, sd = 1)
ai <- rnorm(n = 50, mean = 13.8, sd = .8)

baci <- data.table(m_bc = mean(bc),
                   sd_bc = sd(bc),
                   m_bi = mean(bi),
                   sd_bi = sd(bi),
                   m_ac = mean(ac),
                   sd_ac = sd(ac),
                   m_ai = mean(ai),
                   sd_ai = sd(ai))
baci$id <- "blah"
baci <- melt(baci,
             id.vars = "id")
baci[, c("type", "trt") := tstrsplit(variable, "_")]
baci <- dcast(baci,
              trt + id ~ type, value.var = "value")
baci

baci[, before_after := ifelse(grepl("b", trt), "before", "after")]
baci[, control_impact := ifelse(grepl("c", trt), "control", "impact")]
baci$before_after <- factor(baci$before_after, levels = c("before", "after"))
baci

ggplot()+
  geom_col_pattern(data = baci, 
                   aes(x = control_impact, y = m, fill = control_impact,
                       pattern = before_after),
           position = position_dodge(.9))+
  geom_errorbar(data = baci, aes(ymin = m-sd, ymax = m+sd, 
                                 x = control_impact,
                                 group = before_after),
                position = position_dodge(.9),
                width = .5)+
  geom_label(data = baci, aes(x = control_impact, y = 4,
                             label = before_after,
                             group = before_after),
             position = position_dodge(.9),
             size = 3)+
  xlab(NULL)+
  ylab("Outcome")+
  ggtitle("Non-problematic BACI")+
  scale_pattern_manual("Before/after treatment", values = c("before" = "none",
                                                             "after" = "stripe"))+
  scale_fill_manual(values = c("control" = "dodgerblue2",
                               "impact" = "indianred"),
                    labels = c("control" = "Control",
                               "impact" = "Treatment"))+
  scale_x_discrete(labels = c("control" = "Control",
                              "impact" = "Treatment"))+
  theme_bw()+
  theme(panel.grid = element_blank(),
        legend.position = "none")
ggsave("figures/illustration_icons/baci.png", width = 3, height = 3)

#
baci2 <- copy(baci)
baci2

baci2[trt == "bc", m := 3]
# baci2[trt == "ac", m := m * 2]
#
ggplot()+
  geom_col_pattern(data = baci2, 
                   aes(x = control_impact, y = m, fill = control_impact,
                       pattern = before_after),
                   position = position_dodge())+
  geom_errorbar(data = baci2, aes(ymin = m-sd, ymax = m+sd, 
                                 x = control_impact,
                                 group = before_after),
                position = position_dodge(1),
                width = .5)+
  geom_label(data = baci, aes(x = control_impact, y = 1,
                              label = before_after,
                              group = before_after),
             position = position_dodge(.9),
             size = 3)+
  xlab(NULL)+
  ylab("Outcome")+
  ggtitle("Problematic BACI")+
  scale_pattern_manual("Before/after treatment", values = c("before" = "none",
                                                            "after" = "stripe"))+
  scale_fill_manual(values = c("control" = "dodgerblue2",
                               "impact" = "indianred"),
                    labels = c("control" = "Control",
                               "impact" = "Treatment"))+
  scale_x_discrete(labels = c("control" = "Control",
                              "impact" = "Treatment"))+
  theme_bw()+
  theme(panel.grid = element_blank(),
        legend.position = "none")
ggsave("figures/illustration_icons/problem baci.png", width = 3, height = 3)

# >>> Each group is a difference ------------------------------------------

# Each group IS a difference between treatment and control
# This case is common with trophic cascades. Exclosure vs control in areas with HIGH risk or LOW risk

# Just use the same data as baci:
ggplot()+
  geom_col_pattern(data = baci, aes(x = before_after, y = m, 
                                    fill = before_after,
                                    pattern = control_impact,
                                    group = control_impact),
           position = position_dodge())+
  geom_errorbar(data = baci, aes(ymin = m-sd, ymax = m+sd, 
                                 x = before_after,
                                 group = control_impact),
                position = position_dodge(1),
                width = .5)+
  xlab(NULL)+
  ylab("Outcome")+
  scale_pattern_manual(name = "Experimental\ntreatment", values = c("control" = "none",
                                                                    "impact" = "stripe"),
                       labels = c("control" = "Sub-control",
                                  "impact" = "Sub-treatment"))+
  scale_fill_manual("Group", values = c("before" = "dodgerblue2",
                               "after" = "indianred"),
                    labels = c("before" = "Control",
                               "after" = "Treatment"))+
  scale_x_discrete(labels = c("before" = "Control",
                              "after" = "Treatment"))+
  theme_bw()+
  theme(panel.grid = element_blank(),
        legend.position = "right")

ggsave("figures/illustration_icons/experimental differences.png", width = 3.5, height = 3)


# >>> Percent change ------------------------------------------------------
baci.wide <- dcast(baci,
                   control_impact ~ before_after,
                   value.var = c("m", "sd"))
baci.wide[, percent_change := (m_after - m_before) / m_before * 100]

# Customize this:
baci.wide[control_impact == "control", percent_change := -15]
baci.wide[control_impact == "impact", percent_change := 35]
baci.wide[, percent_sd := 5]

ggplot(data = baci.wide, aes(x = control_impact,
                             y = percent_change,
                             fill = control_impact,
                             ymin = percent_change-percent_sd,
                             ymax = percent_change+percent_sd))+
  geom_hline(yintercept = 0)+
  geom_col()+
  geom_errorbar(width = .5)+
  ylab("Percent change from before to after")+
  xlab(NULL)+
  scale_x_discrete(labels = c("control" = "Control",
                              "impact" = "Treatment"))+
  scale_fill_manual("Group", values = c("control" = "dodgerblue2",
                                        "impact" = "indianred"),
                    labels = c("control" = "Control",
                               "impact" = "Treatment"))+
  theme_bw()+
  theme(panel.grid = element_blank(),
        legend.position = "right")

ggsave("figures/illustration_icons/percent change.png", width = 3.5, height = 3)

# >>> Interaction between two variables of interest -----------------------

x1 <- seq(1:10)
x2 <- seq(1:10)

y1 <- x1 * 1 + rnorm(n = 10, mean = 0, sd = 1.5)
plot(x1, y1)

y2 <- 3 * 2 + rnorm(n = 10, mean = 1, sd = .5)
plot(x1, y2)

dt <- data.table(x1 = x1, x2 = x2, y1 = y1, y2 = y2)

p1 <- ggplot(data = dt, aes(x = x1, y = y1))+
  geom_path(color = "indianred")+
  geom_point(size = 3, fill = "indianred", shape = 21)+
  ggtitle("Control group")+
  ylab("Outcome")+
  xlab("Continuous variable of interest")+
  theme_bw()+
  theme(panel.grid = element_blank(),
        legend.position = "none")
p1

p2 <- ggplot(data = dt, aes(x = x2, y = y2))+
  geom_path(color = "dodgerblue2")+
  geom_point(size = 3, fill = "dodgerblue2", shape = 21)+
  ggtitle("Treatment group")+
  ylab("Outcome")+
  xlab("Continuous variable of interest")+
  theme_bw()+
  theme(panel.grid = element_blank(),
        legend.position = "none")
p2

p1 + 
  p2 + 
  plot_layout(ncol = 2)
ggsave("figures/illustration_icons/interaction.png", width = 6, height = 3)




# >>> Discrete interaction ------------------------------------------------

# Just use the same data as baci:
baci3 <- copy(baci)
baci3[, control_impact := ifelse(control_impact == "control", "Factor 2\ncontrol", "Factor 2\ntreatment")]

ggplot()+
  geom_col_pattern(data = baci3, aes(x = before_after, y = m, 
                                    fill = before_after,
                                    pattern = control_impact,
                                    group = control_impact),
                   position = position_dodge())+
  geom_errorbar(data = baci3, aes(ymin = m-sd, ymax = m+sd, 
                                 x = before_after,
                                 group = control_impact),
                position = position_dodge(1),
                width = .5)+
  geom_label(data = baci3, aes(x = before_after, y = 1,
                               label = control_impact,
                               group = control_impact),
             position = position_dodge(.9),
             size = 3)+
  xlab(NULL)+
  ylab("Outcome")+
  ggtitle("Crossed design")+
  scale_pattern_manual(name = "Experimental\ntreatment", values = c("Factor 2\ncontrol" = "none",
                                                                    "Factor 2\ntreatment" = "stripe"))+
  scale_fill_manual("Group", values = c("before" = "dodgerblue2",
                                        "after" = "indianred"),
                    labels = c("before" = "Factor 1 control",
                               "after" = "Factor 1 treatment"))+
  scale_x_discrete(labels = c("before" = "Factor 1 control",
                              "after" = "Factor 1 treatment"))+
  guides(fill = "none", pattern = "none")+
  theme_bw()+
  theme(panel.grid = element_blank(),
        legend.position = "right")

ggsave("figures/illustration_icons/crossed design.png", width = 3.5, height = 3)


# ZCOR --------------------------------------------------------------------
x <- m1
y <- m1 * 1.3 + rnorm(n = 50, mean = 0, sd = 1)

zcor <- data.table(x = x, y = y, sd = abs(rnorm(n = 50, mean = 0, sd = .5)))

ggplot(data = zcor, aes(x = x, y = y))+
  geom_point(size = 3, shape = 21, fill = "grey50")+
  geom_segment(x = zcor[50, ]$x, y = 0, yend = zcor[50, ]$y)+
  geom_segment(x = 0, xend = zcor[50, ]$x, y = zcor[50, ]$y)+
  geom_smooth(method = "lm", color = "black")+
  xlab("x")+
  ylab("y")+
  theme_bw()+
  theme(panel.grid = element_blank(),
        legend.position = "none")
ggsave("figures/illustration_icons/zcor_simple.png", width = 3, height = 3)

ggplot(data = zcor, aes(x = x, y = y))+
  geom_point(size = 3, shape = 21, fill = "grey50")+
  geom_errorbar(width = .25, aes(ymin = y-sd, ymax = y+sd))+
  geom_smooth(method = "lm", color = "black")+
  xlab("x")+
  ylab("y")+
  theme_bw()+
  theme(panel.grid = element_blank(),
        legend.position = "none")
ggsave("figures/illustration_icons/zcor_error.png", width = 3, height = 3)

zcor[, x_sd := rnorm(50, mean = 0, sd = .25)]

ggplot(data = zcor[sample(25)], aes(x = x, y = y))+
  geom_point(size = 3, shape = 21, fill = "grey50")+
  geom_errorbar(width = .25, aes(ymin = y-sd, ymax = y+sd))+
  geom_errorbarh(aes(xmin = x-x_sd, xmax = x+x_sd), height = .25)+
  geom_smooth(method = "lm", color = "black")+
  xlab("x")+
  ylab("y")+
  theme_bw()+
  theme(panel.grid = element_blank(),
        legend.position = "none")
ggsave("figures/illustration_icons/zcor_2error.png", width = 3, height = 3)




# >>> Mismatched time series ----------------------------------------------
x1 <- seq(from = 1995, to = 2005, by = 1)
x2 <- seq(from = 1995, to = 2005, by = .25)
x2

length(x1)
y1 <- seq(from = 5, to = 15, by = 1)#m1[sample(11)] * 1.3 + rnorm(n = 11, mean = 0, sd = 1)
y1 <- y1[1:11] 
y1 <- y1 + rnorm(n = 11, mean = 0, sd = .5)
plot(x1, y1)

#
y2 <- seq(from = 100, to = 110, by = .1)
y2 <- y2[1:length(x2)]
y2 <- y2 + rnorm(n=length(x2), mean = 0, sd = .5)
plot(x2, y2)

# slopes2 <- rnorm()
dt1 <- data.table(x1 = x1,
                  y1 = y1)
dt2 <- data.table(x2 = x2,
                  y2 = rev(y2))

p1 <- ggplot(data = dt1, aes(x = x1, y = y1))+
  geom_path()+
  geom_point(size = 3)+
  xlab("Year")+
  ylab("Predictor variable of interest")+
  theme_bw()+
  scale_x_continuous(breaks = seq(from = min(dt1$x1), to=max(dt1$x1), by = 2),
                     labels = as.integer(seq(from = min(dt1$x1), to=max(dt1$x1), by = 2)))+
  theme(panel.grid = element_blank(),
        legend.position = "none")
p1


#
dt2[, date := date_decimal(x2) |> as.Date()]
p2 <- ggplot(data = dt2, aes(x = date, y = y2))+
  geom_path()+
  geom_point(size = 3)+
  xlab("Year")+
  ylab("Response variable of interest")+
  theme_bw()+
  # scale_x_continuous(breaks = seq(from = min(dt1$x1), to=max(dt1$x1), by = 2))+
  theme(panel.grid = element_blank(),
        legend.position = "none")
p2

p1 + p2
ggsave("figures/illustration_icons/zcor_mismatched_time.png", width = 6, height = 3)



# >>> Matrices ------------------------------------------------------------

library("gt")

dat1 <- CJ(agent1 = c("Sally", "James", "Bart", "Sergeant Brown"), 
           agent2 = c("Sally", "James", "Bart", "Sergeant Brown"))
dat1[, val1 := rnorm(n = nrow(dat1), 
                     mean = .8, sd = .1)]
dat1[, val2 := rnorm(n = nrow(dat1), 
                     mean = 1.5, sd = .3)]

dat1[agent1 == agent2, val1 := NA]
dat1[agent1 == agent2, val2 := NA]

mat1 <- dcast(data = dat1,
              agent1 ~ agent2, value.var = "val1")
mat1

mat2 <- dcast(data = dat1,
              agent1 ~ agent2, value.var = "val2")
mat2

gt(mat1)
gt(mat2)


# lnOR --------------------------------------------------------------------

# >>> Survivorship --------------------------------------------------------

x <- seq(1:15)
a <- rweibull(n = 15, shape = 2, scale = 4)
plot(x, rev(sort(a)))

b <- rweibull(n = 15, shape = 2, scale = 4)
plot(x, rev(sort(b)))


a <- rev(sort(a))
b <- rev(sort(b))

a <- a - min(a)
a <- a/max(a)
a


b <- b - min(b)
b <- b/max(b)
b


ggplot()+
  geom_path(aes(x = x, y = a),
            color = "indianred",
            linewidth = 2)+
  geom_path(aes(x = x, y = b),
            color = "dodgerblue",
            linewidth = 2)+
  geom_point(aes(x = x, y = a),
            fill = "indianred",
            shape = 21,
            size = 3)+
  geom_point(aes(x = x, y = b),
            fill = "dodgerblue",
            shape = 21,
            size = 3)+
  ylab("Survivorship (proportion alive)")+
  xlab("Time")+
  theme_bw()+
  theme(panel.grid = element_blank(),
        legend.position = "none")
ggsave("figures/illustration_icons/OR_survivorship.png", width = 3, height = 3)


# # Survivorship
# p <- rexp(100, rate = 0.5) 
# p
# 
# group1 <- 100 * p
# group1
# 
# group2 <- 100 * seq(from = 0, to = 0.8, by = 0.05)
# 
# ggplot()+
#   geom_path(aes(x = seq(1:17), y = group1))


# >>> Simple proportion ---------------------------------------------------


# Simple:
dt <- data.table(mean = c(mean(m1), mean(m2)), sd = c(sd(m1), sd(m2)),
                 group = c("Control", "Treatment"))
# dt <- 
ggplot(data = dt,
       aes(x = group, y = mean, fill = group))+
  geom_col()+
  scale_fill_manual(NULL,
                    values = c("Control" = "dodgerblue2",
                               "Treatment" = "indianred"),
                    labels = c("Control" = "Control (n = 100 individuals)",
                               "Treatment" = "Treatment (n = 200 individuals)"))+  
  xlab(NULL)+
  ylab("Mortality rate (% of population)")+
  theme_bw()+
  theme(panel.grid = element_blank(),
        legend.position = "none")
ggsave("figures/illustration_icons/proportion simple.png", width = 3, height = 3)

