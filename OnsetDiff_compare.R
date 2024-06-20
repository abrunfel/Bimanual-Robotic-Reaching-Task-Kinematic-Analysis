#library(ggplot2)
#library(gridExtra)
#library(ez)



# Onset Difference Boxplots -----------------------------------------------
# WARNING: In order to run this section properly, you must load in the correct experiment's workspace and change the working directory to the respective experiment's output folder!!!

pdf("Onset Diff baselines EXP1.pdf", width = 12, height = 5.12, useDingbats = FALSE)
vb.onset.diff = ggplot(data = subset(hand.diff, hand.diff$trial %in% c(1:20)), aes(x = subjectID, y = lag, color = group))+
  geom_boxplot()+
  coord_cartesian(ylim = c(-500,1000))+
  ggtitle("Visual Baseline")

kb.onset.diff = ggplot(data = subset(hand.diff, hand.diff$trial %in% c(21:40)), aes(x = subjectID, y = lag, color = group))+
  geom_boxplot()+
  coord_cartesian(ylim = c(-500,1000))+
  ggtitle("Kinesthetic Baseline")

grid.arrange(vb.onset.diff, kb.onset.diff)
dev.off()
#


# 2x2 ANOVA ---------------------------------------------------------------

# Load in experiment 1 stats, then add a phase factor and experiment factor
load("/Volumes/mnl/Data/Adaptation/interference_dosing/R output files/hand_diff_stats.Rdata")
hand.diff.stats.exp1 = hand_diff_stats
rm(hand_diff_stats)
numSub1 = nrow(hand.diff.stats.exp1)/22
hand.diff.stats.exp1$phase = as.factor(rep(c(1,1,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,4,4,4,4), numSub1))
hand.diff.stats.exp1$experiment = as.factor(rep(c(1),nrow(hand.diff.stats.exp1)))

# Load in experiment 2 stats, then add a phase factor and experiment factor
load("/Volumes/mnl/Data/Adaptation/interference_dosing/IFdosing_exp2/Routput/hand_diff_stats.Rdata")
hand.diff.stats.exp2 = hand_diff_stats
rm(hand_diff_stats)
numSub2 = nrow(hand.diff.stats.exp2)/22
hand.diff.stats.exp2$phase = as.factor(rep(c(1,1,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,4,4,4,4), numSub2))
hand.diff.stats.exp2$experiment = as.factor(rep(c(2),nrow(hand.diff.stats.exp2)))

# Concat the two data.frames
hand.diff.stats.both = rbind(hand.diff.stats.exp1, hand.diff.stats.exp2)
# Run the 2 (Phase) x 2 (Experiment) ANOVA
ezANOVA(data = subset(hand.diff.stats.both, hand.diff.stats.both$phase %in% c(1,2)), dv = lag, wid = subjectID, between = experiment, within = phase)

#
