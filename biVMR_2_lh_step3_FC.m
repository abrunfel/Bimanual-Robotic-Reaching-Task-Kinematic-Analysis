% This program save data to do MANOVA analysis
clear all
close all

% Select the subject file
str = computer;
if strcmp(str,'MACI64') == 1
    cd('/Volumes/mnl/Data/Adaptation/interference_dosing/Post_Step_2_FC');
else
    cd('Z:\Data\Adaptation\interference_dosing\Post_Step_2_FC\');
end

dir_list = dir('*_lh_fc.mat');    %Store subject *mat data file names in variable (struct array).

dir_list = {dir_list.name}; % filenames
dir_list = sort(dir_list);  % sorts files

A2 = length(dir_list);      % how many files to process?
hand='_lh';

for B = 1:1:A2
   load(char(dir_list(B)));

ALL_subjects=[subjectID upBool wrong_trial force]; %You store the current matrix

if strcmp(str,'MACI64') == 1
    cd('/Volumes/mnl/Data/Adaptation/interference_dosing/Post_Step_3_FC');
    dlmwrite('lh_raw_fc.csv', ALL_subjects, '-append', 'delimiter', ',', 'precision','%.6f');
    cd('/Volumes/mnl/Data/Adaptation/interference_dosing/Post_Step_2_FC');
else
    cd('Z:\Data\Adaptation\interference_dosing\Post_Step_3_FC');
    dlmwrite('lh_raw_fc.csv', ALL_subjects, '-append', 'delimiter', ',', 'precision','%.6f');
    cd('Z:\Data\Adaptation\interference_dosing\Post_Step_2_FC');
end
% the notation '%.6f' writes each variable out to six decimal places, should get rid of engineering notation

end