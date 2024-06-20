% Runs through all post step 2 BH files and writes the arrays to a text
% file.

clear all
close all

% Select the subject file
str = computer;
if strcmp(str,'MACI64') == 1
    cd('/Volumes/mnl/Data/Adaptation/interference_dosing/Post_Step_2_BH');
else
    cd('Z:\Data\Adaptation\interference_dosing\Post_Step_2_BH\');
end

dir_list = dir('*.mat');    % Get the file list

dir_list = {dir_list.name}; % filenames
dir_list = sort(dir_list);  % sorts files

A2 = length(dir_list);      % how many files to process?

for B = 1:1:A2
   load(char(dir_list(B)));

ALL_subjects=[subjectID gr [LHD; LHV; RHD; RHV; Distance_diff]]; %You store the current matrix

if strcmp(str,'MACI64') == 1
    cd('/Volumes/mnl/Data/Adaptation/interference_dosing/Post_Step_3_BH');
    dlmwrite('raw_BH.csv', ALL_subjects, '-append', 'delimiter', ',', 'precision','%.6f');
    cd('/Volumes/mnl/Data/Adaptation/interference_dosing/Post_Step_2_BH');
else
    cd('Z:\Data\Adaptation\interference_dosing\Post_Step_3_BH');
    dlmwrite('raw_BH.csv', ALL_subjects, '-append', 'delimiter', ',', 'precision','%.6f');
    cd('Z:\Data\Adaptation\interference_dosing\Post_Step_2_BH');
end
% the notation '%.6f' writes each variable out to six decimal places, should get rid of engineering notation

end