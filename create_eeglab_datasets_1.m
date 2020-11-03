%% create_eeglab_datasets_1
% Script reads .bdf files provided by Rafael
clear all; close all; clc;
main_path = 'E:\Documentos\BCI_Kaplab\Article\Data3\'; % can be modified
if exist(main_path)==0
    mkdir(main_path);
end
raw_datasets_path = [main_path,'raw_datasets\'];
if exist (raw_datasets_path)==0
    mkdir(raw_datasets_path);
end
chanlocks_path=[main_path,'supplementary_data\topomap_26.ced'];

addpath('C:\Users\Andrei\Documents\MATLAB\eeglab2019_1')
mode_names = {'allhappy','allneutral','rarehappy','rareneutral'};
count_set = 1;
[events.type events.latency] = deal(cell(1,64));
for subject = 1:16
    for mode=1:4
        eeglab
        % preallocate tmp variables
        tmp_trial_type=[];
        tmp_sample=[];
        tmp_is_rare=[];
        
        % load dataset .bdf
        EEG = pop_biosig(strcat('E:\Documentos\BCI_Kaplab\Internship\data_raw\exp1_bids\sub-',num2str(subject),'\ses-', ...
        mode_names{mode},'\eeg\sub-',num2str(subject),'_ses-',mode_names{mode},'_task-bci_eeg.bdf'), 'importevent','off','importannot','off');
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, count_set,'setname',strcat('s',num2str(subject),'_',mode_names{mode}),'gui','off');
        
        % read markup fields
        fileID = fopen(strcat('E:\Documentos\BCI_Kaplab\Internship\data_raw\exp1_bids\sub-',num2str(subject),'\ses-',mode_names{mode},...
            '\eeg\sub-',num2str(subject),'_ses-',mode_names{mode},'_task-bci_events.tsv'),'r');
        fspec = '%*f %*f %d %*f %f %*f %s %*[^\n]'; % trial_type, sample, is_rare
        tmp_markup = textscan(fileID, fspec, 'Delimiter', '\t', 'Headerlines',1);
        fclose(fileID);

        tmp_trial_type = double(tmp_markup{1});
        tmp_sample = double(tmp_markup{2});
        
        % tmp_markup{3} can not be directly transformed ito cell, so do it
        % within a loop
        
        for idx = 1:length(tmp_markup{3})
            tmp_is_rare(idx,1) = double(str2num(lower((tmp_markup{3}{idx}))));
        end
        tmp_markup = [tmp_trial_type tmp_sample tmp_is_rare]; % trial_type, sample, is_rare
                   
        if mode == 1 % all happy
           tmp_events_freq = 3*ones(size(tmp_markup,1),1); % 3-all
           tmp_events_valence = ones(size(tmp_markup,1),1); % 1 -happy
        elseif mode == 2 % all neutral
           tmp_events_freq = 3*ones(size(tmp_markup,1),1); % 3-all
           tmp_events_valence = 2*ones(size(tmp_markup,1),1); % 2 - neutral
        elseif mode == 3 % rare happy
           tmp_events_freq = 2*ones(size(tmp_markup,1),1); %"default" 2 -frequent
           tmp_events_valence = 2*ones(size(tmp_markup,1),1);%default 2 - neutral
           tmp_events_freq(tmp_is_rare == 1) = 1; % in mode rarehappy where is_rare==1, trials are rare_happy (11)
           tmp_events_valence(tmp_is_rare == 1) = 1;
        elseif mode == 4 % rare neutral
           tmp_events_freq = 2*ones(size(tmp_markup,1),1); %"default" 2 -frequent
           tmp_events_valence = 1*ones(size(tmp_markup,1),1); %"default" 1 - happy
           tmp_events_freq(tmp_is_rare == 1) = 1; % in mode rareneutral where is_rare is true, trials are rare(1)_neutral(2)
           tmp_events_valence(tmp_is_rare == 1) = 2; 
        end
        
        tmp_events_istarget = tmp_trial_type; % 1 - is_target, 2 - is_non_target      
        events.type{count_set}=str2num(([num2str(tmp_events_freq) num2str(tmp_events_valence) num2str(tmp_events_istarget)]))'; % events contains all event types in columns, rows are different sets
        events.latency{count_set}=tmp_sample;
        
        % create new channel as the last one 
        EEG.data(27,:) = zeros(1,size(EEG.data,2));
        EEG.data(27, events.latency{count_set}' ) = events.type{count_set};
        
        % Extract events from data channel and save them in EEGlab dataset
        EEG = pop_chanevent(EEG, 27,'edge','leading','edgelen',0,'delchan','on');
        [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG);
        
        % load channel location
        EEG=pop_chanedit(EEG, 'load',chanlocks_path,'settype',{'1:24' 'EEG'},'settype',{'25:26' 'EOG'});
        
        % Save dataset
        fname=sprintf('s%d_%s.set', subject, mode_names{mode})
        pop_saveset( EEG, 'filename',strcat('s',num2str(subject),'_',mode_names{mode},'.set'),'filepath',raw_datasets_path);
        
        % update dataset counter after each new mode
        count_set = count_set + 1;       
    end
end