%% save_only_exp_data_2
% get rid of noisy in-betwwen stimuli data
clear all; close all; clc;
main_path = 'E:\Documentos\BCI_Kaplab\Article\Data3\'; % can be modified
raw_datasets_path = [main_path,'raw_datasets\'];
path_exp = strcat(main_path,'only_exp_data_datasets\');
if exist(path_exp)==0
   mkdir(path_exp);
end
mode_names = {'allhappy','allneutral','rarehappy','rareneutral'};
set_count=1;
buffer_window = [-1 1]; % seconds

for subject=1:16
        for mode=1:4
            eeglab
            % Load dataset
            EEG = pop_loadset('filename',strcat('s',num2str(subject),'_',mode_names{mode},'.set'),'filepath',raw_datasets_path);
            interval_count=1;
            
            % calculate exp data interval indices 
                for event = 1:length(EEG.event) % if no event after 2s -end of of stimulus presentation data piece
                        event_lat = EEG.event(event).latency;
                        % detect start
                        if isempty(intersect([EEG.event.latency], [(event_lat-EEG.srate*2) : event_lat-1])) % if there there is no event 2 seconds before the current event 
                           point_vec(1,interval_count) = EEG.event(event).latency + EEG.srate*buffer_window(1);            
                        % detect end
                        elseif isempty(intersect([EEG.event.latency], [event_lat+1 : event_lat+EEG.srate*2 ])) % if there there is no event 2 seconds onwards from the current event 
                           point_vec(2,interval_count) = EEG.event(event).latency + EEG.srate*buffer_window(2);            
                           interval_count=interval_count+1;
                        end
                end
                            
             % select only exp data
             eeg=pop_select(EEG,'point', point_vec'); 
             pop_saveset(eeg, 'filename', fullfile(path_exp, strcat('s',num2str(subject),'_',mode_names{mode},'_exp.set')))
             eeg=[];
             point_vec = [];
        end           
end