%% create_average_deltas_8
% average deltas from different classes to get one epcoch for each class instance within each person
% output variable av_deltas is 4D array (channels x frames x stim_type x subject)

clear all; close all; clc
main_path = 'E:\Documentos\BCI_Kaplab\Article\Data3\'; % can be modified
path_deltas=strcat(main_path, 'deltas\deltas.mat');
path_av_deltas=strcat(main_path,'av_deltas\');
if exist(path_av_deltas)==0
   mkdir(path_av_deltas);
end
load(path_deltas);

% av_deltas dimensions: channels x frames x stim_type x subject
% 6 stimuli types (all happy (31_), all neutral (32_), 
% frequent happy (21_), frequent neutral (22_), rare hapy (11_), rare neutral (12_)

for subject=1:16
    for stim_type = 1:6
        av_deltas(:,:,stim_type,subject) = mean(deltas{subject,stim_type},3); % deltas 3rd dimension is epochs (see create_deltas_7.m)
    end
end

save(strcat(path_av_deltas,'av_deltas.mat'), 'av_deltas')