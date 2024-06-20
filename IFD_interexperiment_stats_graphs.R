### Interference Dosing experiment comparisons and graphs
# library(tidyverse)
# library(ez)
# library(plotrix)
# library(afex) # Need this package to deal with unbalanced design (see Stats section below)
# library(emmeans)

# Data wrangling for plotting ---------------------------------------------
be.lh.kinematics.plot = be.lh.kinematics.stats %>% filter(block == 18) %>% select(-c(subjectID, block)) %>% group_by(group, experiment) %>% summarise_each(funs(mean, std.error))
be.fc.plot = be.fc.stats %>% filter(sample == 950) %>% select(-c(subID, sample)) %>% group_by(group, experiment) %>% summarise_each(funs(mean, std.error)) %>% mutate(experiment = recode(experiment, '1' = "Adaptive", '2' = "Non-adaptive"))
be.fc.stats = be.fc.stats %>% mutate(experiment = recode(experiment, '1' = "Adaptive", '2' = "Non-adaptive"))
##
ashjgjjjj
# Graphs ------------------------------------------------------------------
# Non-FC DVs
# IDE
pos = position_dodge(1)
ggplot(data = be.lh.kinematics.plot, aes(x = experiment, y = ide.bc_mean, fill = group))+
  geom_bar(stat = "identity", position = pos)+
  geom_errorbar(aes(ymin = ide.bc_mean - ide.bc_std.error, ymax = ide.bc_mean + ide.bc_std.error), position = pos, width = 0.2)+
  labs(x = "Experiment", y = "IDE (deg)")+
  theme_bw()+
  guides(fill = guide_legend(title = "Group"))
ggsave("ide.interexperiment.jpeg", plot = last_plot(), device = "jpeg", path = "/Volumes/mnl/Data/Adaptation/interference_dosing/R output files", width = 7.5, height = 4.5, units = "in")

# EPX
pos = position_dodge(1)
ggplot(data = be.lh.kinematics.plot, aes(x = experiment, y = EP_X.bc_mean, fill = group))+
  geom_bar(stat = "identity", position = pos)+
  geom_errorbar(aes(ymin = EP_X.bc_mean - EP_X.bc_std.error, ymax = EP_X.bc_mean + EP_X.bc_std.error), position = pos, width = 0.2)+
  labs(x = "Experiment", y = "EPX (cm)")+
  theme_bw()+
  guides(fill = guide_legend(title = "Group"))
ggsave("epx.interexperiment.jpeg", plot = last_plot(), device = "jpeg", path = "/Volumes/mnl/Data/Adaptation/interference_dosing/R output files", width = 7.5, height = 4.5, units = "in")

# LFP
pos = position_dodge(1)
ggplot(data = be.lh.kinematics.plot, aes(x = experiment, y = LFvp.bc_mean, fill = group))+
  geom_bar(stat = "identity", position = pos)+
  geom_errorbar(aes(ymin = LFvp.bc_mean - LFvp.bc_std.error, ymax = LFvp.bc_mean + LFvp.bc_std.error), position = pos, width = 0.2)+
  labs(x = "Experiment", y = "LFP (N)")+
  theme_bw()+
  guides(fill = guide_legend(title = "Group"))
ggsave("lfp.interexperiment.jpeg", plot = last_plot(), device = "jpeg", path = "/Volumes/mnl/Data/Adaptation/interference_dosing/R output files", width = 7.5, height = 4.5, units = "in")

# LFO
pos = position_dodge(1)
ggplot(data = be.lh.kinematics.plot, aes(x = experiment, y = LFoff.bc_mean, fill = group))+
  geom_bar(stat = "identity", position = pos)+
  geom_errorbar(aes(ymin = LFoff.bc_mean - LFoff.bc_std.error, ymax = LFoff.bc_mean + LFoff.bc_std.error), position = pos, width = 0.2)+
  labs(x = "Experiment", y = "LFO (N)")+
  theme_bw()+
  guides(fill = guide_legend(title = "Group"))
ggsave("lfo.interexperiment.jpeg", plot = last_plot(), device = "jpeg", path = "/Volumes/mnl/Data/Adaptation/interference_dosing/R output files", width = 7.5, height = 4.5, units = "in")

# Force Channel
pos = position_dodge(1)
ggplot(data = be.fc.plot, aes(x = experiment, y = bk3mean_mean, fill = group))+
  geom_bar(stat = "identity", position = pos)+
  geom_errorbar(aes(ymin = bk3mean_mean - bk3mean_std.error, ymax = bk3mean_mean + bk3mean_std.error), position = pos, width = 0.2)+
  labs(x = "Experiment", y = "Lateral Force (N)")+
  theme_bw()+
  guides(fill = guide_legend(title = "Group"))
ggsave("fc.interexperiment.pdf", plot = last_plot(), device = "pdf", path = "/Volumes/mnl/Data/Adaptation/interference_dosing/R output files", width = 7.5, height = 4.5, units = "in")
##

# Force Channel Box and Whisker (Neuroscience resubmission 2 - November 2020)
pos = position_dodge(1)
ggplot(data = subset(be.fc.stats, sample == 950), aes(x = experiment, y = bk3mean, fill = group))+
  geom_boxplot(position = pos)+
  geom_point(position = pos, alpha = 1)+
  labs(x = "Experiment", y = "Lateral Force (N)")+
  theme_bw()+
  guides(fill = guide_legend(title = "Group"))
# ggsave("fc.interexperiment.boxplot.pdf", plot = last_plot(), device = "pdf", path = "/Volumes/mnl/Data/Adaptation/interference_dosing/R output files", width = 7.5, height = 4.5, units = "in") # Mac
ggsave("fc.interexperiment.boxplot.pdf", plot = last_plot(), device = "pdf", path = "Z:\\Data\\Adaptation\\interference_dosing\\R output files", width = 7.5, height = 4.5, units = "in")
ggsave("fc.interexperiment.boxplot.eps", plot = last_plot(), device = "eps", path = "Z:\\Data\\Adaptation\\interference_dosing\\R output files", width = 7.5, height = 4.5, units = "in")


# Stats -------------------------------------------------------------------
# WARNING: There are uneven sample sizes between the two experiments. Consider using 'afex' package

#ezANOVA(subset(be.rh.kinematics.stats, block %in% c(18)), dv = ide.bc, between = c(group, experiment), wid = subjectID, detailed = TRUE) # doing this for rh doesn't make much sense as there is no adaptation in the second experiment
#ezANOVA(subset(be.lh.kinematics.stats, block %in% c(18)), dv = LFoff.bc, between = c(group, experiment), wid = subjectID, detailed = TRUE) # Change the dv as needed
#ezANOVA(subset(be.fc.stats, sample %in% c(950)), dv = bk3mean, between = c(group, experiment), wid = subID, detailed = TRUE) # Change block (bk*mean) as needed, but you should ONLY use block 3, the last block, as it is the timepoint most similar between the experiments
##

# Stats using afex --------------------------------------------------------
# Check out these link to use 'afex'

# https://cran.r-project.org/web/packages/afex/vignettes/afex_anova_example.html#post-hoc-contrasts-and-plotting
# https://ademos.people.uic.edu/Chapter21.html
# https://github.com/mattansb/ANOVA-and-Contrasts-in-R/blob/master/demo_anova.md
# https://cran.r-project.org/web/packages/emmeans/vignettes/interactions.html

# Run for all non-FC DVs
fit.nonFC = aov_ez("subjectID", "LFoff.bc", subset(be.lh.kinematics.stats, block %in% c(18)), between = c("group", "experiment"))
knitr::kable(nice(fit.nonFC)) # pretty print that bad boy
ref.nonFC = emmeans(fit.nonFC, ~group*experiment) # find estimated marginal means for Group x Experiment interaction. ONLY USE IF THERE IS AN INTERACTION
pairs(ref.nonFC)
#contrast(ref, "pairwise", adjust = "tukey") Same result because of design

# Run for FC data
fit.fc = aov_ez("subID", "bk3mean", subset(be.fc.stats, sample %in% c(950)), between = c("group", "experiment"))
knitr::kable(nice(fit.fc)) # pretty print that bad boy
ref.fc = emmeans(fit.fc, ~group*experiment) # find estimated marginal means for Group x Experiment interaction. ONLY USE IF THERE IS AN INTERACTION
pairs(ref.fc)
##

