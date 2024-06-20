%% This loads in the .mat file generated in step 1
% will process the time-series force channel data
% Force data are filtered in step 1 per BKIN's c3d_filter, just need to
% resample the data to 1000ms and create within subject averages for the
% exposure blocks

clear all
close all

% Select the subject file
str = computer;
if strcmp(str,'MACI64') == 1
    cd('/Volumes/mnl/Data/Adaptation/interference_dosing/Post_Step_1');
    fname = uigetfile('*lh.mat');
    fname = fname(1:22);
    fcTrials = xlsread('/Volumes/mnl/Data/Adaptation/interference_dosing/Force_Channel_Trials_12_03_16.xlsx','Sheet1');
else
    cd('Z:\Data\Adaptation\interference_dosing\Post_Step_1\');
    fname = uigetfile('*lh.mat');
    fname = fname(1:22);
    fcTrials = xlsread('Z:\Data\Adaptation\interference_dosing\Force_Channel_Trials_12_03_16.xlsx','Sheet1');
end

load([fname '.mat']);
subID = fname(7:9);
group = subID(1);

numTrials = size(sortData,1); % Number of Trials

% toss out trials 41 and 42, these are transition trials between
% kinesthetic and kin+rotation
wrong_trial(41) = 1;
wrong_trial(42) = 1;

% Write a boolean for the force channel trials
channel_trial = zeros(1,numTrials);
channel_trial(fcTrials) = 1;

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
    numDataPoints(i) = size(sortData(i).Left_HandX,1); % Number of Data points in each trial
end

%% Plot FC data, then take averages for the blocks FOR FORCE SENSOR
forceTS = cell(numTrials,1);

% forceTS includes the force command data for ALL trials from movement
% onset to offset
for i = 1:numTrials
    if wrong_trial(i) == 0
        forceTS{i,1} = sortData(i).Left_FS_ForceX(onset(i):offset(i));
    else
        forceTS{i,1} = NaN;
    end
end


% Resample so each trial lasts 1000ms (USING interp1)
forceTSRS = zeros(numTrials,1000);
for i = 1:numTrials
    if wrong_trial(i) == 0
        x = 1:1:length(forceTS{i,1});
        y = forceTS{i,1};
        xi = 1:length(x)/1000:length(x);
        temp = interp1(x,y,xi);
        if length(temp) == 1000
            forceTSRS(i,:) = temp;
        else
            padlen = 1000 - length(temp); % Some really short trials (<500 ms) get extrapolated to only 998 or even 997 trials. This will find out how 'short' the extrap is, and pads with the appropriate number of the end of the trial.
            pad = repmat(temp(end),1,padlen);
            forceTSRS(i,:) = [temp pad]; % Trials that last <1000 ms only get extrapolated to 999 samples. This fills in the 1000th value with a repeat of the 999th.
        end
    else
        forceTSRS(i,:) = NaN;
    end
end
% Rectify
forceTSRS = abs(forceTSRS);

% Average the blocks
temp = zeros(numTrials,1000);
for i = 1:numTrials
    if wrong_trial(i) == 0
        temp(i,:) = forceTSRS(i,:); % makes a 222x1000 matrix containing the FC data
    else
        temp(i,:) = NaN;
    end
end

bk1 = temp(fcTrials(13:19),:);
bk1mean = nanmean(bk1,1);

bk2 = temp(fcTrials(20:26),:);
bk2mean = nanmean(bk2,1);

bk3 = temp(fcTrials(27:33),:);
bk3mean = nanmean(bk3,1);

bk4 = temp(fcTrials(34:40),:);
bk4mean = nanmean(bk4,1);
clear temp

% Find the force time series data for only FC trials (export this one!)
forceFS = zeros(length(fcTrials),1000);
for i = 1:length(fcTrials)
    forceFS(i,:) = forceTSRS(fcTrials(i),:);
end
clear temp

% figure
% subplot(2,4,1)
% for i = 13:19
%     hold on
%     if wrong_trial(fcTrials(i)) == 0
%     plot(forceTSRS(fcTrials(i),:))
%     end
% end
% title([subID,' ','EX block 1 - FS'])
% 
% subplot(2,4,2)
% for i = 20:26
%     hold on
%     if wrong_trial(fcTrials(i)) == 0
%     plot(forceTSRS(fcTrials(i),:))
%     end
% end
% title([subID,' ','EX block 2'])
% 
% subplot(2,4,3)
% for i = 27:33
%     hold on
%     if wrong_trial(fcTrials(i)) == 0
%     plot(forceTSRS(fcTrials(i),:))
%     end
% end
% title([subID,' ','EX block 3'])
% 
% subplot(2,4,4)
% for i = 34:40
%     hold on
%     if wrong_trial(fcTrials(i)) == 0
%     plot(forceTSRS(fcTrials(i),:))
%     end
% end
% title([subID,' ','EX block 4'])
% 
% subplot(2,4,5)
% plot(bk1mean)
% 
% subplot(2,4,6)
% plot(bk2mean)
% 
% subplot(2,4,7)
% plot(bk3mean)
% 
% subplot(2,4,8)
% plot(bk4mean)



%% Plot FC data, then take averages for the blocks FOR CMD
forceTS = cell(numTrials,1);

% forceTS includes the force command data for ALL trials from movement
% onset to offset
for i = 1:numTrials
    if wrong_trial(i) == 0
        forceTS{i,1} = sortData(i).Left_Hand_ForceCMD_X(onset(i):offset(i));
    else
        forceTS{i,1} = NaN;
    end
end

% Resample so each trial lasts 1000ms (USING interp1)
forceTSRS = zeros(numTrials,1000);
for i = 1:numTrials
    if wrong_trial(i) == 0
        x = 1:1:length(forceTS{i,1});
        y = forceTS{i,1};
        xi = 1:length(x)/1000:length(x);
        temp = interp1(x,y,xi);
        if length(temp) == 1000
            forceTSRS(i,:) = temp;
        else
            padlen = 1000 - length(temp); % Some really short trials (<500 ms) get extrapolated to only 998 or even 997 trials. This will find out how 'short' the extrap is, and pads with the appropriate number of the end of the trial.
            pad = repmat(temp(end),1,padlen);
            forceTSRS(i,:) = [temp pad]; % Trials that last <1000 ms only get extrapolated to 999 samples. This fills in the 1000th value with a repeat of the 999th.
        end
    else
        forceTSRS(i,:) = NaN;
    end
end
% Rectify
forceTSRS = abs(forceTSRS);

% Average the blocks
temp = zeros(numTrials,1000);
for i = 1:numTrials
    if wrong_trial(i) == 0
        temp(i,:) = forceTSRS(i,:); % makes a 222x1000 matrix containing the FC data
    else
        temp(i,:) = NaN;
    end
end

bk1 = temp(fcTrials(13:19),:);
bk1mean = nanmean(bk1,1);

bk2 = temp(fcTrials(20:26),:);
bk2mean = nanmean(bk2,1);

bk3 = temp(fcTrials(27:33),:);
bk3mean = nanmean(bk3,1);

bk4 = temp(fcTrials(34:40),:);
bk4mean = nanmean(bk4,1);
clear temp

% Find the force time series data for only FC trials (export this one!)
% Find the force time series data for only FC trials (export this one!)
forceCMD = zeros(length(fcTrials),1000);
for i = 1:length(fcTrials)
    forceCMD(i,:) = forceTSRS(fcTrials(i),:);
end
clear temp

% figure
% subplot(2,4,1)
% for i = 13:19
%     hold on
%     if wrong_trial(fcTrials(i)) == 0
%     plot(forceTSRS(fcTrials(i),:))
%     end
% end
% title([subID,' ','EX block 1 - CMD'])
% 
% subplot(2,4,2)
% for i = 20:26
%     hold on
%     if wrong_trial(fcTrials(i)) == 0
%     plot(forceTSRS(fcTrials(i),:))
%     end
% end
% title([subID,' ','EX block 2'])
% 
% subplot(2,4,3)
% for i = 27:33
%     hold on
%     if wrong_trial(fcTrials(i)) == 0
%     plot(forceTSRS(fcTrials(i),:))
%     end
% end
% title([subID,' ','EX block 3'])
% 
% subplot(2,4,4)
% for i = 34:40
%     hold on
%     if wrong_trial(fcTrials(i)) == 0
%     plot(forceTSRS(fcTrials(i),:))
%     end
% end
% title([subID,' ','EX block 4'])
% 
% subplot(2,4,5)
% plot(bk1mean)
% 
% subplot(2,4,6)
% plot(bk2mean)
% 
% subplot(2,4,7)
% plot(bk3mean)
% 
% subplot(2,4,8)
% plot(bk4mean)

temp = zeros(48,1);
temp(:,1) = str2num(subID);
subjectID = temp;
wrong_trial_export = wrong_trial(fcTrials);
upBool_export = upBool(fcTrials)';

%% Data Export
%switch Directory
if strcmp(str,'MACI64') == 1
    cd(['/Volumes/mnl/Data/Adaptation/interference_dosing/Post_Step_2_FC']);
else
    cd(['Z:\Data\Adaptation\interference_dosing\Post_Step_2_FC']);
end
save([subID '_postStep2_lh_fc_FS' '.mat'],'subjectID', 'upBool_export', 'wrong_trial_export', 'forceFS')
save([subID '_postStep2_lh_fc_CMD' '.mat'],'subjectID', 'upBool_export', 'wrong_trial_export', 'forceCMD')