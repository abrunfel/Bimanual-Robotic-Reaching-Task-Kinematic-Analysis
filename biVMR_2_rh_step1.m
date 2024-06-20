% This is the first attempt at generating code to import data files from
% March 03, 2015 tests. These were bimanual tests with visual rotation and
% kinesthetic control.

clear all
close all

% Select the subject file
str = computer;
if strcmp(str,'MACI64') == 1
    cd('/Volumes/mnl/Data/Adaptation/interference_dosing/pilot/');
    fname = uigetfile('*.zip');
    fname = fname(1:9);
else
    cd('Z:\Data\Adaptation\interference_dosing\pilot\');
    fname = uigetfile('*.zip');
    fname = fname(1:9);
end


unZip = zip_load(fname);
data = unZip.c3d;
filename = unZip.filename;
rawData = KINARM_add_hand_kinematics(data(:)); % this adds kinematics to c3d files
filtData = c3d_filter_dblpass(rawData, 'enhanced', 'fc', 10, 'fs', 1000); % 'fc' = cutoff freq, 'fs' = sample rate (don't change fs)
numTrials = size(rawData,1); % Number of Trials

% Find trail numbers
trialNumber = zeros(numTrials,1);
for i = 1:numTrials
    trialNumber(i) = filtData(i).TRIAL.TRIAL_NUM;
end

% Find correct trial order
trialOrder = zeros(numTrials,1);
for i = 1:numTrials
    trialOrder(i) = find(trialNumber == i);
end
% reorders the data to reflect trial number, not TP number
for i = 1:numTrials
    sortData(i) = filtData(trialOrder(i));
end
sortData = sortData';

numDataPoints = zeros(numTrials,1);
for i = 1:numTrials
    numDataPoints(i) = size(sortData(i).Left_HandX,1); % Number of Data points in each trial
end

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

velR = cell(numTrials,1);
onset = zeros(numTrials,1);
onset = onset + 10; % So we don't get errors when moveOnset doesn't work
offset = zeros(numTrials,1);
offset = offset +20; % So we don't get errors when moveOffset doesn't work
wrong_trial = zeros(numTrials,1);
rhX = cell(numTrials,1);
rhY = cell(numTrials,1);
mov_tanR = cell(numTrials,1);
On_err = zeros(numTrials,1);
Off_err = zeros(numTrials,1);
delta_t = 1/1000; % 1/fs

% Find Hand Speed (Magnitude of tangential velocity)
for i = 1:numTrials
    % Calculate hand speed
%     velL{i,1} = sqrt(sortData(i,1).Left_HandXVel.^2 + sortData(i,1).Left_HandYVel.^2);
%     % Calculate movement onset and offset (First column is L-hand, second
%     % column is R-hand
%     % This is calculated from Teasdale, based on Tresilian (see function
%     % for more info)
%     onset(i,1) = movOnset(velL{i,1}, 1000, 10, 100);
%     offset(i,1) = movOffset(velL{i,1} ,500 ,10, 100);
    
% Tangential velocity from kinsym
    rhX{i,1} = sortData(i,1).Right_HandX;
    rhY{i,1} = sortData(i,1).Right_HandY;
    mov_tanR{i,1} = sqrt(rhX{i,1}.^2 + rhY{i,1}.^2);
    velR{i,1} = diff(mov_tanR{i,1})/delta_t;
      
    onset(i,1) = movOnset2(velR{i,1}, 750, 10, 100); % !!! movOnset2 and movOffset3 is working better as of 5/28/15 !!!!
    offset(i,1) = movOffset3(velR{i,1} ,50 ,10, 100); 
end

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

vel = cell(numTrials,1);
velPeak = zeros(numTrials,1);
indPeak = zeros(numTrials,1);
for i = 1:numTrials
    %Calculate hand speed
    vel{i,1} = sqrt(sortData(i,1).Right_HandXVel.^2 + sortData(i,1).Right_HandYVel.^2);
    %Find Peak velocity
    [velPeak(i), indPeak(i)] = max(abs(vel{i,1}));
end

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
    if wrong_trial(i) == 0
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
        
    elseif wrong_trial(i) == 1
        xPeak(i) = NaN;
        yPeak(i) = NaN;
        xStart(i) = NaN;
        yStart(i) = NaN;
        imd(i,:) = NaN;
        ide(i) = NaN;
    end
end

ide(upTrials) = ide(upTrials) + 90;
ide(downTrials) = ide(downTrials) - 90;

%%
% Plot movement trajectories and hand speeds to verify onset/offest
% Right HAND ONLY
% figure(1);
ang = 0:0.1:2.01*pi;
r = sortData(i).TARGET_TABLE.VRad(2);

for i = 1:numTrials
    flag = 2;
    while flag>1
        figure('Position', [100 100 1920/2 1080/2]); %[bottom left corner coords X and Y, W, H]
        subplot(1,2,1)
        plot(sortData(i).TARGET_TABLE.X(2)+r*cos(ang),sortData(i).TARGET_TABLE.Y(2)+r*sin(ang),'Color',[255/255 117/255 56/255])
        hold on
        plot(sortData(i).TARGET_TABLE.X(3)+r*cos(ang),sortData(i).TARGET_TABLE.Y(3)+r*sin(ang),'k')
        hold on
        plot(sortData(i).TARGET_TABLE.X(4)+r*cos(ang),sortData(i).TARGET_TABLE.Y(4)+r*sin(ang),'k')
        axis([sortData(i).TARGET_TABLE.X(2)-20 sortData(i).TARGET_TABLE.X(2)+20 sortData(i).TARGET_TABLE.Y(4)-10 sortData(i).TARGET_TABLE.Y(3)+10]);
        axis square;
        title(['Trial: ',num2str(i), '  ', 'Theta: ',num2str(ide(i))]);
        hold on
        % NOTE: need to subtract 20 cm from the y data. This is because the
        % reference frame for the output is in global coords, while the target
        % table is in relative coords (this will change, but I can't find where
        % in the data file it occurs. Can't parameterize it now)
        %Correction: this is Tx and Ty
        if sortData(i).TRIAL.TP == 1 || sortData(i).TRIAL.TP == 3 || sortData(i).TRIAL.TP == 2 || sortData(i).TRIAL.TP == 4 % Non-rotated Trials
            plot(sortData(i).Right_HandX(750:end)*100-Tx,sortData(i).Right_HandY(750:end)*100-Ty); % in cm
            hold on
            % NOTE: The 750 comes from the movOnset
            % parameters
            plot(sortData(i).Right_HandX(onset(i,1))*100-Tx,sortData(i).Right_HandY(onset(i,1))*100-Ty,'go');
            hold on
            plot(sortData(i).Right_HandX(offset(i,1))*100-Tx,sortData(i).Right_HandY(offset(i,1))*100-Ty,'mo');
        elseif sortData(i).TRIAL.TP == 5 || sortData(i).TRIAL.TP == 6 % Rotated Trials need to show cursor position, not hand position
            plot(cursorPosX{i,1}(750:end)*100-Tx,cursorPosY{i,1}(750:end)*100-Ty); % in cm
            hold on
            % NOTE: The 750 comes from the movOnset
            % parameters
            plot(cursorPosX{i,1}(onset(i,1))*100-Tx,cursorPosY{i,1}(onset(i,1))*100-Ty,'go');
            hold on
            plot(cursorPosX{i,1}(offset(i,1))*100-Tx,cursorPosY{i,1}(offset(i,1))*100-Ty,'mo');
        end
        subplot(1,2,2)
        plot(velR{i,1});
        hold on
        plot(onset(i,1),velR{i,1}(onset(i,1)), 'go');
        hold on
        plot(offset(i,1),velR{i,1}(offset(i,1)), 'mo');
        
        % Verify Onset/Offset
        button = questdlg('Confirm movement onset/offset?','Onset and offset markers:','Yes','No','Reject','No');
        if strcmp(button,'Yes')
            close(1);
            flag=1;
        elseif strcmp(button,'No') %user can verify if movement onset was computed correctly
            [loc_onset,loc_size]=ginput(2);
            onset(i,1)=round(loc_onset(1)); % replace onset with user defined input
            offset(i,1)=round(loc_onset(2)); % replace offset with use defined input
            close(1);
            flag=2;
        elseif strcmp(button,'Reject')
            onset(i,1) = NaN;
            offset(i,1) = NaN;
            wrong_trial(i,1)=1;			% Keeps track of rejected trials
            close(1);
            flag=1;
        end
    end
    clear button;
end

% errors = inputdlg('Enter trials numbers which were errors (space-separated)');
% errors = str2num(errors{:});
% wrong_trial(errors) = 1;

%switch Directory
if strcmp(str,'MACI64') == 1
    cd('/Volumes/mnl/Data/Adaptation/interference_dosing/Post_Step_1');
else
    cd('Z:\Data\Adaptation\interference_dosing\Post_Step_1');
end
filename = cell2mat(filename);
filename = filename(1:end-4);
% cd('C:\Users\Alex\Desktop\sicibiman2 post step 1')% only use when coding from a remote location (to improve speed)
save([fname '_postStep1_rh' '.mat'],'sortData');
save([fname '_postStep1_rh' '.mat'],'onset', 'offset', 'wrong_trial', '-append');
if strcmp(str,'MACI64') == 1
    cd('/Volumes/mnl/Data/Adaptation/interference_dosing/matlab/');
else
    cd('Z:\Data\Adaptation\interference_dosing\matlab\');
end