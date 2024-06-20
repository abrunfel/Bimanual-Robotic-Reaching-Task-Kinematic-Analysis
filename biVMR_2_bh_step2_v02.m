%% Intermanual Coordination Analysis
% This will read in the X & Y hand position and resample to 1000ms... then
% calculate the distance per % of movement completed. Then, the hand speed
% will be calculated. Also, the difference in distance travelled between hands R-L.
%These 5 variables will be exported to one .mat file for use in step3.
clear all
close all

%% Load in Data
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

lh = load([fname '.mat']);
rh = load([fname(1:20) 'rh' '.mat']);
subID = fname(7:9);
group = subID(1);

numTrials = size(lh.sortData,1); % Number of Trials

% toss out trials 41 and 42, these are transition trials between
% kinesthetic and kin+rotation
lh.wrong_trial(41) = 1;
lh.wrong_trial(42) = 1;
rh.wrong_trial(41) = 1;
rh.wrong_trial(42) = 1;

% mark FC trials as "wrong_trials". This will exclude them from analysis.
lh.wrong_trial(fcTrials) = 1;
rh.wrong_trial(fcTrials) = 1;


%% Create arrays for Left and Right hand X and Y locations. Resample to 1000ms

lhX = cell(numTrials,1);
lhY = cell(numTrials,1);
for i = 1:numTrials
    if lh.wrong_trial(i) == 0
        lhX{i,1} = lh.sortData(i).Left_HandX(lh.onset(i):lh.offset(i));
        lhY{i,1} = lh.sortData(i).Left_HandY(lh.onset(i):lh.offset(i));
    else
        lhX{i,1} = NaN;
        lhY{i,1} = NaN;
    end
end

% Resample so each trial lasts 1000ms (USING interp1)
lhXrs = zeros(numTrials,1000);
for i = 1:numTrials
    if lh.wrong_trial(i) == 0
        x = 1:1:length(lhX{i,1});
        y = lhX{i,1};
        xi = 1:length(x)/1000:length(x);
        temp = interp1(x,y,xi);
        if length(temp) == 1000
            lhXrs(i,:) = temp;
        else
            padlen = 1000 - length(temp); % Some really short trials (<500 ms) get extrapolated to only 998 or even 997 trials. This will find out how 'short' the extrap is, and pads with the appropriate number of the end of the trial.
            pad = repmat(temp(end),1,padlen);
            lhXrs(i,:) = [temp pad]; % Trials that last <1000 ms only get extrapolated to 999 samples. This fills in the 1000th value with a repeat of the 999th.
        end
    else
        lhXrs(i,:) = NaN;
    end
end

lhYrs = zeros(numTrials,1000);
for i = 1:numTrials
    if lh.wrong_trial(i) == 0
        x = 1:1:length(lhY{i,1});
        y = lhY{i,1};
        xi = 1:length(x)/1000:length(x);
        temp = interp1(x,y,xi);
        if length(temp) == 1000
            lhYrs(i,:) = temp;
        else
            padlen = 1000 - length(temp); % Some really short trials (<500 ms) get extrapolated to only 998 or even 997 trials. This will find out how 'short' the extrap is, and pads with the appropriate number of the end of the trial.
            pad = repmat(temp(end),1,padlen);
            lhYrs(i,:) = [temp pad]; % Trials that last <1000 ms only get extrapolated to 999 samples. This fills in the 1000th value with a repeat of the 999th.
        end
    else
        lhYrs(i,:) = NaN;
    end
end

% Do the same biz to the right hand
rhX = cell(numTrials,1);
rhY = cell(numTrials,1);
for i = 1:numTrials
    if rh.wrong_trial(i) == 0
        rhX{i,1} = rh.sortData(i).Right_HandX(rh.onset(i):rh.offset(i));
        rhY{i,1} = rh.sortData(i).Right_HandY(rh.onset(i):rh.offset(i));
    else
        rhX{i,1} = NaN;
        rhY{i,1} = NaN;
    end
end

rhXrs = zeros(numTrials,1000);
for i = 1:numTrials
    if rh.wrong_trial(i) == 0
        x = 1:1:length(rhX{i,1});
        y = rhX{i,1};
        xi = 1:length(x)/1000:length(x);
        temp = interp1(x,y,xi);
        if length(temp) == 1000
            rhXrs(i,:) = temp;
        else
            padlen = 1000 - length(temp); % Some really short trials (<500 ms) get extrapolated to only 998 or even 997 trials. This will find out how 'short' the extrap is, and pads with the appropriate number of the end of the trial.
            pad = repmat(temp(end),1,padlen);
            rhXrs(i,:) = [temp pad]; % Trials that last <1000 ms only get extrapolated to 999 samples. This fills in the 1000th value with a repeat of the 999th.
        end
    else
        rhXrs(i,:) = NaN;
    end
end

rhYrs = zeros(numTrials,1000);
for i = 1:numTrials
    if rh.wrong_trial(i) == 0
        x = 1:1:length(rhY{i,1});
        y = rhY{i,1};
        xi = 1:length(x)/1000:length(x);
        temp = interp1(x,y,xi);
        if length(temp) == 1000
            rhYrs(i,:) = temp;
        else
            padlen = 1000 - length(temp); % Some really short trials (<500 ms) get extrapolated to only 998 or even 997 trials. This will find out how 'short' the extrap is, and pads with the appropriate number of the end of the trial.
            pad = repmat(temp(end),1,padlen);
            rhYrs(i,:) = [temp pad]; % Trials that last <1000 ms only get extrapolated to 999 samples. This fills in the 1000th value with a repeat of the 999th.
        end
    else
        rhYrs(i,:) = NaN;
    end
end


%% Calculate the distance travelled over the course of the movement.
%Left Hand
lhd = zeros(numTrials,1000); % Non-normalized to move length
LHD = zeros(numTrials,1000); % Normalize to move length (expressed as % of movement)
for i = 1:numTrials
    for j = 2:1000
        if lh.wrong_trial(i) == 1 || rh.wrong_trial(i) == 1
            lhd(i,1) = NaN; % Set initial distance to NaN
        else
            lhd(i,1) = 0;  % Set initial distance to 0
        end
        lhd(i,j) = sqrt((lhXrs(i,j)-lhXrs(i,j-1))^2 + (lhYrs(i,j)-lhYrs(i,j-1))^2);
    end
    LHD(i,:) = cumsum(lhd(i,:));
    LHD(i,:) = LHD(i,:)/LHD(i,end);
end

% Right hand
rhd = zeros(numTrials,1000); % Non-normalized to move length
RHD = zeros(numTrials,1000); % Normalize to move length (expressed as % of movement)
for i = 1:numTrials
    for j = 2:1000
        if lh.wrong_trial(i) == 1 || rh.wrong_trial(i) == 1
            rhd(i,1) = NaN; % Set initial distance to NaN
        else
            rhd(i,1) = 0;  % Set initial distance to 0
        end
        rhd(i,j) = sqrt((rhXrs(i,j)-rhXrs(i,j-1))^2 + (rhYrs(i,j)-rhYrs(i,j-1))^2);
    end
    RHD(i,:) = cumsum(rhd(i,:));
    RHD(i,:) = RHD(i,:)/RHD(i,end);
end


% Compute normalized hand speed
LHV = diff(LHD,1,2);
LHV(:,1000) = 0; % Force the final hand speed to 0 so these are same length as distance
RHV = diff(RHD,1,2);
RHV(:,1000) = 0;


%% Plot Grouped trials
vb = 1:20;
kb = 21:40;
ex_early = 43:62;
ex_late = 164:183;

% Hand displacement
lhvb_meanD = nanmean(LHD(vb,:),1);
lhkb_meanD = nanmean(LHD(kb,:),1);
lhearly_meanD = nanmean(LHD(ex_early,:),1);
lhlate_meanD = nanmean(LHD(ex_late,:),1);

% Hand "speed"
lhvb_meanV = nanmean(LHV(vb,:),1);
lhkb_meanV = nanmean(LHV(kb,:),1);
lhearly_meanV = nanmean(LHV(ex_early,:),1);
lhlate_meanV = nanmean(LHV(ex_late,:),1);

figure
plot(lhvb_meanD,'b')
hold on
plot(lhkb_meanD,'r')
hold on
plot(lhearly_meanD,'g')
hold on
plot(lhlate_meanD,'m')

figure
plot(lhvb_meanV,'b')
hold on
plot(lhkb_meanV,'r')
hold on
plot(lhearly_meanV,'g')
hold on
plot(lhlate_meanV,'m')


rhvb_meanD = nanmean(RHD(vb,:),1);
rhkb_meanD = nanmean(RHD(kb,:),1);
rhearly_meanD = nanmean(RHD(ex_early,:),1);
rhlate_meanD = nanmean(RHD(ex_late,:),1);

rhvb_meanV = nanmean(RHV(vb,:),1);
rhkb_meanV = nanmean(RHV(kb,:),1);
rhearly_meanV = nanmean(RHV(ex_early,:),1);
rhlate_meanV = nanmean(RHV(ex_late,:),1);

figure
plot(rhvb_meanD,'b')
hold on
plot(rhkb_meanD,'r')
hold on
plot(rhearly_meanD,'g')
hold on
plot(rhlate_meanD,'m')

figure
plot(rhvb_meanV,'b')
hold on
plot(rhkb_meanV,'r')
hold on
plot(rhearly_meanV,'g')
hold on
plot(rhlate_meanV,'m')

% Plotting the lh and rh on the same plot. Could also consider calculating
% the difference?
figure
plot(rhearly_meanD-lhearly_meanD,'b')

%% Data Export
Distance_diff = RHD - LHD; % Get the difference in % of movement completed
temp = zeros(numTrials*5,1);
temp(:,1) = str2num(subID);
subjectID = temp; clear temp
temp = zeros(numTrials*5,1);
temp(:,1) = str2num(group);
gr = temp; clear temp

%switch Directory
if strcmp(str,'MACI64') == 1
    cd(['/Volumes/mnl/Data/Adaptation/interference_dosing/Post_Step_2_BH']);
else
    cd(['Z:\Data\Adaptation\interference_dosing\Post_Step_2_BH']);
end

save([subID '_postStep2_BH' '.mat'], 'subjectID', 'gr', 'LHD', 'RHD', 'LHV', 'RHV', 'Distance_diff')