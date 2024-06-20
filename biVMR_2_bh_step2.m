%% Intermanual Coordination Analysis
% This will read in the X & Y hand position and resample to 1000ms... then
% calculate the distance per % of movement completed.
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

% Resample so each trial lasts 1000ms
padlen = 20;
lhXrs = cell(numTrials,1);
lhYrs = cell(numTrials,1);
for i = 1:numTrials
    tempX{i,1} = resample([repmat(lhX{i,1}(1), 1, padlen)'; lhX{i,1}; repmat(lhX{i,1}(end), 1, padlen)'], 1000+2*padlen, length([repmat(lhX{i,1}(1), 1, padlen)'; lhX{i,1}; repmat(lhX{i,1}(end), 1, padlen)']));
    lhXrs{i,1} = tempX{i,1}(padlen:end-padlen);
    tempY{i,1} = resample([repmat(lhY{i,1}(1), 1, padlen)'; lhY{i,1}; repmat(lhY{i,1}(end), 1, padlen)'], 1000+2*padlen, length([repmat(lhX{i,1}(1), 1, padlen)'; lhX{i,1}; repmat(lhX{i,1}(end), 1, padlen)']));
    lhYrs{i,1} = tempY{i,1}(padlen:end-padlen);
end
clear tempX tempY

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
        
rhXrs = cell(numTrials,1);
rhYrs = cell(numTrials,1);
for i = 1:numTrials
    tempX{i,1} = resample([repmat(rhX{i,1}(1), 1, padlen)'; rhX{i,1}; repmat(rhX{i,1}(end), 1, padlen)'], 1000+2*padlen, length([repmat(rhX{i,1}(1), 1, padlen)'; rhX{i,1}; repmat(rhX{i,1}(end), 1, padlen)']));
    rhXrs{i,1} = tempX{i,1}(padlen:end-padlen);
    tempY{i,1} = resample([repmat(rhY{i,1}(1), 1, padlen)'; rhY{i,1}; repmat(rhY{i,1}(end), 1, padlen)'], 1000+2*padlen, length([repmat(rhX{i,1}(1), 1, padlen)'; rhX{i,1}; repmat(rhX{i,1}(end), 1, padlen)']));
    rhYrs{i,1} = tempY{i,1}(padlen:end-padlen);
end
clear tempX tempY

%% Calculate the distance travelled over the course of the movement.

lhd = cell(numTrials,1);
lhD = cell(numTrials,1);
for i = 1:numTrials
    for j = 2:1000
        if lh.wrong_trial(i) == 1 || rh.wrong_trial(i) == 1
            lhd{i,1} = NaN; % Set initial distance to NaN
        else
            lhd{i,1} = 0;  % Set initial distance to NaN
        end
        lhd{i,j} = sqrt((lhXrs{i,1}(j)-lhXrs{i,1}(j-1))^2 + (lhYrs{i,1}(j)-lhYrs{i,1}(j-1))^2);
    end
    lhD{i} = cumsum(cell2mat(lhd(i,:)));
    lhD{i} = lhD{i}/lhD{i}(end);
end

rhd = cell(numTrials,1);
rhD = cell(numTrials,1);
for i = 1:numTrials
    for j = 2:1000
        if rh.wrong_trial(i) == 1 || rh.wrong_trial(i) == 1
            rhd{i,1} = NaN; % Set initial distance to NaN
        else
            rhd{i,1} = 0;  % Set initial distance to NaN
        end
        rhd{i,j} = sqrt((rhXrs{i,1}(j)-rhXrs{i,1}(j-1))^2 + (rhYrs{i,1}(j)-rhYrs{i,1}(j-1))^2);
    end
    rhD{i} = cumsum(cell2mat(rhd(i,:)));
    rhD{i} = rhD{i}/rhD{i}(end);
end

% Turn lhD and rhD into arrays
LHD = zeros(numTrials,1000);
for i = 1:numTrials
    if lh.wrong_trial(i) == 0
        LHD(i,:) = lhD{i,1}; % makes a 222x1000 matrix containing the distance data
    else
        LHD(i,:) = NaN;
    end
end

RHD = zeros(numTrials,1000);
for i = 1:numTrials
    if rh.wrong_trial(i) == 0
        RHD(i,:) = rhD{i,1}; % makes a 222x1000 matrix containing the distance data
    else
        RHD(i,:) = NaN;
    end
end

LHV = diff(LHD,1,2);
RHV = diff(RHD,1,2);
%% Plot individual trials
figure
plot(rhD{1, 1})
hold on
plot(rhD{43,1}, 'r')
hold on
plot(rhD{181,1},'g')

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

% Hand "velocity"
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

%%

