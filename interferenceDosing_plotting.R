block_ex = subset(lhData_mbg, lhData_mbg$phase==3)$block
group_ex = subset(lhData_mbg, lhData_mbg$phase==3)$group

block_pe = subset(lhData_mbg, lhData_mbg$phase==4)$block
group_pe = subset(lhData_mbg, lhData_mbg$phase==4)$group


# ide exposure and post, both hands ---------------------------------------------------------------------
siz = 3 # Used to scale the size of the data points
pdf("ide_bh.pdf", width = 8.32, height = 5.12, useDingbats = FALSE)
ggplot()+
  geom_point(data = subset(lhData_mbg, lhData_mbg$phase==3), aes(x = block, y = ide.bc, color = group_ex), size = siz)+
  geom_point(data = subset(lhData_mbg, lhData_mbg$phase==4), aes(x = block, y = ide.bc, color = group_pe), size = siz)+
  geom_point(data = subset(rhData_mbg, rhData_mbg$phase==3), aes(x = block, y = ide.bc, color = group_ex), shape=1, size = siz, stroke = 1)+
  geom_point(data = subset(rhData_mbg, rhData_mbg$phase==4), aes(x = block, y = ide.bc, color = group_pe), shape=1, size = siz, stroke = 1)+
  labs(y = "IDE (deg)")+
  theme_bw()+
  theme(axis.text.y = element_text(size = 16),
        axis.text.x = element_text(size = 12),
        axis.title.y = element_text(size = 20),
        axis.title.x = element_text(size = 20),
        legend.title = element_blank())+
  scale_color_discrete(labels = c("0 N/m", "30 N/m", "60 N/m"))+
  geom_vline(xintercept = c(18.5), linetype = "dotted")
dev.off()
#


# ide exposure only, left hand only ---------------------------------------
pdf("ide.bc.pdf", width = 8.32, height = 5.12, useDingbats = FALSE)
pd = position_dodge(width = 0.4)
block_ex = subset(lhData_MandSEMbg, lhData_MandSEMbg$phase==3)$block
group_ex = subset(lhData_MandSEMbg, lhData_MandSEMbg$phase==3)$group
ggplot(data = subset(lhData_MandSEMbg, lhData_MandSEMbg$phase==3), aes(x = block, y = ide.bc))+
  geom_point(aes(color = group_ex), position = pd, size = 3)+
  geom_errorbar(data = subset(lhData_MandSEMbg, lhData_MandSEMbg$phase==3), aes(x = block, ymin = ide.bc-ide.bc_sem, ymax = ide.bc+ide.bc_sem, color = group),
                position = pd, width = 0)+
  geom_line(aes(color = group_ex), position = pd, size = 1)+
  scale_y_continuous(limits = c(-1,7))+
  labs(y = "IDE (deg)")+
  theme_bw()+
  theme(axis.text.y = element_text(size = 16),
        axis.text.x = element_text(size = 12),
        axis.title.y = element_text(size = 20),
        axis.title.x = element_text(size = 20),
        legend.title = element_blank())+
  scale_color_discrete(labels = c("0 N/m", "30 N/m", "60 N/m"))+
  geom_vline(xintercept = c(5,12,18), linetype = "dotted")+
  scale_x_continuous(name = "block", breaks = c(5,12,18))
dev.off()

# epx ---------------------------------------------------------------------
pdf("epx.bc.pdf", width = 8.32, height = 5.12, useDingbats = FALSE)
pd = position_dodge(width = 0.4)
block_ex = subset(lhData_mbg, lhData_mbg$phase==3)$block
group_ex = subset(lhData_mbg, lhData_mbg$phase==3)$group
ggplot(data = subset(lhData_MandSEMbg, lhData_MandSEMbg$phase==3), aes(x = block, y = EP_X.bc))+
  geom_point(aes(color = group_ex), position = pd, size = 3)+
  geom_errorbar(data = subset(lhData_MandSEMbg, lhData_MandSEMbg$phase==3), aes(x = block, ymin = EP_X.bc-EP_X.bc_sem, ymax = EP_X.bc+EP_X.bc_sem, color = group),
                position = pd, width = 0)+
  geom_line(aes(color = group_ex), position = pd, size = 1)+
  scale_y_continuous(limits = c(0,1))+
  labs(y = "EPX (cm)")+
  theme_bw()+
  theme(axis.text.y = element_text(size = 16),
        axis.text.x = element_text(size = 12),
        axis.title.y = element_text(size = 20),
        axis.title.x = element_text(size = 20),
        legend.title = element_blank())+
  scale_color_discrete(labels = c("0 N/m", "30 N/m", "60 N/m"))+
  geom_vline(xintercept = c(5,12,18), linetype = "dotted")+
  scale_x_continuous(name = "block", breaks = c(5,12,18))
dev.off()
#


# Force Channel -----------------------------------------------------------
# Which block do you want to plot?
plot.block = block1.fs
pdf("latForce_bk1.pdf", width = 8.32, height = 5.12, useDingbats = FALSE)
ggplot(data = plot.block, aes(x = sample, y = mean, color = group))+
  geom_point()+
  geom_errorbar(aes(x = plot.block$sample, ymin = plot.block$mean-plot.block$se, ymax = plot.block$mean+plot.block$se, color = plot.block$group, alpha = 0.05))+
  coord_cartesian(ylim = c(-0.5, 3.5))+
  labs(y = "Lateral Force (N)")+
  theme_bw()+
  theme(axis.text.y = element_text(size = 16),
        axis.text.x = element_text(size = 12),
        axis.title.y = element_text(size = 20),
        axis.title.x = element_text(size = 20),
        legend.title = element_blank())+
  scale_color_discrete(labels = c("0 N/m", "30 N/m", "60 N/m"))+
  geom_vline(xintercept = c(100,900), linetype = "dotted")
dev.off()

plot.block = block2.fs
pdf("latForce_bk2.pdf", width = 8.32, height = 5.12, useDingbats = FALSE)
ggplot(data = plot.block, aes(x = sample, y = mean, color = group))+
  geom_point()+
  geom_errorbar(aes(x = plot.block$sample, ymin = plot.block$mean-plot.block$se, ymax = plot.block$mean+plot.block$se, color = plot.block$group, alpha = 0.05))+
  coord_cartesian(ylim = c(-0.5, 3.5))+
  labs(y = "Lateral Force (N)")+
  theme_bw()+
  theme(axis.text.y = element_text(size = 16),
        axis.text.x = element_text(size = 12),
        axis.title.y = element_text(size = 20),
        axis.title.x = element_text(size = 20),
        legend.title = element_blank())+
  scale_color_discrete(labels = c("0 N/m", "30 N/m", "60 N/m"))+
  geom_vline(xintercept = c(100,900), linetype = "dotted")
dev.off()

plot.block = block3.fs
pdf("latForce_bk3.pdf", width = 8.32, height = 5.12, useDingbats = FALSE)
ggplot(data = plot.block, aes(x = sample, y = mean, color = group))+
  geom_point()+
  geom_errorbar(aes(x = plot.block$sample, ymin = plot.block$mean-plot.block$se, ymax = plot.block$mean+plot.block$se, color = plot.block$group, alpha = 0.05))+
  coord_cartesian(ylim = c(-0.5, 3.5))+
  labs(y = "Lateral Force (N)")+
  theme_bw()+
  theme(axis.text.y = element_text(size = 16),
        axis.text.x = element_text(size = 12),
        axis.title.y = element_text(size = 20),
        axis.title.x = element_text(size = 20),
        legend.title = element_blank())+
  scale_color_discrete(labels = c("0 N/m", "30 N/m", "60 N/m"))+
  geom_vline(xintercept = c(100,900), linetype = "dotted")
dev.off()
#


# Hand comparison plotting -------------------------------------
# You must run the *_bh_* code first!
pdf("onset_lag.pdf", width = 8.32, height = 5.12, useDingbats = FALSE)
ggplot(data = hand.diff.plot, aes(x = block, y = lag))+
  geom_point(size = 3)+
  geom_line(size = 1)+
  geom_errorbar(data = hand.diff.plot,
                aes(ymin = (lag - sem_lag), ymax = lag + sem_lag),
                width = 0)+
  geom_vline(xintercept = c(4.5,18.5), linetype = "dotted")+
  labs(y = "Onset Difference (ms)")+
  theme_bw()+
  theme(axis.text.y = element_text(size = 14),
        axis.text.x = element_text(size = 12),
        axis.title.y = element_text(size = 20),
        axis.title.x = element_text(size = 20))+
  geom_hline(yintercept = 0, linetype = "dotted")
dev.off()

pdf("offset_lag.pdf", width = 8.32, height = 5.12, useDingbats = FALSE)
ggplot(data = hand.diff.plot, aes(x = block, y = lagf))+
  geom_point(size = 3)+
  geom_line(size = 1)+
  geom_errorbar(data = hand.diff.plot,
                aes(ymin = (lagf - sem_lagf), ymax = lagf + sem_lagf),
                width = 0)+
  geom_vline(xintercept = c(4.5,18.5), linetype = "dotted")+
  labs(y = "Offset Difference (ms)")+
  theme_bw()+
  theme(axis.text.y = element_text(size = 14),
        axis.text.x = element_text(size = 12),
        axis.title.y = element_text(size = 20),
        axis.title.x = element_text(size = 20))+
  geom_hline(yintercept = 0, linetype = "dotted")
dev.off()

pdf("vel_diff.pdf", width = 8.32, height = 5.12, useDingbats = FALSE)
ggplot(data = hand.diff.plot, aes(x = block, y = velPeak))+
  geom_point(size = 3)+
  geom_line(size = 1)+
  geom_errorbar(data = hand.diff.plot,
                aes(ymin = (velPeak - sem_velPeak), ymax = velPeak + sem_velPeak),
                width = 0)+
  geom_vline(xintercept = c(4.5,18.5), linetype = "dotted")+
  labs(y = "Peak Velocity Difference (cm/s)")+
  theme_bw()+
  theme(axis.text.y = element_text(size = 14),
        axis.text.x = element_text(size = 12),
        axis.title.y = element_text(size = 20),
        axis.title.x = element_text(size = 20))+
  geom_hline(yintercept = 0, linetype = "dotted")
dev.off()

pdf("dist_diff.pdf", width = 8.32, height = 5.12, useDingbats = FALSE)
ggplot(data = hand.diff.plot, aes(x = block, y = dist))+
  geom_point(size = 3)+
  geom_line(size = 1)+
  geom_errorbar(data = hand.diff.plot,
                aes(ymin = (dist - sem_dist), ymax = dist + sem_dist),
                width = 0)+
  geom_vline(xintercept = c(4.5,18.5), linetype = "dotted")+
  labs(y = "Movement Length Difference (cm)")+
  theme_bw()+
  theme(axis.text.y = element_text(size = 14),
        axis.text.x = element_text(size = 12),
        axis.title.y = element_text(size = 20),
        axis.title.x = element_text(size = 20))+
  geom_hline(yintercept = 0, linetype = "dotted")
dev.off()

pdf("rmse_diff.pdf", width = 8.32, height = 5.12, useDingbats = FALSE)
ggplot(data = hand.diff.plot, aes(x = block, y = rmse))+
  geom_point(size = 3)+
  geom_line(size = 1)+
  geom_errorbar(data = hand.diff.plot,
                aes(ymin = (rmse - sem_rmse), ymax = rmse + sem_rmse),
                width = 0)+
  geom_vline(xintercept = c(4.5,18.5), linetype = "dotted")+
  labs(y = "RMSE Difference (mm)")+
  theme_bw()+
  theme(axis.text.y = element_text(size = 14),
        axis.text.x = element_text(size = 12),
        axis.title.y = element_text(size = 20),
        axis.title.x = element_text(size = 20))+
  geom_hline(yintercept = 0, linetype = "dotted")
dev.off()
#


# LFvp.bc plotting --------------------------------------------------------
pdf("LFvp.bc.pdf", width = 8.32, height = 5.12, useDingbats = FALSE)
pd = position_dodge(width = 0.4)
block_ex = subset(lhData_MandSEMbg, lhData_MandSEMbg$phase==3)$block
group_ex = subset(lhData_MandSEMbg, lhData_MandSEMbg$phase==3)$group
ggplot(data = subset(lhData_MandSEMbg, lhData_MandSEMbg$phase==3), aes(x = block, y = LFvp.bc))+
  geom_point(aes(color = group_ex), position = pd, size = 3)+
  geom_errorbar(data = subset(lhData_MandSEMbg, lhData_MandSEMbg$phase==3), aes(x = block, ymin = LFvp.bc-LFvp.bc_sem, ymax = LFvp.bc+LFvp.bc_sem, color = group),
                position = pd, width = 0)+
  geom_line(aes(color = group_ex), position = pd, size = 1)+
  scale_y_continuous(limits = c(-0.1,0.5))+
  labs(y = "LFP (N)")+
  theme_bw()+
  theme(axis.text.y = element_text(size = 16),
        axis.text.x = element_text(size = 12),
        axis.title.y = element_text(size = 20),
        axis.title.x = element_text(size = 20),
        legend.title = element_blank())+
  scale_color_discrete(labels = c("0 N/m", "30 N/m", "60 N/m"))+
  geom_vline(xintercept = c(5,12,18), linetype = "dotted")+
  scale_x_continuous(name = "block", breaks = c(5,12,18))
dev.off()
#

# LFoff.bc plotting -----------------------------------------------------
pdf("LFoff.bc.pdf", width = 8.32, height = 5.12, useDingbats = FALSE)
pd = position_dodge(width = 0.4)
block_ex = subset(lhData_MandSEMbg, lhData_MandSEMbg$phase==3)$block
group_ex = subset(lhData_MandSEMbg, lhData_MandSEMbg$phase==3)$group
ggplot(data = subset(lhData_MandSEMbg, lhData_MandSEMbg$phase==3), aes(x = block, y = LFoff.bc))+
  geom_point(aes(color = group_ex), position = pd, size = 3)+
  geom_errorbar(data = subset(lhData_MandSEMbg, lhData_MandSEMbg$phase==3), aes(x = block, ymin = LFoff.bc-LFoff.bc_sem, ymax = LFoff.bc+LFoff.bc_sem, color = group),
                position = pd, width = 0)+
  geom_line(aes(color = group_ex), position = pd, size = 1)+
  scale_y_continuous(limits = c(-0.1,0.5))+
  labs(y = "LFO (N)")+
  theme_bw()+
  theme(axis.text.y = element_text(size = 16),
        axis.text.x = element_text(size = 12),
        axis.title.y = element_text(size = 20),
        axis.title.x = element_text(size = 20),
        legend.title = element_blank())+
  scale_color_discrete(labels = c("0 N/m", "30 N/m", "60 N/m"))+
  geom_vline(xintercept = c(5,12,18), linetype = "dotted")+
  scale_x_continuous(name = "block", breaks = c(5,12,18))
dev.off()
#


# Onset Lag ---------------------------------------------------------------
pdf("Onset_diff.pdf", width = 8.32, height = 5.12, useDingbats = FALSE)
pd = position_dodge(width = 0.4)
block_ex = subset(hand.diff_MandSEMbg, hand.diff_MandSEMbg$phase %in% 1:4)$block
group_ex = subset(hand.diff_MandSEMbg, hand.diff_MandSEMbg$phase %in% 1:4)$group
ggplot()+
  geom_point(data = subset(hand.diff_MandSEMbg, hand.diff_MandSEMbg$phase %in% 1:4), aes(x = block, y = lag, color = group, alpha = 0.01), position = pd)+
  geom_line(data = subset(hand.diff_MandSEMbg, hand.diff_MandSEMbg$phase %in% 1:4), aes(x = block, y = lag, color = group_ex, alpha = 0.01), position = pd)+
  geom_point(data = hand.diff.plot, aes(x = block, y = lag))+
  geom_line(data = hand.diff.plot, aes(x = block, y = lag))+
  geom_errorbar(data = hand.diff.plot, aes(x = block, ymin = (lag - sem_lag), ymax = (lag + sem_lag), width = 0))+
  scale_y_continuous(limits = c(-75,75))+
  labs(y = "Onset Difference (ms)")+
  theme_bw()+
  theme(axis.text.y = element_text(size = 16),
        axis.text.x = element_text(size = 12),
        axis.title.y = element_text(size = 20),
        axis.title.x = element_text(size = 20),
        legend.title = element_blank())+
  scale_color_discrete(labels = c("0 N/m", "30 N/m", "60 N/m"))+
  geom_vline(xintercept = c(5,12,18), linetype = "dotted")+
  scale_x_continuous(name = "block", breaks = c(5,12,18))
dev.off()
#

# velPeakTime diff -------------------------------------------------------------
pdf("velPeakTime_diff.pdf", width = 8.32, height = 5.12, useDingbats = FALSE)
pd = position_dodge(width = 0.4)
block_ex = subset(hand.diff_MandSEMbg, hand.diff_MandSEMbg$phase %in% 1:4)$block
group_ex = subset(hand.diff_MandSEMbg, hand.diff_MandSEMbg$phase %in% 1:4)$group
ggplot()+
  geom_point(data = subset(hand.diff_MandSEMbg, hand.diff_MandSEMbg$phase %in% 1:4), aes(x = block, y = velPeakTime, color = group, alpha = 0.01), position = pd)+
  geom_line(data = subset(hand.diff_MandSEMbg, hand.diff_MandSEMbg$phase %in% 1:4), aes(x = block, y = velPeakTime, color = group_ex, alpha = 0.01), position = pd)+
  geom_point(data = hand.diff.plot, aes(x = block, y = velPeakTime))+
  geom_line(data = hand.diff.plot, aes(x = block, y = velPeakTime))+
  geom_errorbar(data = hand.diff.plot, aes(x = block, ymin = (velPeakTime - sem_velPeakTime), ymax = (velPeakTime + sem_velPeakTime), width = 0))+
  scale_y_continuous(limits = c(-60,125))+
  labs(y = "Time to PV Difference (ms)")+
  theme_bw()+
  theme(axis.text.y = element_text(size = 16),
        axis.text.x = element_text(size = 12),
        axis.title.y = element_text(size = 20),
        axis.title.x = element_text(size = 20),
        legend.title = element_blank())+
  scale_color_discrete(labels = c("0 N/m", "30 N/m", "60 N/m"))+
  geom_vline(xintercept = c(5,12,18), linetype = "dotted")+
  scale_x_continuous(name = "block", breaks = c(5,12,18))
dev.off()
#


# Offset Lag --------------------------------------------------------------
pdf("Offset_diff.pdf", width = 8.32, height = 5.12, useDingbats = FALSE)
pd = position_dodge(width = 0.4)
block_ex = subset(hand.diff_MandSEMbg, hand.diff_MandSEMbg$phase %in% 1:4)$block
group_ex = subset(hand.diff_MandSEMbg, hand.diff_MandSEMbg$phase %in% 1:4)$group
ggplot()+
  geom_point(data = subset(hand.diff_MandSEMbg, hand.diff_MandSEMbg$phase %in% 1:4), aes(x = block, y = lagf, color = group, alpha = 0.01), position = pd)+
  geom_line(data = subset(hand.diff_MandSEMbg, hand.diff_MandSEMbg$phase %in% 1:4), aes(x = block, y = lagf, color = group_ex, alpha = 0.01), position = pd)+
  geom_point(data = hand.diff.plot, aes(x = block, y = lagf))+
  geom_line(data = hand.diff.plot, aes(x = block, y = lagf))+
  geom_errorbar(data = hand.diff.plot, aes(x = block, ymin = (lagf - sem_lagf), ymax = (lagf + sem_lagf), width = 0))+
  labs(y = "Offset Difference (ms)")+
  theme_bw()+
  theme(axis.text.y = element_text(size = 16),
        axis.text.x = element_text(size = 12),
        axis.title.y = element_text(size = 20),
        axis.title.x = element_text(size = 20),
        legend.title = element_blank())+
  scale_color_discrete(labels = c("0 N/m", "30 N/m", "60 N/m"))+
  geom_vline(xintercept = c(5,12,18), linetype = "dotted")+
  scale_x_continuous(name = "block", breaks = c(5,12,18))
dev.off()
#
  
# RH - reaction time ------------------------------------------------------

pdf("rhRT.pdf", width = 8.32, height = 5.12, useDingbats = FALSE)
pd = position_dodge(width = 0.4)
block_ex = subset(rhData_MandSEMbg, rhData_MandSEMbg$block %in% c(4,5))$block
group_ex = subset(rhData_MandSEMbg, rhData_MandSEMbg$block %in% c(4,5))$group
ggplot(data = subset(rhData_MandSEMbg, rhData_MandSEMbg$block %in% c(4,5)), aes(x = block, y = RT_c))+
  geom_point(aes(color = group_ex), position = pd, size = 3)+
  geom_errorbar(data = subset(rhData_MandSEMbg, rhData_MandSEMbg$block %in% c(4,5)), aes(x = block, ymin = RT_c-RT_c_sem, ymax = RT_c+RT_c_sem, color = group),
                position = pd, width = 0)+
  geom_line(aes(color = group_ex), position = pd, size = 1)+
  scale_y_continuous(limits = c(250,375))+
  labs(y = "RT (ms)")+
  theme_bw()+
  theme(axis.text.y = element_text(size = 16),
        axis.text.x = element_text(size = 12),
        axis.title.y = element_text(size = 20),
        axis.title.x = element_text(size = 20),
        legend.title = element_blank())+
  scale_color_discrete(labels = c("0 N/m", "30 N/m", "60 N/m"))+
  scale_x_continuous(name = "block", breaks = c(4,5))
dev.off()
#

# LH - reaction time ------------------------------------------------------

pdf("lhRT.pdf", width = 8.32, height = 5.12, useDingbats = FALSE)
pd = position_dodge(width = 0.4)
block_ex = subset(lhData_MandSEMbg, lhData_MandSEMbg$block %in% c(4,5))$block
group_ex = subset(lhData_MandSEMbg, lhData_MandSEMbg$block %in% c(4,5))$group
ggplot(data = subset(lhData_MandSEMbg, lhData_MandSEMbg$block %in% c(4,5)), aes(x = block, y = RT_c))+
  geom_point(aes(color = group_ex), position = pd, size = 3)+
  geom_errorbar(data = subset(lhData_MandSEMbg, lhData_MandSEMbg$block %in% c(4,5)), aes(x = block, ymin = RT_c-RT_c_sem, ymax = RT_c+RT_c_sem, color = group),
                position = pd, width = 0)+
  geom_line(aes(color = group_ex), position = pd, size = 1)+
  scale_y_continuous(limits = c(250,375))+
  labs(y = "RT (ms)")+
  theme_bw()+
  theme(axis.text.y = element_text(size = 16),
        axis.text.x = element_text(size = 12),
        axis.title.y = element_text(size = 20),
        axis.title.x = element_text(size = 20),
        legend.title = element_blank())+
  scale_color_discrete(labels = c("0 N/m", "30 N/m", "60 N/m"))+
  scale_x_continuous(name = "block", breaks = c(4,5))
dev.off()
#

# mov_int Left hand -------------------------------------------------------
pdf("mov_int_c.pdf", width = 8.32, height = 5.12, useDingbats = FALSE)
pd = position_dodge(width = 0.4)
block_ex = subset(lhData_MandSEMbg, lhData_MandSEMbg$phase==3)$block
group_ex = subset(lhData_MandSEMbg, lhData_MandSEMbg$phase==3)$group
ggplot(data = subset(lhData_MandSEMbg, lhData_MandSEMbg$phase==3), aes(x = block, y = mov_int_c))+
  geom_point(aes(color = group_ex), position = pd, size = 3)+
  geom_errorbar(data = subset(lhData_MandSEMbg, lhData_MandSEMbg$phase==3), aes(x = block, ymin = mov_int_c-mov_int_c_sem, ymax = mov_int_c+mov_int_c_sem, color = group),
                position = pd, width = 0)+
  geom_line(aes(color = group_ex), position = pd, size = 1)+
  scale_y_continuous(limits = c(8,10.5))+
  labs(y = "Movement length (cm)")+
  theme_bw()+
  theme(axis.text.y = element_text(size = 16),
        axis.text.x = element_text(size = 12),
        axis.title.y = element_text(size = 20),
        axis.title.x = element_text(size = 20),
        legend.title = element_blank())+
  scale_color_discrete(labels = c("0 N/m", "30 N/m", "60 N/m"))+
  geom_hline(yintercept = c(10), linetype = "dotted")+
  scale_x_continuous(name = "block", breaks = c(5,12,18))
dev.off()
#
