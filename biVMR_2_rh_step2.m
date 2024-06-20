% This loads in the .mat file generated in step 1

clear all
close all

% Select the subject file
str = computer;
if strcmp(str,'MACI64') == 1
    cd('/Volumes/mnl/Data/Adaptation/interference_dosing/Post_Step_1');
    fname = uigetfile('*rh.mat');
    fname = fname(1:22);
    fcTrials = xlsread('/Volumes/mnl/Data/Adaptation/interference_dosing/Force_Channel_Trials_12_03_16.xlsx','Sheet1');
else
    cd('Z:\Data\Adaptation\interference_dosing\Post_Step_1\'); % Lab PCs
    %cd('C:\Users\Alex\Desktop\IFDosing\Post_Step_1'); % Home PC
    fname = uigetfile('*rh.mat');
    fname = fname(1:22);
    fcTrials = xlsread('Z:Data\Adaptation\interference_dosing\Force_Channel_Trials_12_03_16.xlsx','Sheet1'); %Lab PCs
    %fcTrials = xlsread('C:\Users\Alex\Desktop\IFDosing\Force_Channel_Trials_12_03_16.xlsx','Sheet1'); % Home PC
end

load([fname '.mat']);
subID = fname(1:9);

numTrials = size(sortData,1); % Number of Trials
fs = 1000; % Sample Rate (Hz)
delta_t = 1/fs; %Sample Period

% toss out trials 25 and 26, these are transition trials between
% kinesthetic and kin+rotation
wrong_trial(41) = 1;
wrong_trial(42) = 1;

channel_trial = zeros(1,numTrials);
channel_trial(fcTrials) = 1;

% Conversion between global and local reference frame (this is due to all
% x,y hand positions being referenced in the global frame, whereas the
% targets in the target table are referenced in a local frame specified in
% Deterit-E
Tx = sortData(1,1).TARGET_TABLE.X_GLOBAL(1) - sortData(1,1).TARGET_TABLE.X(1);
Ty = sortData(1,1).TARGET_TABLE.Y_GLOBAL(1) - sortData(1,1).TARGET_TABLE.Y(1);

%visual baseline, kinesthetic baseline, exposure, and post-exposure
%trial numbers in the sequence
vbTrials = 1:20;
kbTrials = 21:40;
exTrials = 43:182;
peTrials = 183:222;

rotation_type =  sortData(1,1).TP_TABLE.Rotation_Type(5);
rotation_amount =  sortData(1,1).TP_TABLE.Rotation_Amount(5);

theta(vbTrials) = 0; % rotation in degrees during exposure phase
theta(kbTrials) = 0;
if rotation_type == 1 && strcmp(sortData(1,1).EXPERIMENT.ACTIVE_ARM, 'RIGHT') == 1
    theta(exTrials) = rotation_amount;
else
    theta(exTrials) = 0;
end
theta(peTrials) = 0;

% Find the Cursor Position
% First, translate rotation point to global origin
% Then apply rotation, and translate back to target origin
cursorPosX = cell(numTrials,1);
cursorPosY = cell(numTrials,1);
handPosX = cell(numTrials,1);
handPosY = cell(numTrials,1);
for i = 1:numTrials
    handPosX{i,1} = sortData(i).Right_HandX - sortData(1).TARGET_TABLE.X_GLOBAL(2)/100; % Translate to global origin
    handPosY{i,1} = sortData(i).Right_HandY - sortData(1).TARGET_TABLE.Y_GLOBAL(2)/100;
    
    cursorPosX{i,1} = handPosX{i,1}.*cosd(theta(i)) - handPosY{i,1}.*sind(theta(i)); % Reverse the rotation
    cursorPosY{i,1} = handPosX{i,1}.*sind(theta(i)) + handPosY{i,1}.*cosd(theta(i));
    
    cursorPosX{i,1} = cursorPosX{i,1} + sortData(1).TARGET_TABLE.X_GLOBAL(2)/100; % Translate back to target origin
    cursorPosY{i,1} = cursorPosY{i,1} + sortData(1).TARGET_TABLE.Y_GLOBAL(2)/100;
end



% Find the "Up" and "Down" trials
upBool = zeros(numTrials,1);
for i = 1:numTrials
    upBool(i) = sortData(i).TRIAL.TP == 1 || sortData(i).TRIAL.TP == 3 || sortData(i).TRIAL.TP == 5;
end
upBool = upBool';
upTrials = find(upBool == 1); % Trial numbers of "up" targets
upTrials = upTrials';
downTrials = find(upBool == 0);
downTrials = downTrials';


numDataPoints = zeros(numTrials,1);
for i = 1:numTrials
    numDataPoints(i) = size(sortData(i).Right_HandX,1); % Number of Data points in each trial
end

vel = cell(numTrials,1);
velPeak = zeros(numTrials,1);
indPeak = zeros(numTrials,1);
for i = 1:numTrials
    %Calculate hand speed
    vel{i,1} = sqrt(sortData(i,1).Right_HandXVel.^2 + sortData(i,1).Right_HandYVel.^2);
    %Find Peak velocity
    [velPeak(i), indPeak(i)] = max(abs(vel{i,1}));
end
velPeakTime = indPeak - onset;
%% Movement Time (MT)
%%%%%%%%%%%%%%%%%%%%%%%%%%% Movement Time %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MT = (offset - onset)/fs;
MT(wrong_trial==1) = NaN;
MT(channel_trial==1) = NaN;

%% MT outlier analysis
data = outlier_t(MT(upTrials(1:10))); % Outlier for visual baseline
MT_c(upTrials(1:10)) = data;
data = outlier_t(MT(downTrials(1:10)));
MT_c(downTrials(1:10)) = data;
clear data;

data = outlier_t(MT(upTrials(11:20))); % Outlier for kin baseline
MT_c(upTrials(11:20)) = data;
data = outlier_t(MT(downTrials(11:20)));
MT_c(downTrials(11:20)) = data;
clear data;

MT_c(upTrials(21)) = NaN; MT_c(downTrials(21)) = NaN; % Toss out catch trials

% data = outlier_t(MT(upTrials(14:23))); % Outlier for first 20 exposure
% MT_c(upTrials(14:23)) = data;
% data = outlier_t(MT(downTrials(14:23)));
% MT_c(downTrials(14:23)) = data;
% clear data;
MT_c(upTrials(22:31)) = MT(upTrials(22:31));
MT_c(downTrials(22:31)) = MT(downTrials(22:31));

data = outlier_t(MT(upTrials(32:91))); % Outlier for last 100 exposure
MT_c(upTrials(32:91)) = data;
data = outlier_t(MT(downTrials(32:91)));
MT_c(downTrials(32:91)) = data;
clear data;

data = outlier_t(MT(upTrials(92:96))); % Outlier for first 10 post-exp
MT_c(upTrials(92:96)) = data;
data = outlier_t(MT(downTrials(92:96)));
MT_c(downTrials(92:96)) = data;
clear data;

data = outlier_t(MT(upTrials(97:111))); % Outlier for last 10 post-exp
MT_c(upTrials(97:111)) = data;
data = outlier_t(MT(downTrials(97:111)));
MT_c(downTrials(97:111)) = data;
clear data;

% transpose and calculate standardized variable
MT_c = MT_c';
bvup_mean = nanmean(MT_c(upTrials(1:10)));
bvup_std = nanstd(MT_c(upTrials(1:10)));
MT_up_st = (MT_c(upTrials) - bvup_mean)/bvup_std;

bvdown_mean = nanmean(MT_c(downTrials(1:10)));
bvdown_std = nanstd(MT_c(downTrials(1:10)));
MT_down_st = (MT_c(downTrials) - bvdown_mean)/bvdown_std;

clear bvup_mean; clear bvup_std; clear bvdown_mean; clear bvdown_std;

%% Plotting Code for MT
figure
set(gcf,'Color','w','Position',[560 528 600 420])
hold on;

subplot('Position',[0.06 0.2 0.1 0.6]); hold on;
plot(upTrials(1:10),MT(upTrials(1:10)),'bo');
hold on
plot(upTrials(1:10),MT_c(upTrials(1:10)),'bx');
hold on
plot(downTrials(1:10),MT(downTrials(1:10)),'ro');
hold on
plot(downTrials(1:10),MT_c(downTrials(1:10)),'rx');
axis([0 20 0 6]); set(gca,'LineWidth',2,'XTick',[1 10 20],'YTick',0:1:6,'YTickLabel',0:1:6,'FontName','Arial','FontSize',10); ylabel('MT [s]'); title('vis-pre','fontsize',11);

hold on
subplot('Position',[0.19 0.2 0.1 0.6]); hold on;
plot(upTrials(11:20)-kbTrials(1)+1,MT(upTrials(11:20)),'bo');
hold on
plot(upTrials(11:20)-kbTrials(1)+1,MT_c(upTrials(11:20)),'bx');
hold on
plot(downTrials(11:20)-kbTrials(1)+1,MT(downTrials(11:20)),'ro');
hold on
plot(downTrials(11:20)-kbTrials(1)+1,MT_c(downTrials(11:20)),'rx');
axis([0 20 0 6]); set(gca,'LineWidth',2,'XTick',[1 10 20],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title('kin-pre','fontsize',11);

hold on
subplot('Position',[0.32 0.2 0.4 0.6]); hold on;
plot(upTrials(22:91)-exTrials(1)+1,MT(upTrials(22:91)),'bo');
hold on
plot(upTrials(22:91)-exTrials(1)+1,MT_c(upTrials(22:91)),'bx');
hold on
plot(downTrials(22:91)-exTrials(1)+1,MT(downTrials(22:91)),'ro');
hold on
plot(downTrials(22:91)-exTrials(1)+1,MT_c(downTrials(22:91)),'rx');
axis([0 140 0 6]); set(gca,'LineWidth',2,'XTick',[1 20 70 120 140],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);

hold on
subplot('Position',[0.75 0.2 0.24 0.6]); hold on;
plot(upTrials(92:111)-peTrials(1)+1,MT(upTrials(92:111)),'bo');
hold on
plot(upTrials(92:111)-peTrials(1)+1,MT_c(upTrials(92:111)),'bx');
hold on
plot(downTrials(92:111)-peTrials(1)+1,MT(downTrials(92:111)),'ro');
hold on
plot(downTrials(92:111)-peTrials(1)+1,MT_c(downTrials(92:111)),'rx');
axis([0 40 0 6]); set(gca,'LineWidth',2,'XTick',[1 20 40],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['post-exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);
title('MT')

%% IDE
%%%%%%%%%%%%%%%%%%%%%%% Initial Directional Error %%%%%%%%%%%%%%%%%%%%%%%%
% Defined as the angle between the vector from hand position at movement
% onset to target position and a vector pointing to the hand
% position at peak velocity from movement onset hand position
upTargetPos = [sortData(1,1).TARGET_TABLE.X(3) sortData(1,1).TARGET_TABLE.Y(3)];
downTargetPos = [sortData(1,1).TARGET_TABLE.X(4) sortData(1,1).TARGET_TABLE.Y(4)];

xPeak = zeros(numTrials,1);
yPeak = zeros(numTrials,1);
xStart = zeros(numTrials,1);
yStart = zeros(numTrials,1);
imd = zeros(numTrials,2); % initial movement direction (x,y)
itd = zeros(numTrials,2); % initial target direction (x,y)
ide = zeros(numTrials,1);

for i = 1:numTrials
    if wrong_trial(i) == 0 && channel_trial(i) == 0
        % Hand Position at movement onset
        xStart(i) = cursorPosX{i,1}(onset(i))*100-Tx; %in cm and workspace ref frame
        yStart(i) = cursorPosY{i,1}(onset(i))*100-Ty;
        % Hand Position at peak velocity
        xPeak(i) = cursorPosX{i,1}(indPeak(i))*100-Tx; %in cm and workspace ref frame
        yPeak(i) = cursorPosY{i,1}(indPeak(i))*100-Ty;
        % Vector from start position to peak velocity position
        imd(i,:) = [xPeak(i) - xStart(i) yPeak(i) - yStart(i)];
        
        if yPeak(i) > 0
            itd(i,:) = [upTargetPos(1) - xStart(i) upTargetPos(2) - yStart(i)];
        elseif yPeak(i) < 0
            itd(i,:) = [downTargetPos(1) - xStart(i) downTargetPos(2) - yStart(i)];
        end
        ide(i) = acosd(dot(itd(i,:),imd(i,:))./(norm(itd(i,:)).*norm(imd(i,:))));
        % Make ide the the 1st and 3rd quad negative
        if imd(i,1) > 0 && imd(i,2) > 0
            ide(i) = -ide(i);
        elseif imd(i,1) < 0 && imd(i,2) < 0
            ide(i) = -ide(i);
        end
        
    else
        xPeak(i) = NaN;
        yPeak(i) = NaN;
        xStart(i) = NaN;
        yStart(i) = NaN;
        imd(i,:) = NaN;
        ide(i) = NaN;
    end
end

% ide(exTrials) = ide(exTrials)-40;

%% ide outlier analysis
data = outlier_t(ide(upTrials(1:10)));
ide_c(upTrials(1:10)) = data;
data = outlier_t(ide(downTrials(1:10)));
ide_c(downTrials(1:10)) = data;
clear data;

data = outlier_t(ide(upTrials(11:20)));
ide_c(upTrials(11:20)) = data;
data = outlier_t(ide(downTrials(11:20)));
ide_c(downTrials(11:20)) = data;
clear data;

ide_c(upTrials(21)) = NaN; ide_c(downTrials(21)) = NaN;

% data = outlier_t(ide(upTrials(14:23)));
% ide_c(upTrials(14:23)) = data;
% data = outlier_t(ide(downTrials(14:23)));
% ide_c(downTrials(14:23)) = data;
% clear data;
ide_c(upTrials(22:31)) = ide(upTrials(22:31));
ide_c(downTrials(22:31)) = ide(downTrials(22:31));

data = outlier_t(ide(upTrials(32:91)));
ide_c(upTrials(32:91)) = data;
data = outlier_t(ide(downTrials(32:91)));
ide_c(downTrials(32:91)) = data;
clear data;

data = outlier_t(ide(upTrials(92:96)));
ide_c(upTrials(92:96)) = data;
data = outlier_t(ide(downTrials(92:96)));
ide_c(downTrials(92:96)) = data;
clear data;

data = outlier_t(ide(upTrials(97:111)));
ide_c(upTrials(97:111)) = data;
data = outlier_t(ide(downTrials(97:111)));
ide_c(downTrials(97:111)) = data;
clear data;

% transpose and calculate standardized variable
ide_c = ide_c';
bvup_mean = nanmean(ide_c(upTrials(1:10)));
bvup_std = nanstd(ide_c(upTrials(1:10)));
ide_up_st = (ide_c(upTrials) - bvup_mean)/bvup_std;

bvdown_mean = nanmean(ide_c(downTrials(1:10)));
bvdown_std = nanstd(ide_c(downTrials(1:10)));
ide_down_st = (ide_c(downTrials) - bvdown_mean)/bvdown_std;

clear bvup_mean; clear bvup_std; clear bvdown_mean; clear bvdown_std;

%% Plotting Code for ide
figure
set(gcf,'Color','w','Position',[560 528 600 420])
hold on;

subplot('Position',[0.06 0.2 0.1 0.6]); hold on;
plot(upTrials(1:10),ide(upTrials(1:10)),'bo');
hold on
plot(upTrials(1:10),ide_c(upTrials(1:10)),'bx');
hold on
plot(downTrials(1:10),ide(downTrials(1:10)),'ro');
hold on
plot(downTrials(1:10),ide_c(downTrials(1:10)),'rx');
axis([0 20 -80 80]); set(gca,'LineWidth',2,'XTick',[1 10 20],'YTick',-80:20:80,'YTickLabel',-80:20:80,'FontName','Arial','FontSize',10); ylabel('ide [deg]'); title('vis-pre','fontsize',11);
hold on
line([0 20],[0 0],'LineStyle','--','Color',[.5 .5 .5])

hold on
subplot('Position',[0.19 0.2 0.1 0.6]); hold on;
plot(upTrials(11:20)-kbTrials(1)+1,ide(upTrials(11:20)),'bo');
hold on
plot(upTrials(11:20)-kbTrials(1)+1,ide_c(upTrials(11:20)),'bx');
hold on
plot(downTrials(11:20)-kbTrials(1)+1,ide(downTrials(11:20)),'ro');
hold on
plot(downTrials(11:20)-kbTrials(1)+1,ide_c(downTrials(11:20)),'rx');
axis([0 20 -80 80]); set(gca,'LineWidth',2,'XTick',[1 10 20],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title('kin-pre','fontsize',11);
hold on
line([0 20],[0 0],'LineStyle','--','Color',[.5 .5 .5])

hold on
subplot('Position',[0.32 0.2 0.4 0.6]); hold on;
plot(upTrials(22:91)-exTrials(1)+1,ide(upTrials(22:91)),'bo');
hold on
plot(upTrials(22:91)-exTrials(1)+1,ide_c(upTrials(22:91)),'bx');
hold on
plot(downTrials(22:91)-exTrials(1)+1,ide(downTrials(22:91)),'ro');
hold on
plot(downTrials(22:91)-exTrials(1)+1,ide_c(downTrials(22:91)),'rx');
axis([0 140 -80 80]); set(gca,'LineWidth',2,'XTick',[1 20 70 120 140],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);
hold on
line([0 140],[0 0],'LineStyle','--','Color',[.5 .5 .5])

hold on
subplot('Position',[0.75 0.2 0.24 0.6]); hold on;
plot(upTrials(92:111)-peTrials(1)+1,ide(upTrials(92:111)),'bo');
hold on
plot(upTrials(92:111)-peTrials(1)+1,ide_c(upTrials(92:111)),'bx');
hold on
plot(downTrials(92:111)-peTrials(1)+1,ide(downTrials(92:111)),'ro');
hold on
plot(downTrials(92:111)-peTrials(1)+1,ide_c(downTrials(92:111)),'rx');
axis([0 40 -80 80]); set(gca,'LineWidth',2,'XTick',[1 20 40],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['post-exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);
hold on
line([0 40],[0 0],'LineStyle','--','Color',[.5 .5 .5])
title('ide')

%% EDE
%%%%%%%%%%%%%%%%%%%%%%% Endpoint Directional Error %%%%%%%%%%%%%%%%%%%%%%%%
% Defined as the angle between the vector from hand position at movement
% onset to target position and a vector pointing to the hand
% position at movement endpoint from movement onset hand position
upTargetPos = [sortData(1,1).TARGET_TABLE.X(3) sortData(1,1).TARGET_TABLE.Y(3)];
downTargetPos = [sortData(1,1).TARGET_TABLE.X(4) sortData(1,1).TARGET_TABLE.Y(4)];

xOff = zeros(numTrials,1);
yOff = zeros(numTrials,1);
xStart = zeros(numTrials,1);
yStart = zeros(numTrials,1);
imd = zeros(numTrials,2); % initial movement direction (x,y)
itd = zeros(numTrials,2); % initial target direction (x,y)
ede = zeros(numTrials,1);

for i = 1:numTrials
    if wrong_trial(i) == 0 && channel_trial(i) == 0
        % Hand Position at movement onset
        xStart(i) = cursorPosX{i,1}(onset(i))*100-Tx; %in cm and workspace ref frame
        yStart(i) = cursorPosY{i,1}(onset(i))*100-Ty;
        % Hand Position at peak velocity
        xOff(i) = cursorPosX{i,1}(offset(i))*100-Tx; %in cm and workspace ref frame
        yOff(i) = cursorPosY{i,1}(offset(i))*100-Ty;
        % Vector from start position to peak velocity position
        imd(i,:) = [xOff(i) - xStart(i) yOff(i) - yStart(i)];
        
        if yOff(i) > 0
            itd(i,:) = [upTargetPos(1) - xStart(i) upTargetPos(2) - yStart(i)];
        elseif yOff(i) < 0
            itd(i,:) = [downTargetPos(1) - xStart(i) downTargetPos(2) - yStart(i)];
        end
        ede(i) = acosd(dot(itd(i,:),imd(i,:))./(norm(itd(i,:)).*norm(imd(i,:))));
        % Make ede the the 1st and 3rd quad negative
        if imd(i,1) > 0 && imd(i,2) > 0
            ede(i) = -ede(i);
        elseif imd(i,1) < 0 && imd(i,2) < 0
            ede(i) = -ede(i);
        end
        
    else
        xOff(i) = NaN;
        yOff(i) = NaN;
        xStart(i) = NaN;
        yStart(i) = NaN;
        imd(i,:) = NaN;
        ede(i) = NaN;
    end
end

% ede(exTrials) = ede(exTrials)-40;

%% ede outlier analysis
data = outlier_t(ede(upTrials(1:10)));
ede_c(upTrials(1:10)) = data;
data = outlier_t(ede(downTrials(1:10)));
ede_c(downTrials(1:10)) = data;
clear data;

data = outlier_t(ede(upTrials(11:20)));
ede_c(upTrials(11:20)) = data;
data = outlier_t(ede(downTrials(11:20)));
ede_c(downTrials(11:20)) = data;
clear data;

ede_c(upTrials(21)) = NaN; ede_c(downTrials(21)) = NaN;

% data = outlier_t(ede(upTrials(14:23)));
% ede_c(upTrials(14:23)) = data;
% data = outlier_t(ede(downTrials(14:23)));
% ede_c(downTrials(14:23)) = data;
% clear data;
ede_c(upTrials(22:31)) = ede(upTrials(22:31));
ede_c(downTrials(22:31)) = ede(downTrials(22:31));

data = outlier_t(ede(upTrials(32:91)));
ede_c(upTrials(32:91)) = data;
data = outlier_t(ede(downTrials(32:91)));
ede_c(downTrials(32:91)) = data;
clear data;

data = outlier_t(ede(upTrials(92:96)));
ede_c(upTrials(92:96)) = data;
data = outlier_t(ede(downTrials(92:96)));
ede_c(downTrials(92:96)) = data;
clear data;

data = outlier_t(ede(upTrials(97:111)));
ede_c(upTrials(97:111)) = data;
data = outlier_t(ede(downTrials(97:111)));
ede_c(downTrials(97:111)) = data;
clear data;

% transpose and calculate standardized variable
ede_c = ede_c';
bvup_mean = nanmean(ede_c(upTrials(1:10)));
bvup_std = nanstd(ede_c(upTrials(1:10)));
ede_up_st = (ede_c(upTrials) - bvup_mean)/bvup_std;

bvdown_mean = nanmean(ede_c(downTrials(1:10)));
bvdown_std = nanstd(ede_c(downTrials(1:10)));
ede_down_st = (ede_c(downTrials) - bvdown_mean)/bvdown_std;

clear bvup_mean; clear bvup_std; clear bvdown_mean; clear bvdown_std;

%% Plotting Code for ede
figure
set(gcf,'Color','w','Position',[560 528 600 420])
hold on;

subplot('Position',[0.06 0.2 0.1 0.6]); hold on;
plot(upTrials(1:10),ede(upTrials(1:10)),'bo');
hold on
plot(upTrials(1:10),ede_c(upTrials(1:10)),'bx');
hold on
plot(downTrials(1:10),ede(downTrials(1:10)),'ro');
hold on
plot(downTrials(1:10),ede_c(downTrials(1:10)),'rx');
axis([0 20 -80 80]); set(gca,'LineWidth',2,'XTick',[1 10 20],'YTick',-80:20:80,'YTickLabel',-80:20:80,'FontName','Arial','FontSize',10); ylabel('ede [deg]'); title('vis-pre','fontsize',11);
hold on
line([0 20],[0 0],'LineStyle','--','Color',[.5 .5 .5])

hold on
subplot('Position',[0.19 0.2 0.1 0.6]); hold on;
plot(upTrials(11:20)-kbTrials(1)+1,ede(upTrials(11:20)),'bo');
hold on
plot(upTrials(11:20)-kbTrials(1)+1,ede_c(upTrials(11:20)),'bx');
hold on
plot(downTrials(11:20)-kbTrials(1)+1,ede(downTrials(11:20)),'ro');
hold on
plot(downTrials(11:20)-kbTrials(1)+1,ede_c(downTrials(11:20)),'rx');
axis([0 20 -80 80]); set(gca,'LineWidth',2,'XTick',[1 10 20],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title('kin-pre','fontsize',11);
hold on
line([0 20],[0 0],'LineStyle','--','Color',[.5 .5 .5])

hold on
subplot('Position',[0.32 0.2 0.4 0.6]); hold on;
plot(upTrials(22:91)-exTrials(1)+1,ede(upTrials(22:91)),'bo');
hold on
plot(upTrials(22:91)-exTrials(1)+1,ede_c(upTrials(22:91)),'bx');
hold on
plot(downTrials(22:91)-exTrials(1)+1,ede(downTrials(22:91)),'ro');
hold on
plot(downTrials(22:91)-exTrials(1)+1,ede_c(downTrials(22:91)),'rx');
axis([0 140 -80 80]); set(gca,'LineWidth',2,'XTick',[1 20 70 120 140],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);
hold on
line([0 140],[0 0],'LineStyle','--','Color',[.5 .5 .5])

hold on
subplot('Position',[0.75 0.2 0.24 0.6]); hold on;
plot(upTrials(92:111)-peTrials(1)+1,ede(upTrials(92:111)),'bo');
hold on
plot(upTrials(92:111)-peTrials(1)+1,ede_c(upTrials(92:111)),'bx');
hold on
plot(downTrials(92:111)-peTrials(1)+1,ede(downTrials(92:111)),'ro');
hold on
plot(downTrials(92:111)-peTrials(1)+1,ede_c(downTrials(92:111)),'rx');
axis([0 40 -80 80]); set(gca,'LineWidth',2,'XTick',[1 20 40],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['post-exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);
hold on
line([0 40],[0 0],'LineStyle','--','Color',[.5 .5 .5])
title('ede')

%% RMSE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RMSE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Taken straight from kinsym2 step 2 files
rmse=zeros(numTrials,1); % allocate space for rmse
mov_int = zeros(numTrials,1);
for i=1:numTrials
    if (wrong_trial(i)==0 && channel_trial(i)==0)
        xx=cursorPosX{i,1}(onset(i):offset(i))*1000; % convert to mm
        yy=cursorPosY{i,1}(onset(i):offset(i))*1000;
        % spatial resampling of movement path
        N= 2000; N1= length(xx); % Computes equally-spaced vector assuming 1000 samples
        xc= 1/(N-1)*(0:N-1)*(xx(N1)-xx(1))+xx(1);
        yc= 1/(N-1)*(0:N-1)*(yy(N1)-yy(1))+yy(1);
        % integrates the movement length
        mov_int(i)=sum(sqrt(diff(xx).^2+ diff(yy).^2));
        di=(0:N-1)*mov_int(i)/(N-1);
        d=[0; (cumsum(sqrt((diff(xx).^2)+ (diff(yy).^2))))];
        % interpolates the movement path to make it equally spaced
        x2i= interp1q(d,xx,di');
        y2i= interp1q(d,yy,di');
        x2i(N)=xc(N);
        y2i(N)=yc(N);
        optimal =[xc', yc'];
        resampled_path =[x2i, y2i];
        rmse(i) = sqrt(sum(sum((resampled_path - optimal).^2))/N);
    else rmse(i)=NaN;
    end
end

%% rmse outlier analysis
data = outlier_t(rmse(upTrials(1:10))); % Outlier for visual baseline
rmse_c(upTrials(1:10)) = data;
data = outlier_t(rmse(downTrials(1:10)));
rmse_c(downTrials(1:10)) = data;
clear data;

data = outlier_t(rmse(upTrials(11:20))); % Outlier for kin baseline
rmse_c(upTrials(11:20)) = data;
data = outlier_t(rmse(downTrials(11:20)));
rmse_c(downTrials(11:20)) = data;
clear data;

rmse_c(upTrials(21)) = NaN; rmse_c(downTrials(21)) = NaN; % Toss out catch trials

% data = outlier_t(rmse(upTrials(14:23))); % Outlier for first 20 exposure
% rmse_c(upTrials(14:23)) = data;
% data = outlier_t(rmse(downTrials(14:23)));
% rmse_c(downTrials(14:23)) = data;
% clear data;
rmse_c(upTrials(22:31)) = rmse(upTrials(22:31));
rmse_c(downTrials(22:31)) = rmse(downTrials(22:31));

data = outlier_t(rmse(upTrials(32:91))); % Outlier for last 100 exposure
rmse_c(upTrials(32:91)) = data;
data = outlier_t(rmse(downTrials(32:91)));
rmse_c(downTrials(32:91)) = data;
clear data;

data = outlier_t(rmse(upTrials(92:96))); % Outlier for first 10 post-exp
rmse_c(upTrials(92:96)) = data;
data = outlier_t(rmse(downTrials(92:96)));
rmse_c(downTrials(92:96)) = data;
clear data;

data = outlier_t(rmse(upTrials(97:111))); % Outlier for last 10 post-exp
rmse_c(upTrials(97:111)) = data;
data = outlier_t(rmse(downTrials(97:111)));
rmse_c(downTrials(97:111)) = data;
clear data;

% transpose and calculate standardized variable
rmse_c = rmse_c';
bvup_mean = nanmean(rmse_c(upTrials(1:10)));
bvup_std = nanstd(rmse_c(upTrials(1:10)));
rmse_up_st = (rmse_c(upTrials) - bvup_mean)/bvup_std;

bvdown_mean = nanmean(rmse_c(downTrials(1:10)));
bvdown_std = nanstd(rmse_c(downTrials(1:10)));
rmse_down_st = (rmse_c(downTrials) - bvdown_mean)/bvdown_std;

clear bvup_mean; clear bvup_std; clear bvdown_mean; clear bvdown_std;

%% Plotting Code for rmse
figure
set(gcf,'Color','w','Position',[560 528 600 420])
hold on;

subplot('Position',[0.06 0.2 0.1 0.6]); hold on;
plot(upTrials(1:10),rmse(upTrials(1:10)),'bo');
hold on
plot(upTrials(1:10),rmse_c(upTrials(1:10)),'bx');
hold on
plot(downTrials(1:10),rmse(downTrials(1:10)),'ro');
hold on
plot(downTrials(1:10),rmse_c(downTrials(1:10)),'rx');
axis([0 20 0 60]); set(gca,'LineWidth',2,'XTick',[1 10 20],'YTick',0:10:60,'YTickLabel',0:10:60,'FontName','Arial','FontSize',10); ylabel('rmse [mm]'); title('vis-pre','fontsize',11);

hold on
subplot('Position',[0.19 0.2 0.1 0.6]); hold on;
plot(upTrials(11:20)-kbTrials(1)+1,rmse(upTrials(11:20)),'bo');
hold on
plot(upTrials(11:20)-kbTrials(1)+1,rmse_c(upTrials(11:20)),'bx');
hold on
plot(downTrials(11:20)-kbTrials(1)+1,rmse(downTrials(11:20)),'ro');
hold on
plot(downTrials(11:20)-kbTrials(1)+1,rmse_c(downTrials(11:20)),'rx');
axis([0 20 0 60]); set(gca,'LineWidth',2,'XTick',[1 10 20],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title('kin-pre','fontsize',11);

hold on
subplot('Position',[0.32 0.2 0.4 0.6]); hold on;
plot(upTrials(22:91)-exTrials(1)+1,rmse(upTrials(22:91)),'bo');
hold on
plot(upTrials(22:91)-exTrials(1)+1,rmse_c(upTrials(22:91)),'bx');
hold on
plot(downTrials(22:91)-exTrials(1)+1,rmse(downTrials(22:91)),'ro');
hold on
plot(downTrials(22:91)-exTrials(1)+1,rmse_c(downTrials(22:91)),'rx');
axis([0 140 0 60]); set(gca,'LineWidth',2,'XTick',[1 20 70 120 140],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);

hold on
subplot('Position',[0.75 0.2 0.24 0.6]); hold on;
plot(upTrials(92:111)-peTrials(1)+1,rmse(upTrials(92:111)),'bo');
hold on
plot(upTrials(92:111)-peTrials(1)+1,rmse_c(upTrials(92:111)),'bx');
hold on
plot(downTrials(92:111)-peTrials(1)+1,rmse(downTrials(92:111)),'ro');
hold on
plot(downTrials(92:111)-peTrials(1)+1,rmse_c(downTrials(92:111)),'rx');
axis([0 40 0 60]); set(gca,'LineWidth',2,'XTick',[1 20 40],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['post-exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);
title('rmse')

%% EPE, EP_X, and EP_Y calcs
%%%%%%%%%%%%%%%%%%%%%%%% End-Point Error (EPE)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% and EP_X and EP_Y

EPE = zeros(numTrials,1);
EP_X = zeros(numTrials,1);
EP_Y = zeros(numTrials,1);

for i = 1:numTrials
    if wrong_trial(i) == 0 && channel_trial(i) == 0
        EP_X(i) = (cursorPosX{i,1}(offset(i))*100 - Tx) - sortData(i).TARGET_TABLE.X(3);
        if upBool(i) == 1
            EP_Y(i) = (cursorPosY{i,1}(offset(i))*100 - Ty) - sortData(i).TARGET_TABLE.Y(3);
        else
            EP_Y(i) = (cursorPosY{i,1}(offset(i))*100 - Ty) - sortData(i).TARGET_TABLE.Y(4);
        end
    else
        EPE(i) = NaN;
        EP_X(i) = NaN;
        EP_Y(i) = NaN;
    end
end
EPE = sqrt(EP_X.^2 + EP_Y.^2);

%% EPE outlier analysis
data = outlier_t(EPE(upTrials(1:10))); % Outlier for visual baseline
EPE_c(upTrials(1:10)) = data;
data = outlier_t(EPE(downTrials(1:10)));
EPE_c(downTrials(1:10)) = data;
clear data;

data = outlier_t(EPE(upTrials(11:20))); % Outlier for kin baseline
EPE_c(upTrials(11:20)) = data;
data = outlier_t(EPE(downTrials(11:20)));
EPE_c(downTrials(11:20)) = data;
clear data;

EPE_c(upTrials(21)) = NaN; EPE_c(downTrials(21)) = NaN; % Toss out catch trials

% data = outlier_t(EPE(upTrials(14:23))); % Outlier for first 20 exposure
% EPE_c(upTrials(14:23)) = data;
% data = outlier_t(EPE(downTrials(14:23)));
% EPE_c(downTrials(14:23)) = data;
% clear data;
EPE_c(upTrials(22:31)) = EPE(upTrials(22:31));
EPE_c(downTrials(22:31)) = EPE(downTrials(22:31));

data = outlier_t(EPE(upTrials(32:91))); % Outlier for last 100 exposure
EPE_c(upTrials(32:91)) = data;
data = outlier_t(EPE(downTrials(32:91)));
EPE_c(downTrials(32:91)) = data;
clear data;

data = outlier_t(EPE(upTrials(92:96))); % Outlier for first 10 post-exp
EPE_c(upTrials(92:96)) = data;
data = outlier_t(EPE(downTrials(92:96)));
EPE_c(downTrials(92:96)) = data;
clear data;

data = outlier_t(EPE(upTrials(97:111))); % Outlier for last 10 post-exp
EPE_c(upTrials(97:111)) = data;
data = outlier_t(EPE(downTrials(97:111)));
EPE_c(downTrials(97:111)) = data;
clear data;

% transpose and calculate standardized variable
EPE_c = EPE_c';
bvup_mean = nanmean(EPE_c(upTrials(1:10)));
bvup_std = nanstd(EPE_c(upTrials(1:10)));
EPE_up_st = (EPE_c(upTrials) - bvup_mean)/bvup_std;

bvdown_mean = nanmean(EPE_c(downTrials(1:10)));
bvdown_std = nanstd(EPE_c(downTrials(1:10)));
EPE_down_st = (EPE_c(downTrials) - bvdown_mean)/bvdown_std;

clear bvup_mean; clear bvup_std; clear bvdown_mean; clear bvdown_std;

%% Plotting Code for EPE
figure
set(gcf,'Color','w','Position',[560 528 600 420])
hold on;

subplot('Position',[0.06 0.2 0.1 0.6]); hold on;
plot(upTrials(1:10),EPE(upTrials(1:10)),'bo');
hold on
plot(upTrials(1:10),EPE_c(upTrials(1:10)),'bx');
hold on
plot(downTrials(1:10),EPE(downTrials(1:10)),'ro');
hold on
plot(downTrials(1:10),EPE_c(downTrials(1:10)),'rx');
axis([0 20 0 20]); set(gca,'LineWidth',2,'XTick',[1 10 20],'YTick',0:4:20,'YTickLabel',0:4:20,'FontName','Arial','FontSize',10); ylabel('EPE [cm]'); title('vis-pre','fontsize',11);

hold on
subplot('Position',[0.19 0.2 0.1 0.6]); hold on;
plot(upTrials(11:20)-kbTrials(1)+1,EPE(upTrials(11:20)),'bo');
hold on
plot(upTrials(11:20)-kbTrials(1)+1,EPE_c(upTrials(11:20)),'bx');
hold on
plot(downTrials(11:20)-kbTrials(1)+1,EPE(downTrials(11:20)),'ro');
hold on
plot(downTrials(11:20)-kbTrials(1)+1,EPE_c(downTrials(11:20)),'rx');
axis([0 20 0 20]); set(gca,'LineWidth',2,'XTick',[1 10 20],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title('kin-pre','fontsize',11);

hold on
subplot('Position',[0.32 0.2 0.4 0.6]); hold on;
plot(upTrials(22:91)-exTrials(1)+1,EPE(upTrials(22:91)),'bo');
hold on
plot(upTrials(22:91)-exTrials(1)+1,EPE_c(upTrials(22:91)),'bx');
hold on
plot(downTrials(22:91)-exTrials(1)+1,EPE(downTrials(22:91)),'ro');
hold on
plot(downTrials(22:91)-exTrials(1)+1,EPE_c(downTrials(22:91)),'rx');
axis([0 140 0 20]); set(gca,'LineWidth',2,'XTick',[1 20 70 120 140],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);

hold on
subplot('Position',[0.75 0.2 0.24 0.6]); hold on;
plot(upTrials(92:111)-peTrials(1)+1,EPE(upTrials(92:111)),'bo');
hold on
plot(upTrials(92:111)-peTrials(1)+1,EPE_c(upTrials(92:111)),'bx');
hold on
plot(downTrials(92:111)-peTrials(1)+1,EPE(downTrials(92:111)),'ro');
hold on
plot(downTrials(92:111)-peTrials(1)+1,EPE_c(downTrials(92:111)),'rx');
axis([0 40 0 20]); set(gca,'LineWidth',2,'XTick',[1 20 40],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['post-exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);
title('EPE')

%% EP_X outlier analysis
data = outlier_t(EP_X(upTrials(1:10))); % Outlier for visual baseline
EP_X_c(upTrials(1:10)) = data;
data = outlier_t(EP_X(downTrials(1:10)));
EP_X_c(downTrials(1:10)) = data;
clear data;

data = outlier_t(EP_X(upTrials(11:20))); % Outlier for kin baseline
EP_X_c(upTrials(11:20)) = data;
data = outlier_t(EP_X(downTrials(11:20)));
EP_X_c(downTrials(11:20)) = data;
clear data;

EP_X_c(upTrials(21)) = NaN; EP_X_c(downTrials(21)) = NaN; % Toss out catch trials

% data = outlier_t(EP_X(upTrials(14:23))); % Outlier for first 20 exposure
% EP_X_c(upTrials(14:23)) = data;
% data = outlier_t(EP_X(downTrials(14:23)));
% EP_X_c(downTrials(14:23)) = data;
% clear data;
EP_X_c(upTrials(22:31)) = EP_X(upTrials(22:31));
EP_X_c(downTrials(22:31)) = EP_X(downTrials(22:31));

data = outlier_t(EP_X(upTrials(32:91))); % Outlier for last 100 exposure
EP_X_c(upTrials(32:91)) = data;
data = outlier_t(EP_X(downTrials(32:91)));
EP_X_c(downTrials(32:91)) = data;
clear data;

data = outlier_t(EP_X(upTrials(92:96))); % Outlier for first 10 post-exp
EP_X_c(upTrials(92:96)) = data;
data = outlier_t(EP_X(downTrials(92:96)));
EP_X_c(downTrials(92:96)) = data;
clear data;

data = outlier_t(EP_X(upTrials(97:111))); % Outlier for last 10 post-exp
EP_X_c(upTrials(97:111)) = data;
data = outlier_t(EP_X(downTrials(97:111)));
EP_X_c(downTrials(97:111)) = data;
clear data;

% transpose and calculate standardized variable
EP_X_c = EP_X_c';
bvup_mean = nanmean(EP_X_c(upTrials(1:10)));
bvup_std = nanstd(EP_X_c(upTrials(1:10)));
EP_X_up_st = (EP_X_c(upTrials) - bvup_mean)/bvup_std;

bvdown_mean = nanmean(EP_X_c(downTrials(1:10)));
bvdown_std = nanstd(EP_X_c(downTrials(1:10)));
EP_X_down_st = (EP_X_c(downTrials) - bvdown_mean)/bvdown_std;

clear bvup_mean; clear bvup_std; clear bvdown_mean; clear bvdown_std;

%% Plotting Code for EP_X
figure
set(gcf,'Color','w','Position',[560 528 600 420])
hold on;

subplot('Position',[0.06 0.2 0.1 0.6]); hold on;
plot(upTrials(1:10),EP_X(upTrials(1:10)),'bo');
hold on
plot(upTrials(1:10),EP_X_c(upTrials(1:10)),'bx');
hold on
plot(downTrials(1:10),EP_X(downTrials(1:10)),'ro');
hold on
plot(downTrials(1:10),EP_X_c(downTrials(1:10)),'rx');
axis([0 20 -20 20]); set(gca,'LineWidth',2,'XTick',[1 10 20],'YTick',-20:4:20,'YTickLabel',-20:4:20,'FontName','Arial','FontSize',10); ylabel('EP_X [cm]'); title('vis-pre','fontsize',11);
hold on
line([0 20],[0 0],'LineStyle','--','Color',[.5 .5 .5])

hold on
subplot('Position',[0.19 0.2 0.1 0.6]); hold on;
plot(upTrials(11:20)-kbTrials(1)+1,EP_X(upTrials(11:20)),'bo');
hold on
plot(upTrials(11:20)-kbTrials(1)+1,EP_X_c(upTrials(11:20)),'bx');
hold on
plot(downTrials(11:20)-kbTrials(1)+1,EP_X(downTrials(11:20)),'ro');
hold on
plot(downTrials(11:20)-kbTrials(1)+1,EP_X_c(downTrials(11:20)),'rx');
axis([0 20 -20 20]); set(gca,'LineWidth',2,'XTick',[1 10 20],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title('kin-pre','fontsize',11);
hold on
line([0 20],[0 0],'LineStyle','--','Color',[.5 .5 .5])

hold on
subplot('Position',[0.32 0.2 0.4 0.6]); hold on;
plot(upTrials(22:91)-exTrials(1)+1,EP_X(upTrials(22:91)),'bo');
hold on
plot(upTrials(22:91)-exTrials(1)+1,EP_X_c(upTrials(22:91)),'bx');
hold on
plot(downTrials(22:91)-exTrials(1)+1,EP_X(downTrials(22:91)),'ro');
hold on
plot(downTrials(22:91)-exTrials(1)+1,EP_X_c(downTrials(22:91)),'rx');
axis([0 140 -20 20]); set(gca,'LineWidth',2,'XTick',[1 20 70 120 140],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);
hold on
line([0 140],[0 0],'LineStyle','--','Color',[.5 .5 .5])

hold on
subplot('Position',[0.75 0.2 0.24 0.6]); hold on;
plot(upTrials(92:111)-peTrials(1)+1,EP_X(upTrials(92:111)),'bo');
hold on
plot(upTrials(92:111)-peTrials(1)+1,EP_X_c(upTrials(92:111)),'bx');
hold on
plot(downTrials(92:111)-peTrials(1)+1,EP_X(downTrials(92:111)),'ro');
hold on
plot(downTrials(92:111)-peTrials(1)+1,EP_X_c(downTrials(92:111)),'rx');
axis([0 40 -20 20]); set(gca,'LineWidth',2,'XTick',[1 20 40],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['post-exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);
hold on
line([0 40],[0 0],'LineStyle','--','Color',[.5 .5 .5])
title('EP_X')

%% EP_Y outlier analysis
data = outlier_t(EP_Y(upTrials(1:10))); % Outlier for visual baseline
EP_Y_c(upTrials(1:10)) = data;
data = outlier_t(EP_Y(downTrials(1:10)));
EP_Y_c(downTrials(1:10)) = data;
clear data;

data = outlier_t(EP_Y(upTrials(11:20))); % Outlier for kin baseline
EP_Y_c(upTrials(11:20)) = data;
data = outlier_t(EP_Y(downTrials(11:20)));
EP_Y_c(downTrials(11:20)) = data;
clear data;

EP_Y_c(upTrials(21)) = NaN; EP_Y_c(downTrials(21)) = NaN; % Toss out catch trials

% data = outlier_t(EP_Y(upTrials(14:23))); % Outlier for first 20 exposure
% EP_Y_c(upTrials(14:23)) = data;
% data = outlier_t(EP_Y(downTrials(14:23)));
% EP_Y_c(downTrials(14:23)) = data;
% clear data;
EP_Y_c(upTrials(22:31)) = EP_Y(upTrials(22:31));
EP_Y_c(downTrials(22:31)) = EP_Y(downTrials(22:31));

data = outlier_t(EP_Y(upTrials(32:91))); % Outlier for last 100 exposure
EP_Y_c(upTrials(32:91)) = data;
data = outlier_t(EP_Y(downTrials(32:91)));
EP_Y_c(downTrials(32:91)) = data;
clear data;

data = outlier_t(EP_Y(upTrials(92:96))); % Outlier for first 10 post-exp
EP_Y_c(upTrials(92:96)) = data;
data = outlier_t(EP_Y(downTrials(92:96)));
EP_Y_c(downTrials(92:96)) = data;
clear data;

data = outlier_t(EP_Y(upTrials(97:111))); % Outlier for last 10 post-exp
EP_Y_c(upTrials(97:111)) = data;
data = outlier_t(EP_Y(downTrials(97:111)));
EP_Y_c(downTrials(97:111)) = data;
clear data;

% transpose and calculate standardized variable
EP_Y_c = EP_Y_c';
bvup_mean = nanmean(EP_Y_c(upTrials(1:10)));
bvup_std = nanstd(EP_Y_c(upTrials(1:10)));
EP_Y_up_st = (EP_Y_c(upTrials) - bvup_mean)/bvup_std;

bvdown_mean = nanmean(EP_Y_c(downTrials(1:10)));
bvdown_std = nanstd(EP_Y_c(downTrials(1:10)));
EP_Y_down_st = (EP_Y_c(downTrials) - bvdown_mean)/bvdown_std;

clear bvup_mean; clear bvup_std; clear bvdown_mean; clear bvdown_std;

%% Plotting Code for EP_Y
figure
set(gcf,'Color','w','Position',[560 528 600 420])
hold on;

subplot('Position',[0.06 0.2 0.1 0.6]); hold on;
plot(upTrials(1:10),EP_Y(upTrials(1:10)),'bo');
hold on
plot(upTrials(1:10),EP_Y_c(upTrials(1:10)),'bx');
hold on
plot(downTrials(1:10),EP_Y(downTrials(1:10)),'ro');
hold on
plot(downTrials(1:10),EP_Y_c(downTrials(1:10)),'rx');
axis([0 20 -20 20]); set(gca,'LineWidth',2,'XTick',[1 10 20],'YTick',-20:4:20,'YTickLabel',-20:4:20,'FontName','Arial','FontSize',10); ylabel('EP_Y [cm]'); title('vis-pre','fontsize',11);
hold on
line([0 20],[0 0],'LineStyle','--','Color',[.5 .5 .5])

hold on
subplot('Position',[0.19 0.2 0.1 0.6]); hold on;
plot(upTrials(11:20)-kbTrials(1)+1,EP_Y(upTrials(11:20)),'bo');
hold on
plot(upTrials(11:20)-kbTrials(1)+1,EP_Y_c(upTrials(11:20)),'bx');
hold on
plot(downTrials(11:20)-kbTrials(1)+1,EP_Y(downTrials(11:20)),'ro');
hold on
plot(downTrials(11:20)-kbTrials(1)+1,EP_Y_c(downTrials(11:20)),'rx');
axis([0 20 -20 20]); set(gca,'LineWidth',2,'XTick',[1 10 20],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title('kin-pre','fontsize',11);
hold on
line([0 20],[0 0],'LineStyle','--','Color',[.5 .5 .5])

hold on
subplot('Position',[0.32 0.2 0.4 0.6]); hold on;
plot(upTrials(22:91)-exTrials(1)+1,EP_Y(upTrials(22:91)),'bo');
hold on
plot(upTrials(22:91)-exTrials(1)+1,EP_Y_c(upTrials(22:91)),'bx');
hold on
plot(downTrials(22:91)-exTrials(1)+1,EP_Y(downTrials(22:91)),'ro');
hold on
plot(downTrials(22:91)-exTrials(1)+1,EP_Y_c(downTrials(22:91)),'rx');
axis([0 140 -20 20]); set(gca,'LineWidth',2,'XTick',[1 20 70 120 140],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);
hold on
line([0 140],[0 0],'LineStyle','--','Color',[.5 .5 .5])

hold on
subplot('Position',[0.75 0.2 0.24 0.6]); hold on;
plot(upTrials(92:111)-peTrials(1)+1,EP_Y(upTrials(92:111)),'bo');
hold on
plot(upTrials(92:111)-peTrials(1)+1,EP_Y_c(upTrials(92:111)),'bx');
hold on
plot(downTrials(92:111)-peTrials(1)+1,EP_Y(downTrials(92:111)),'ro');
hold on
plot(downTrials(92:111)-peTrials(1)+1,EP_Y_c(downTrials(92:111)),'rx');
axis([0 40 -20 20]); set(gca,'LineWidth',2,'XTick',[1 20 40],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['post-exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);
hold on
line([0 40],[0 0],'LineStyle','--','Color',[.5 .5 .5])
title('EP_Y')

%% Movement Length

%%%%%%%%%%%%%%%%%%%%%%% Movement Length %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mov_int = zeros(numTrials,1);
for i = 1:numTrials
    if wrong_trial(i) == 0 && channel_trial(i) == 0
        mov_int(i) = sum(sqrt(diff(cursorPosX{i,1}(onset(i):offset(i))).^2 + diff(cursorPosY{i,1}(onset(i):offset(i))).^2)) * 100; %movement length in cm
    else
        mov_int(i) = NaN;
    end
end

%% mov_int outlier analysis
data = outlier_t(mov_int(upTrials(1:10))); % Outlier for visual baseline
mov_int_c(upTrials(1:10)) = data;
data = outlier_t(mov_int(downTrials(1:10)));
mov_int_c(downTrials(1:10)) = data;
clear data;

data = outlier_t(mov_int(upTrials(11:20))); % Outlier for kin baseline
mov_int_c(upTrials(11:20)) = data;
data = outlier_t(mov_int(downTrials(11:20)));
mov_int_c(downTrials(11:20)) = data;
clear data;

mov_int_c(upTrials(21)) = NaN; mov_int_c(downTrials(21)) = NaN; % Toss out catch trials

% data = outlier_t(mov_int(upTrials(14:23))); % Outlier for first 20 exposure
% mov_int_c(upTrials(14:23)) = data;
% data = outlier_t(mov_int(downTrials(14:23)));
% mov_int_c(downTrials(14:23)) = data;
% clear data;
mov_int_c(upTrials(22:31)) = mov_int(upTrials(22:31));
mov_int_c(downTrials(22:31)) = mov_int(downTrials(22:31));

data = outlier_t(mov_int(upTrials(32:91))); % Outlier for last 100 exposure
mov_int_c(upTrials(32:91)) = data;
data = outlier_t(mov_int(downTrials(32:91)));
mov_int_c(downTrials(32:91)) = data;
clear data;

data = outlier_t(mov_int(upTrials(92:96))); % Outlier for first 10 post-exp
mov_int_c(upTrials(92:96)) = data;
data = outlier_t(mov_int(downTrials(92:96)));
mov_int_c(downTrials(92:96)) = data;
clear data;

data = outlier_t(mov_int(upTrials(97:111))); % Outlier for last 10 post-exp
mov_int_c(upTrials(97:111)) = data;
data = outlier_t(mov_int(downTrials(97:111)));
mov_int_c(downTrials(97:111)) = data;
clear data;

% transpose and calculate standardized variable
mov_int_c = mov_int_c';
bvup_mean = nanmean(mov_int_c(upTrials(1:10)));
bvup_std = nanstd(mov_int_c(upTrials(1:10)));
mov_int_up_st = (mov_int_c(upTrials) - bvup_mean)/bvup_std;

bvdown_mean = nanmean(mov_int_c(downTrials(1:10)));
bvdown_std = nanstd(mov_int_c(downTrials(1:10)));
mov_int_down_st = (mov_int_c(downTrials) - bvdown_mean)/bvdown_std;

clear bvup_mean; clear bvup_std; clear bvdown_mean; clear bvdown_std;

%% Plotting Code for mov_int
figure
set(gcf,'Color','w','Position',[560 528 600 420])
hold on;

subplot('Position',[0.06 0.2 0.1 0.6]); hold on;
plot(upTrials(1:10),mov_int(upTrials(1:10)),'bo');
hold on
plot(upTrials(1:10),mov_int_c(upTrials(1:10)),'bx');
hold on
plot(downTrials(1:10),mov_int(downTrials(1:10)),'ro');
hold on
plot(downTrials(1:10),mov_int_c(downTrials(1:10)),'rx');
axis([0 20 0 20]); set(gca,'LineWidth',2,'XTick',[1 10 20],'YTick',0:4:20,'YTickLabel',0:4:20,'FontName','Arial','FontSize',10); ylabel('mov_int [cm]'); title('vis-pre','fontsize',11);
hold on
line([0 20],[10 10],'LineStyle','--','Color',[.5 .5 .5])

hold on
subplot('Position',[0.19 0.2 0.1 0.6]); hold on;
plot(upTrials(11:20)-kbTrials(1)+1,mov_int(upTrials(11:20)),'bo');
hold on
plot(upTrials(11:20)-kbTrials(1)+1,mov_int_c(upTrials(11:20)),'bx');
hold on
plot(downTrials(11:20)-kbTrials(1)+1,mov_int(downTrials(11:20)),'ro');
hold on
plot(downTrials(11:20)-kbTrials(1)+1,mov_int_c(downTrials(11:20)),'rx');
axis([0 20 0 20]); set(gca,'LineWidth',2,'XTick',[1 10 20],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title('kin-pre','fontsize',11);
hold on
line([0 20],[10 10],'LineStyle','--','Color',[.5 .5 .5])

hold on
subplot('Position',[0.32 0.2 0.4 0.6]); hold on;
plot(upTrials(22:91)-exTrials(1)+1,mov_int(upTrials(22:91)),'bo');
hold on
plot(upTrials(22:91)-exTrials(1)+1,mov_int_c(upTrials(22:91)),'bx');
hold on
plot(downTrials(22:91)-exTrials(1)+1,mov_int(downTrials(22:91)),'ro');
hold on
plot(downTrials(22:91)-exTrials(1)+1,mov_int_c(downTrials(22:91)),'rx');
axis([0 140 0 20]); set(gca,'LineWidth',2,'XTick',[1 20 70 120 140],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);
hold on
line([0 140],[10 10],'LineStyle','--','Color',[.5 .5 .5])

hold on
subplot('Position',[0.75 0.2 0.24 0.6]); hold on;
plot(upTrials(92:111)-peTrials(1)+1,mov_int(upTrials(92:111)),'bo');
hold on
plot(upTrials(92:111)-peTrials(1)+1,mov_int_c(upTrials(92:111)),'bx');
hold on
plot(downTrials(92:111)-peTrials(1)+1,mov_int(downTrials(92:111)),'ro');
hold on
plot(downTrials(92:111)-peTrials(1)+1,mov_int_c(downTrials(92:111)),'rx');
axis([0 40 0 20]); set(gca,'LineWidth',2,'XTick',[1 20 40],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['post-exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);
hold on
line([0 40],[10 10],'LineStyle','--','Color',[.5 .5 .5])
title('mov_int')

%% Normalized Jerk Score
%%%%%%%%%%%%%%%%%%%%%%% Normalized Jerk %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
acc_tan = cell(numTrials,1);
jerk = cell(numTrials,1);
jerk_square = cell(numTrials,1);
delta_1 = cell(numTrials,1);
jerk_int = zeros(numTrials,1);
norm_jerk = zeros(numTrials,1);
for i = 1:numTrials
    if wrong_trial(i) == 0 && channel_trial(i) == 0
        acc_tan{i,1} = 100*sqrt((sortData(i).Right_HandXAcc).^2 + (sortData(i).Right_HandYAcc).^2); % in cm/s/s
        jerk{i,1} = diff(acc_tan{i,1})/delta_t;
        jerk_square{i,1} = jerk{i,1}.^2;
        delta_1{i,1} = (0:1:(length(jerk_square{i,1}) - 1)) ./fs;
        jerk_int(i) = trapz(delta_1{i,1},jerk_square{i,1}); 
        norm_jerk(i) = sqrt(0.5 *jerk_int(i) * ((MT(i))^5)/ (mov_int(i)^2));
    else
        norm_jerk(i) = NaN;
    end
end

%% norm_jerk outlier analysis
data = outlier_t(norm_jerk(upTrials(1:10))); % Outlier for visual baseline
norm_jerk_c(upTrials(1:10)) = data;
data = outlier_t(norm_jerk(downTrials(1:10)));
norm_jerk_c(downTrials(1:10)) = data;
clear data;

data = outlier_t(norm_jerk(upTrials(11:20))); % Outlier for kin baseline
norm_jerk_c(upTrials(11:20)) = data;
data = outlier_t(norm_jerk(downTrials(11:20)));
norm_jerk_c(downTrials(11:20)) = data;
clear data;

norm_jerk_c(upTrials(21)) = NaN; norm_jerk_c(downTrials(21)) = NaN; % Toss out catch trials

% data = outlier_t(norm_jerk(upTrials(14:23))); % Outlier for first 20 exposure
% norm_jerk_c(upTrials(14:23)) = data;
% data = outlier_t(norm_jerk(downTrials(14:23)));
% norm_jerk_c(downTrials(14:23)) = data;
% clear data;
norm_jerk_c(upTrials(22:31)) = norm_jerk(upTrials(22:31));
norm_jerk_c(downTrials(22:31)) = norm_jerk(downTrials(22:31));

data = outlier_t(norm_jerk(upTrials(32:91))); % Outlier for last 100 exposure
norm_jerk_c(upTrials(32:91)) = data;
data = outlier_t(norm_jerk(downTrials(32:91)));
norm_jerk_c(downTrials(32:91)) = data;
clear data;

data = outlier_t(norm_jerk(upTrials(92:96))); % Outlier for first 10 post-exp
norm_jerk_c(upTrials(92:96)) = data;
data = outlier_t(norm_jerk(downTrials(92:96)));
norm_jerk_c(downTrials(92:96)) = data;
clear data;

data = outlier_t(norm_jerk(upTrials(97:111))); % Outlier for last 10 post-exp
norm_jerk_c(upTrials(97:111)) = data;
data = outlier_t(norm_jerk(downTrials(97:111)));
norm_jerk_c(downTrials(97:111)) = data;
clear data;

% transpose and calculate standardized variable
norm_jerk_c = norm_jerk_c';
bvup_mean = nanmean(norm_jerk_c(upTrials(1:10)));
bvup_std = nanstd(norm_jerk_c(upTrials(1:10)));
norm_jerk_up_st = (norm_jerk_c(upTrials) - bvup_mean)/bvup_std;

bvdown_mean = nanmean(norm_jerk_c(downTrials(1:10)));
bvdown_std = nanstd(norm_jerk_c(downTrials(1:10)));
norm_jerk_down_st = (norm_jerk_c(downTrials) - bvdown_mean)/bvdown_std;

clear bvup_mean; clear bvup_std; clear bvdown_mean; clear bvdown_std;

%% Plotting Code for norm_jerk
figure
set(gcf,'Color','w','Position',[560 528 600 420])
hold on;

subplot('Position',[0.06 0.2 0.1 0.6]); hold on;
plot(upTrials(1:10),norm_jerk(upTrials(1:10)),'bo');
hold on
plot(upTrials(1:10),norm_jerk_c(upTrials(1:10)),'bx');
hold on
plot(downTrials(1:10),norm_jerk(downTrials(1:10)),'ro');
hold on
plot(downTrials(1:10),norm_jerk_c(downTrials(1:10)),'rx');
axis([0 20 0 1000]); set(gca,'LineWidth',2,'XTick',[1 10 20],'YTick',0:100:1000,'YTickLabel',0:100:1000,'FontName','Arial','FontSize',10); ylabel('norm_jerk [unitless]'); title('vis-pre','fontsize',11);

hold on
subplot('Position',[0.19 0.2 0.1 0.6]); hold on;
plot(upTrials(11:20)-kbTrials(1)+1,norm_jerk(upTrials(11:20)),'bo');
hold on
plot(upTrials(11:20)-kbTrials(1)+1,norm_jerk_c(upTrials(11:20)),'bx');
hold on
plot(downTrials(11:20)-kbTrials(1)+1,norm_jerk(downTrials(11:20)),'ro');
hold on
plot(downTrials(11:20)-kbTrials(1)+1,norm_jerk_c(downTrials(11:20)),'rx');
axis([0 20 0 1000]); set(gca,'LineWidth',2,'XTick',[1 10 20],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title('kin-pre','fontsize',11);

hold on
subplot('Position',[0.32 0.2 0.4 0.6]); hold on;
plot(upTrials(22:91)-exTrials(1)+1,norm_jerk(upTrials(22:91)),'bo');
hold on
plot(upTrials(22:91)-exTrials(1)+1,norm_jerk_c(upTrials(22:91)),'bx');
hold on
plot(downTrials(22:91)-exTrials(1)+1,norm_jerk(downTrials(22:91)),'ro');
hold on
plot(downTrials(22:91)-exTrials(1)+1,norm_jerk_c(downTrials(22:91)),'rx');
axis([0 140 0 1000]); set(gca,'LineWidth',2,'XTick',[1 20 70 120 140],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);

hold on
subplot('Position',[0.75 0.2 0.24 0.6]); hold on;
plot(upTrials(92:111)-peTrials(1)+1,norm_jerk(upTrials(92:111)),'bo');
hold on
plot(upTrials(92:111)-peTrials(1)+1,norm_jerk_c(upTrials(92:111)),'bx');
hold on
plot(downTrials(92:111)-peTrials(1)+1,norm_jerk(downTrials(92:111)),'ro');
hold on
plot(downTrials(92:111)-peTrials(1)+1,norm_jerk_c(downTrials(92:111)),'rx');
axis([0 40 0 1000]); set(gca,'LineWidth',2,'XTick',[1 20 40],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['post-exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);
title('norm_jerk')

%% Peak Velocity
velPeak = velPeak * 100; % Convert to cm/s
velPeak(wrong_trial == 1) = NaN;
velPeak(channel_trial == 1) = NaN;

%% Peak Velocity outlier calc
data = outlier_t(velPeak(upTrials(1:10))); % Outlier for visual baseline
velPeak_c(upTrials(1:10)) = data;
data = outlier_t(velPeak(downTrials(1:10)));
velPeak_c(downTrials(1:10)) = data;
clear data;

data = outlier_t(velPeak(upTrials(11:20))); % Outlier for kin baseline
velPeak_c(upTrials(11:20)) = data;
data = outlier_t(velPeak(downTrials(11:20)));
velPeak_c(downTrials(11:20)) = data;
clear data;

velPeak_c(upTrials(21)) = NaN; velPeak_c(downTrials(21)) = NaN; % Toss out catch trials

% data = outlier_t(velPeak(upTrials(14:23))); % Outlier for first 20 exposure
% velPeak_c(upTrials(14:23)) = data;
% data = outlier_t(velPeak(downTrials(14:23)));
% velPeak_c(downTrials(14:23)) = data;
% clear data;
velPeak_c(upTrials(22:31)) = velPeak(upTrials(22:31));
velPeak_c(downTrials(22:31)) = velPeak(downTrials(22:31));

data = outlier_t(velPeak(upTrials(32:91))); % Outlier for last 100 exposure
velPeak_c(upTrials(32:91)) = data;
data = outlier_t(velPeak(downTrials(32:91)));
velPeak_c(downTrials(32:91)) = data;
clear data;

data = outlier_t(velPeak(upTrials(92:96))); % Outlier for first 10 post-exp
velPeak_c(upTrials(92:96)) = data;
data = outlier_t(velPeak(downTrials(92:96)));
velPeak_c(downTrials(92:96)) = data;
clear data;

data = outlier_t(velPeak(upTrials(97:111))); % Outlier for last 10 post-exp
velPeak_c(upTrials(97:111)) = data;
data = outlier_t(velPeak(downTrials(97:111)));
velPeak_c(downTrials(97:111)) = data;
clear data;

% transpose and calculate standardized variable
velPeak_c = velPeak_c';
bvup_mean = nanmean(velPeak_c(upTrials(1:10)));
bvup_std = nanstd(velPeak_c(upTrials(1:10)));
velPeak_up_st = (velPeak_c(upTrials) - bvup_mean)/bvup_std;

bvdown_mean = nanmean(velPeak_c(downTrials(1:10)));
bvdown_std = nanstd(velPeak_c(downTrials(1:10)));
velPeak_down_st = (velPeak_c(downTrials) - bvdown_mean)/bvdown_std;

clear bvup_mean; clear bvup_std; clear bvdown_mean; clear bvdown_std;

%% Plotting Code for velPeak
figure
set(gcf,'Color','w','Position',[560 528 600 420])
hold on;

subplot('Position',[0.06 0.2 0.1 0.6]); hold on;
plot(upTrials(1:10),velPeak(upTrials(1:10)),'bo');
hold on
plot(upTrials(1:10),velPeak_c(upTrials(1:10)),'bx');
hold on
plot(downTrials(1:10),velPeak(downTrials(1:10)),'ro');
hold on
plot(downTrials(1:10),velPeak_c(downTrials(1:10)),'rx');
axis([0 20 0 100]); set(gca,'LineWidth',2,'XTick',[1 10 20],'YTick',0:20:100,'YTickLabel',0:20:100,'FontName','Arial','FontSize',10); ylabel('velPeak [cm/s]'); title('vis-pre','fontsize',11);

hold on
subplot('Position',[0.19 0.2 0.1 0.6]); hold on;
plot(upTrials(11:20)-kbTrials(1)+1,velPeak(upTrials(11:20)),'bo');
hold on
plot(upTrials(11:20)-kbTrials(1)+1,velPeak_c(upTrials(11:20)),'bx');
hold on
plot(downTrials(11:20)-kbTrials(1)+1,velPeak(downTrials(11:20)),'ro');
hold on
plot(downTrials(11:20)-kbTrials(1)+1,velPeak_c(downTrials(11:20)),'rx');
axis([0 20 0 100]); set(gca,'LineWidth',2,'XTick',[1 10 20],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title('kin-pre','fontsize',11);

hold on
subplot('Position',[0.32 0.2 0.4 0.6]); hold on;
plot(upTrials(22:91)-exTrials(1)+1,velPeak(upTrials(22:91)),'bo');
hold on
plot(upTrials(22:91)-exTrials(1)+1,velPeak_c(upTrials(22:91)),'bx');
hold on
plot(downTrials(22:91)-exTrials(1)+1,velPeak(downTrials(22:91)),'ro');
hold on
plot(downTrials(22:91)-exTrials(1)+1,velPeak_c(downTrials(22:91)),'rx');
axis([0 140 0 100]); set(gca,'LineWidth',2,'XTick',[1 20 70 120 140],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);

hold on
subplot('Position',[0.75 0.2 0.24 0.6]); hold on;
plot(upTrials(92:111)-peTrials(1)+1,velPeak(upTrials(92:111)),'bo');
hold on
plot(upTrials(92:111)-peTrials(1)+1,velPeak_c(upTrials(92:111)),'bx');
hold on
plot(downTrials(92:111)-peTrials(1)+1,velPeak(downTrials(92:111)),'ro');
hold on
plot(downTrials(92:111)-peTrials(1)+1,velPeak_c(downTrials(92:111)),'rx');
axis([0 40 0 100]); set(gca,'LineWidth',2,'XTick',[1 20 40],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['post-exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);
title('velPeak')

%% velPeakTime
velPeakTime(wrong_trial == 1) = NaN;
velPeakTime(channel_trial == 1) = NaN;

data = outlier_t(velPeakTime(upTrials(1:10))); % Outlier for visual baseline
velPeakTime_c(upTrials(1:10)) = data;
data = outlier_t(velPeakTime(downTrials(1:10)));
velPeakTime_c(downTrials(1:10)) = data;
clear data;

data = outlier_t(velPeakTime(upTrials(11:20))); % Outlier for kin baseline
velPeakTime_c(upTrials(11:20)) = data;
data = outlier_t(velPeakTime(downTrials(11:20)));
velPeakTime_c(downTrials(11:20)) = data;
clear data;

velPeakTime_c(upTrials(21)) = NaN; velPeakTime_c(downTrials(21)) = NaN; % Toss out catch trials

% data = outlier_t(velPeakTime(upTrials(14:23))); % Outlier for first 20 exposure
% velPeakTime_c(upTrials(14:23)) = data;
% data = outlier_t(velPeakTime(downTrials(14:23)));
% velPeakTime_c(downTrials(14:23)) = data;
% clear data;
velPeakTime_c(upTrials(22:31)) = velPeakTime(upTrials(22:31));
velPeakTime_c(downTrials(22:31)) = velPeakTime(downTrials(22:31));

data = outlier_t(velPeakTime(upTrials(32:91))); % Outlier for last 100 exposure
velPeakTime_c(upTrials(32:91)) = data;
data = outlier_t(velPeakTime(downTrials(32:91)));
velPeakTime_c(downTrials(32:91)) = data;
clear data;

data = outlier_t(velPeakTime(upTrials(92:96))); % Outlier for first 10 post-exp
velPeakTime_c(upTrials(92:96)) = data;
data = outlier_t(velPeakTime(downTrials(92:96)));
velPeakTime_c(downTrials(92:96)) = data;
clear data;

data = outlier_t(velPeakTime(upTrials(97:111))); % Outlier for last 10 post-exp
velPeakTime_c(upTrials(97:111)) = data;
data = outlier_t(velPeakTime(downTrials(97:111)));
velPeakTime_c(downTrials(97:111)) = data;
clear data;

% transpose and calculate standardized variable
velPeakTime_c = velPeakTime_c';
bkup_mean = nanmean(velPeakTime_c(upTrials(11:20)));
bkup_std = nanstd(velPeakTime_c(upTrials(11:20)));
velPeakTime_up_st = (velPeakTime_c(upTrials) - bkup_mean)/bkup_std;

bkdown_mean = nanmean(velPeakTime_c(downTrials(11:20)));
bkdown_std = nanstd(velPeakTime_c(downTrials(11:20)));
velPeakTime_down_st = (velPeakTime_c(downTrials) - bkdown_mean)/bkdown_std;

clear bkup_mean; clear bkup_std; clear bkdown_mean; clear bkdown_std;

%% Plotting Code for velPeakTime
figure
set(gcf,'Color','w','Position',[560 528 600 420])
hold on;

subplot('Position',[0.06 0.2 0.1 0.6]); hold on;
plot(upTrials(1:10),velPeakTime(upTrials(1:10)),'bo');
hold on
plot(upTrials(1:10),velPeakTime_c(upTrials(1:10)),'bx');
hold on
plot(downTrials(1:10),velPeakTime(downTrials(1:10)),'ro');
hold on
plot(downTrials(1:10),velPeakTime_c(downTrials(1:10)),'rx');
axis([0 20 50 500]); set(gca,'LineWidth',2,'XTick',[1 10 20],'YTick',50:50:500,'YTickLabel', 50:50:500,'FontName','Arial','FontSize',10); ylabel('velPeakTime [s]'); title('vis-pre','fontsize',11);

hold on
subplot('Position',[0.19 0.2 0.1 0.6]); hold on;
plot(upTrials(11:20)-kbTrials(1)+1,velPeakTime(upTrials(11:20)),'bo');
hold on
plot(upTrials(11:20)-kbTrials(1)+1,velPeakTime_c(upTrials(11:20)),'bx');
hold on
plot(downTrials(11:20)-kbTrials(1)+1,velPeakTime(downTrials(11:20)),'ro');
hold on
plot(downTrials(11:20)-kbTrials(1)+1,velPeakTime_c(downTrials(11:20)),'rx');
axis([0 20 50 500]); set(gca,'LineWidth',2,'XTick',[1 10 20],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title('kin-pre','fontsize',11);

hold on
subplot('Position',[0.32 0.2 0.4 0.6]); hold on;
plot(upTrials(22:91)-exTrials(1)+1,velPeakTime(upTrials(22:91)),'bo');
hold on
plot(upTrials(22:91)-exTrials(1)+1,velPeakTime_c(upTrials(22:91)),'bx');
hold on
plot(downTrials(22:91)-exTrials(1)+1,velPeakTime(downTrials(22:91)),'ro');
hold on
plot(downTrials(22:91)-exTrials(1)+1,velPeakTime_c(downTrials(22:91)),'rx');
axis([0 140 50 500]); set(gca,'LineWidth',2,'XTick',[1 20 70 120 140],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);

hold on
subplot('Position',[0.75 0.2 0.24 0.6]); hold on;
plot(upTrials(92:111)-peTrials(1)+1,velPeakTime(upTrials(92:111)),'bo');
hold on
plot(upTrials(92:111)-peTrials(1)+1,velPeakTime_c(upTrials(92:111)),'bx');
hold on
plot(downTrials(92:111)-peTrials(1)+1,velPeakTime(downTrials(92:111)),'ro');
hold on
plot(downTrials(92:111)-peTrials(1)+1,velPeakTime_c(downTrials(92:111)),'rx');
axis([0 40 50 500]); set(gca,'LineWidth',2,'XTick',[1 20 40],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['post-exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);
title([subID(7:9), ' ', 'velPeakTime'])

%% Reaction Time (ms)
for i = 1:numTrials
    if wrong_trial(i) == 0 && channel_trial(i) == 0
        RT(i) = onset(i) - sortData(i).EVENTS.TIMES(2)*1000; % Event Code 2 occurs when the targets turn on (measured relative to when hands are statioary in the home positions)
    else
        RT(i) = NaN;
    end
end
RT(wrong_trial == 1) = NaN;
RT(channel_trial == 1) = NaN;

data = outlier_t(RT(upTrials(1:10))); % Outlier for visual baseline
RT_c(upTrials(1:10)) = data;
data = outlier_t(RT(downTrials(1:10)));
RT_c(downTrials(1:10)) = data;
clear data;

data = outlier_t(RT(upTrials(11:20))); % Outlier for kin baseline
RT_c(upTrials(11:20)) = data;
data = outlier_t(RT(downTrials(11:20)));
RT_c(downTrials(11:20)) = data;
clear data;

RT_c(upTrials(21)) = NaN; RT_c(downTrials(21)) = NaN; % Toss out catch trials

% data = outlier_t(RT(upTrials(14:23))); % Outlier for first 20 exposure
% RT_c(upTrials(14:23)) = data;
% data = outlier_t(RT(downTrials(14:23)));
% RT_c(downTrials(14:23)) = data;
% clear data;
RT_c(upTrials(22:31)) = RT(upTrials(22:31));
RT_c(downTrials(22:31)) = RT(downTrials(22:31));

data = outlier_t(RT(upTrials(32:91))); % Outlier for last 100 exposure
RT_c(upTrials(32:91)) = data;
data = outlier_t(RT(downTrials(32:91)));
RT_c(downTrials(32:91)) = data;
clear data;

data = outlier_t(RT(upTrials(92:96))); % Outlier for first 10 post-exp
RT_c(upTrials(92:96)) = data;
data = outlier_t(RT(downTrials(92:96)));
RT_c(downTrials(92:96)) = data;
clear data;

data = outlier_t(RT(upTrials(97:111))); % Outlier for last 10 post-exp
RT_c(upTrials(97:111)) = data;
data = outlier_t(RT(downTrials(97:111)));
RT_c(downTrials(97:111)) = data;
clear data;

% transpose and calculate standardized variable
RT_c = RT_c';
bkup_mean = nanmean(RT_c(upTrials(11:20)));
bkup_std = nanstd(RT_c(upTrials(11:20)));
RT_up_st = (RT_c(upTrials) - bkup_mean)/bkup_std;

bkdown_mean = nanmean(RT_c(downTrials(11:20)));
bkdown_std = nanstd(RT_c(downTrials(11:20)));
RT_down_st = (RT_c(downTrials) - bkdown_mean)/bkdown_std;

clear bkup_mean; clear bkup_std; clear bkdown_mean; clear bkdown_std;
RT = RT';

%% Plotting Code for RT
figure
set(gcf,'Color','w','Position',[560 528 600 420])
hold on;

subplot('Position',[0.06 0.2 0.1 0.6]); hold on;
plot(upTrials(1:10),RT(upTrials(1:10)),'bo');
hold on
plot(upTrials(1:10),RT_c(upTrials(1:10)),'bx');
hold on
plot(downTrials(1:10),RT(downTrials(1:10)),'ro');
hold on
plot(downTrials(1:10),RT_c(downTrials(1:10)),'rx');
axis([0 20 0 1000]); set(gca,'LineWidth',2,'XTick',[1 10 20],'YTick',0:100:1000,'YTickLabel', 0:100:1000,'FontName','Arial','FontSize',10); ylabel('RT [s]'); title('vis-pre','fontsize',11);

hold on
subplot('Position',[0.19 0.2 0.1 0.6]); hold on;
plot(upTrials(11:20)-kbTrials(1)+1,RT(upTrials(11:20)),'bo');
hold on
plot(upTrials(11:20)-kbTrials(1)+1,RT_c(upTrials(11:20)),'bx');
hold on
plot(downTrials(11:20)-kbTrials(1)+1,RT(downTrials(11:20)),'ro');
hold on
plot(downTrials(11:20)-kbTrials(1)+1,RT_c(downTrials(11:20)),'rx');
axis([0 20 0 1000]); set(gca,'LineWidth',2,'XTick',[1 10 20],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title('kin-pre','fontsize',11);

hold on
subplot('Position',[0.32 0.2 0.4 0.6]); hold on;
plot(upTrials(22:91)-exTrials(1)+1,RT(upTrials(22:91)),'bo');
hold on
plot(upTrials(22:91)-exTrials(1)+1,RT_c(upTrials(22:91)),'bx');
hold on
plot(downTrials(22:91)-exTrials(1)+1,RT(downTrials(22:91)),'ro');
hold on
plot(downTrials(22:91)-exTrials(1)+1,RT_c(downTrials(22:91)),'rx');
axis([0 140 0 1000]); set(gca,'LineWidth',2,'XTick',[1 20 70 120 140],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);

hold on
subplot('Position',[0.75 0.2 0.24 0.6]); hold on;
plot(upTrials(92:111)-peTrials(1)+1,RT(upTrials(92:111)),'bo');
hold on
plot(upTrials(92:111)-peTrials(1)+1,RT_c(upTrials(92:111)),'bx');
hold on
plot(downTrials(92:111)-peTrials(1)+1,RT(downTrials(92:111)),'ro');
hold on
plot(downTrials(92:111)-peTrials(1)+1,RT_c(downTrials(92:111)),'rx');
axis([0 40 0 1000]); set(gca,'LineWidth',2,'XTick',[1 20 40],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['post-exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);
title([subID(7:9), ' ', 'RT'])

%% Movement Path Plots
ang = 0:0.1:2.01*pi;
r = sortData(1).TARGET_TABLE.VRad(2);
figure
subplot(2,3,1)
for i = 1:20
    if wrong_trial(i) == 0
        plot(cursorPosX{i,1}(onset(i):offset(i))*100 - Tx, cursorPosY{i,1}(onset(i):offset(i))*100 - Ty)
        hold on
    end
end
axis([-6.5 23.5 -15 15]); set(gca,'LineWidth',2,'XTick',[-6.5 8.5 23.5],'YTick',[-15 -10 0 10 15],'YTickLabel',[-15 -10 0 10 15],'FontName','Arial','FontSize',10); title('vis-pre','fontsize',11);
axis square
hold on
plot(sortData(1).TARGET_TABLE.X(2)+r*cos(ang),sortData(1).TARGET_TABLE.Y(2)+r*sin(ang),'Color',[255/255 117/255 56/255]) %home position
hold on
plot(sortData(1).TARGET_TABLE.X(3)+r*cos(ang),sortData(1).TARGET_TABLE.Y(3)+r*sin(ang),'r')
hold on
plot(sortData(1).TARGET_TABLE.X(4)+r*cos(ang),sortData(1).TARGET_TABLE.Y(4)+r*sin(ang),'r')

subplot(2,3,2)
for i = 21:40
    if wrong_trial(i) == 0
        plot(cursorPosX{i,1}(onset(i):offset(i))*100 - Tx, cursorPosY{i,1}(onset(i):offset(i))*100 - Ty)
        hold on
    end
end
axis([-6.5 23.5 -15 15]); set(gca,'LineWidth',2,'XTick',[-6.5 8.5 23.5],'YTick',[-15 -10 0 10 15],'YTickLabel',[-15 -10 0 10 15],'FontName','Arial','FontSize',10); title('kin-pre','fontsize',11);
axis square
hold on
plot(sortData(1).TARGET_TABLE.X(2)+r*cos(ang),sortData(1).TARGET_TABLE.Y(2)+r*sin(ang),'Color',[255/255 117/255 56/255]) %home position
hold on
plot(sortData(1).TARGET_TABLE.X(3)+r*cos(ang),sortData(1).TARGET_TABLE.Y(3)+r*sin(ang),'r')
hold on
plot(sortData(1).TARGET_TABLE.X(4)+r*cos(ang),sortData(1).TARGET_TABLE.Y(4)+r*sin(ang),'r')

subplot(2,3,3)
for i = 43:52
    if wrong_trial(i) == 0
        plot(cursorPosX{i,1}(onset(i):offset(i))*100 - Tx, cursorPosY{i,1}(onset(i):offset(i))*100 - Ty)
        hold on
    end
end
axis([-6.5 23.5 -15 15]); set(gca,'LineWidth',2,'XTick',[-6.5 8.5 23.5],'YTick',[-15 -10 0 10 15],'YTickLabel',[-15 -10 0 10 15],'FontName','Arial','FontSize',10); title('Early Exposure','fontsize',11);
axis square
hold on
plot(sortData(1).TARGET_TABLE.X(2)+r*cos(ang),sortData(1).TARGET_TABLE.Y(2)+r*sin(ang),'Color',[255/255 117/255 56/255]) %home position
hold on
plot(sortData(1).TARGET_TABLE.X(3)+r*cos(ang),sortData(1).TARGET_TABLE.Y(3)+r*sin(ang),'r')
hold on
plot(sortData(1).TARGET_TABLE.X(4)+r*cos(ang),sortData(1).TARGET_TABLE.Y(4)+r*sin(ang),'r')

subplot(2,3,4)
for i = 173:182
    if wrong_trial(i) == 0
        plot(cursorPosX{i,1}(onset(i):offset(i))*100 - Tx, cursorPosY{i,1}(onset(i):offset(i))*100 - Ty)
        hold on
    end
end
axis([-6.5 23.5 -15 15]); set(gca,'LineWidth',2,'XTick',[-6.5 8.5 23.5],'YTick',[-15 -10 0 10 15],'YTickLabel',[-15 -10 0 10 15],'FontName','Arial','FontSize',10); title('Late Exposure','fontsize',11);
axis square
hold on
plot(sortData(1).TARGET_TABLE.X(2)+r*cos(ang),sortData(1).TARGET_TABLE.Y(2)+r*sin(ang),'Color',[255/255 117/255 56/255]) %home position
hold on
plot(sortData(1).TARGET_TABLE.X(3)+r*cos(ang),sortData(1).TARGET_TABLE.Y(3)+r*sin(ang),'r')
hold on
plot(sortData(1).TARGET_TABLE.X(4)+r*cos(ang),sortData(1).TARGET_TABLE.Y(4)+r*sin(ang),'r')

subplot(2,3,5)
for i = 183:192
    if wrong_trial(i) == 0
        plot(cursorPosX{i,1}(onset(i):offset(i))*100 - Tx, cursorPosY{i,1}(onset(i):offset(i))*100 - Ty)
        hold on
    end
end
axis([-6.5 23.5 -15 15]); set(gca,'LineWidth',2,'XTick',[-6.5 8.5 23.5],'YTick',[-15 -10 0 10 15],'YTickLabel',[-15 -10 0 10 15],'FontName','Arial','FontSize',10); title('Early Post-Exposure','fontsize',11);
axis square
hold on
plot(sortData(1).TARGET_TABLE.X(2)+r*cos(ang),sortData(1).TARGET_TABLE.Y(2)+r*sin(ang),'Color',[255/255 117/255 56/255]) %home position
hold on
plot(sortData(1).TARGET_TABLE.X(3)+r*cos(ang),sortData(1).TARGET_TABLE.Y(3)+r*sin(ang),'r')
hold on
plot(sortData(1).TARGET_TABLE.X(4)+r*cos(ang),sortData(1).TARGET_TABLE.Y(4)+r*sin(ang),'r')

subplot(2,3,6)
for i = 213:222
    if wrong_trial(i) == 0
        plot(cursorPosX{i,1}(onset(i):offset(i))*100 - Tx, cursorPosY{i,1}(onset(i):offset(i))*100 - Ty)
        hold on
    end
end
axis([-6.5 23.5 -15 15]); set(gca,'LineWidth',2,'XTick',[-6.5 8.5 23.5],'YTick',[-15 -10 0 10 15],'YTickLabel',[-15 -10 0 10 15],'FontName','Arial','FontSize',10); title('Late Post-Exposure','fontsize',11);
axis square
hold on
plot(sortData(1).TARGET_TABLE.X(2)+r*cos(ang),sortData(1).TARGET_TABLE.Y(2)+r*sin(ang),'Color',[255/255 117/255 56/255]) %home position
hold on
plot(sortData(1).TARGET_TABLE.X(3)+r*cos(ang),sortData(1).TARGET_TABLE.Y(3)+r*sin(ang),'r')
hold on
plot(sortData(1).TARGET_TABLE.X(4)+r*cos(ang),sortData(1).TARGET_TABLE.Y(4)+r*sin(ang),'r')

%% Data Export
%switch Directory
if strcmp(str,'MACI64') == 1
    cd(['/Volumes/mnl/Data/Adaptation/interference_dosing/Post_Step_2']);
else
    %cd(['Z:\Data\Adaptation\interference_dosing\Post_Step_2']); % Lab PCs
    cd(['C:\Users\Alex\Desktop\IFDosing\Post_Step_2']); % Home PC
end

save([subID '_postStep2_rh' '.mat'],'sortData','downTrials','upTrials','fname','onset','offset','wrong_trial','channel_trial','EP_X', 'EP_X_c', 'EP_X_down_st', 'EP_X_up_st',...
    'EP_Y', 'EP_Y_c', 'EP_Y_down_st', 'EP_Y_up_st',...
    'EPE', 'EPE_c', 'EPE_down_st', 'EPE_up_st',...
    'ide', 'ide_c', 'ide_down_st', 'ide_up_st',...
    'ede', 'ede_c', 'ede_down_st', 'ede_up_st',...
    'mov_int', 'mov_int_c', 'mov_int_down_st', 'mov_int_up_st',...
    'MT', 'MT_c', 'MT_down_st', 'MT_up_st',...
    'norm_jerk', 'norm_jerk_c', 'norm_jerk_down_st', 'norm_jerk_up_st',...
    'rmse', 'rmse_c', 'rmse_down_st', 'rmse_up_st',...
    'velPeak', 'velPeak_c', 'velPeak_down_st', 'velPeak_up_st',...
    'velPeakTime', 'velPeakTime_c', 'velPeakTime_down_st', 'velPeakTime_up_st',...
    'RT', 'RT_c', 'RT_down_st', 'RT_up_st')