%% create_deltas_7
% script creates deltas by subtracting average non-taget stimulus over all mode from every target stimulus.
% Output variable deltas is a 16x6 element cell (participants x stim_types),
% inside each cell there is a multidimensional array (channels x frames x epochs)

clear all; close all; clc
main_path = 'E:\Documentos\BCI_Kaplab\Article\Data3\'; % can be modified
path_deltas=[main_path, 'deltas\deltas.mat'];
if exist(path_deltas) == 0
    mkdir(path_deltas)
end
path_epoched = strcat(main_path,'epoched_datasets\');
path_supplementary = strcat(main_path,'\supplementary_data\');
mode_names = {'allhappy','allneutral','rarehappy','rareneutral'};

% initialize variables
deltas= cell(16,6); %subject, stim_types
non_target_array = {'310','320','110','120','210','220'}; %array with all possible non-target event codes
stim_class_codes ={'311','321',{'221','111'},{'211','121'}};
stim_type_position = {1,2,{4,5},{3,6}}; % positions in stim_type dimesnion
        
eeglab;
for subject=1:16
    for mode=1:4
        %% Calculate deltas (target - non-target)
        EEG = pop_loadset('filename',strcat('s',num2str(subject),'_',mode_names{mode},'_epoched.set'),'filepath',path_epoched);
        
        % Calculate average non-target epoch
        non_target_idx = cell2mat(cellfun(@(x) ismember(x, non_target_array), {EEG.event(:).type},'UniformOutput',false));
        av_non_target_tmp = mean(EEG.data(:,:,non_target_idx),3); %average non-target stimulus for this recording
        
        % Subtract it from every target stimulus
        deltas_tmp = EEG.data(:,:,non_target_idx==0) - repmat(av_non_target_tmp,1,1, size(EEG.data(:,:,non_target_idx==0),3));
        events_tmp = {EEG.event(non_target_idx==0).type};
        
        %% Separate deltas into different stimuli classes 
        % (6 stimuli classes (all happy (31_), all neutral (32_), frequent happy (21_), frequent neutral (22_), rare hapy (11_), rare neutral (12_)
        if length(stim_class_codes{mode}) ~= 2 % modes 1,2
           epochs2choose = find(cell2mat(cellfun(@(x) find(strcmp(x,stim_class_codes{mode})), events_tmp,'UniformOutput',false)));  
           deltas{subject,stim_type_position{mode}} = deltas_tmp(:,:,epochs2choose);          
        elseif length(stim_class_codes{mode}) == 2 % modes 3,4
           for stim_ind =1:2 
               epochs2choose = find(cell2mat(cellfun(@(x) find(strcmp(x,stim_class_codes{mode}{stim_ind})), events_tmp,'UniformOutput',false)));  
               deltas{subject,stim_type_position{mode}{stim_ind}} = deltas_tmp(:,:,epochs2choose);   
           end
        end
        EEG=[];       
    end
end

save(path_deltas, 'deltas');   