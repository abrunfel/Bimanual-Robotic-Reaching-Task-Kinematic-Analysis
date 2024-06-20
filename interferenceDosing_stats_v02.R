library(tidyverse)
library(ez)
library(reshape2)


# Left Hand Kinematics ----------------------------------------------------
# Bin trials in "blocks"
nr = nrow(lhData)
blockSize = 10
block = rep(1:floor(nr/blockSize), each = blockSize) # Bins in blocks of "blockSize" trials (need to change lhData_mbg$block also!: See end of this chuck)
lhKinematics_stats = aggregate(lhData, by = list(lhData$group, block, lhData$subjectID), FUN = mean, na.rm = TRUE)
lhKinematics_stats$group = lhKinematics_stats$Group.1
lhKinematics_stats$subjectID = lhKinematics_stats$Group.3
lhKinematics_stats$trial = rep(1:(220/blockSize),numGroup)
lhKinematics_stats = subset(lhKinematics_stats, select = -c(Group.1, Group.2, Group.3, target_theta))
colnames(lhKinematics_stats)[3] <- "block"
lhKinematics_stats$block = as.factor(lhKinematics_stats$block)

setwd("/Volumes/mnl/Data/Adaptation/interference_dosing/R output files") # Mac
#setwd("Z:\\Data\\Adaptation\\interference_dosing\\R output files") #PC
save(lhKinematics_stats, file = "lhKinematics_stats.Rdata")
#

# Right Hand Kinematics ---------------------------------------------------
nr = nrow(rhData)
blockSize = 10
block = rep(1:floor(nr/blockSize), each = blockSize) # Bins in blocks of "blockSize" trials (need to change rhData_mbg$block also!: See end of this chuck)
rhKinematics_stats = aggregate(rhData, by = list(rhData$group, block, rhData$subjectID), FUN = mean, na.rm = TRUE)
rhKinematics_stats$group = rhKinematics_stats$Group.1
rhKinematics_stats$subjectID = rhKinematics_stats$Group.3
rhKinematics_stats$trial = rep(1:(220/blockSize),numGroup)
rhKinematics_stats = subset(rhKinematics_stats, select = -c(Group.1, Group.2, Group.3, target_theta))
colnames(rhKinematics_stats)[3] <- "block"
rhKinematics_stats$block = as.factor(rhKinematics_stats$block)

setwd("/Volumes/mnl/Data/Adaptation/interference_dosing/R output files") # Mac
#setwd("Z:\\Data\\Adaptation\\interference_dosing\\R output files") #PC
save(rhKinematics_stats, file = "rhKinematics_stats.Rdata")
#


# Hand Difference Data ----------------------------------------------------
# Bin trials in "blocks" using median (only for timing data!)
nr = nrow(hand.diff)
blockSize = 10
block = rep(rep(seq(1:22), each = 10),numSub) # Bins in blocks of "blockSize" trials (using median)
hand.diff$block = as.factor(block)
hand_diff_stats = hand.diff %>% select(-c(trial)) %>% group_by(group, subjectID, block) %>% summarise_each(funs(median(.,na.rm = TRUE)))

setwd("/Volumes/mnl/Data/Adaptation/interference_dosing/R output files") # Mac
#setwd("Z:\\Data\\Adaptation\\interference_dosing\\R output files") #PC
save(hand_diff_stats, file = "hand_diff_stats.Rdata")
#

# Force Channel -----------------------------------------------------------
# Run data import chunk of "interferenceDosing_lh_FC_v*.Rmd before running this!!

# Kin Baseline
kb = subset(fcData.fs, trial %in% 7:12)
kb$group = as.numeric(kb$group)
kb = kb %>% group_by(subID) %>%  summarise_all(funs(mean(.,na.rm = TRUE))) %>% select(-c(wrongTrial, trial))
kb$group = as.factor(kb$group)
kb = as.data.frame(kb)
kb = melt(kb, id.vars = c("subID", "group"))
colnames(kb) = c('subID', 'group', 'sample', 'kbmean')

# Break data into blocks of 6 trials (first, middle, last), then take mean by subject and convert to long format
bk1 = subset(fcData.fs, trial %in% 13:18)
bk1$group = as.numeric(bk1$group)
bk1 = bk1 %>% group_by(subID) %>%  summarise_all(funs(mean(.,na.rm = TRUE))) %>% select(-c(wrongTrial, trial))
bk1$group = as.factor(bk1$group)
bk1 = as.data.frame(bk1)
bk1 = melt(bk1, id.vars = c("subID", "group"))
colnames(bk1) = c('subID', 'group', 'sample', 'bk1mean')

bk2 = subset(fcData.fs, trial %in% 24:29)
bk2$group = as.numeric(bk2$group)
bk2 = bk2 %>% group_by(subID) %>%  summarise_all(funs(mean(.,na.rm = TRUE))) %>% select(-c(wrongTrial, trial))
bk2$group = as.factor(bk2$group)
bk2 = as.data.frame(bk2)
bk2 = melt(bk2, id.vars = c("subID", "group"))
colnames(bk2) = c('subID', 'group', 'sample', 'bk2mean')

bk3 = subset(fcData.fs, trial %in% 35:40)
bk3$group = as.numeric(bk3$group)
bk3 = bk3 %>% group_by(subID) %>%  summarise_all(funs(mean(.,na.rm = TRUE))) %>% select(-c(wrongTrial, trial))
bk3$group = as.factor(bk3$group)
bk3 = as.data.frame(bk3)
bk3 = melt(bk3, id.vars = c("subID", "group"))
colnames(bk3) = c('subID', 'group', 'sample', 'bk3mean')

# Use this for individual block RM AVNOAs
FC_stats = cbind(kb, bk1[,4], bk2[,4], bk3[,4])
colnames(FC_stats) = c('subID', 'group', 'sample','kbmean', 'bk1mean', 'bk2mean', 'bk3mean')


# Use this for 3-way ANOVA (Group x Sample x Phase)
temp = subset(FC_stats, FC_stats$sample %in% c(50,950))
FC_3way = melt(temp, id.vars = c("subID", "sample", "group"))
colnames(FC_3way) = c("subID", "sample", "group", "phase", "value")


setwd("/Volumes/mnl/Data/Adaptation/interference_dosing/R output files") # Mac
#setwd("Z:\\Data\\Adaptation\\interference_dosing\\R output files") #PC
save(FC_stats, file = "FC_stats.Rdata")
save(FC_3way, file = "FC_3way.Rdata")
#
