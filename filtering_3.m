%% filtering_3
clear all; close all; clc;
% can be modified
main_path = 'E:\Documentos\BCI_Kaplab\Article\Data3\'; 
path_filtered=[main_path,'filtered_datasets\'];
if exist(path_filtered)==0
    mkdir(path_filtered)
end
path_exp = strcat(main_path,'only_exp_data_datasets\');
mode_names = {'allhappy','allneutral','rarehappy','rareneutral'};

% Determine frequency thresholds in Hz
low_freq_thresh = 0.3; 
high_freq_thresh = 25;

% Plot the signal before and after filtering
check=0;
%%
for subject=1:16
    for mode=1:4
        eeglab
        % Load dataset
        EEG = pop_loadset('filename',strcat('s',num2str(subject),'_',mode_names{mode},'_exp.set'),'filepath',path_exp);
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG); % ALLEEG(1)
        
        % Low-pass 25 Hz
        EEG = pop_eegfiltnew(ALLEEG(1),'hicutoff',high_freq_thresh,'plotfreqz',0)
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG); %ALLEEG(2)
        
        % Filtering (FIR, band-pass filter the data 0.3 Hz - 25 Hz. The order of filter is determined by eeglab defaults)
        % High-pass 0.3 Hz
        EEG = pop_eegfiltnew(ALLEEG(2), 'locutoff',low_freq_thresh,'plotfreqz',0);
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG); %ALLEEG(3)
        
        
        if check == 1
            cz=find(cellfun(@(x) strcmp(x, 'Cz'), {EEG.chanlocs.labels}));
            figure;
            subplot(4,1,1)
            plot(ALLEEG(1).data(cz,EEG.event(2).latency:EEG.event(2).latency+EEG.srate),'b')
            title('Original')
            subplot(4,1,2)
            plot(ALLEEG(2).data(cz,EEG.event(2).latency:EEG.event(2).latency+EEG.srate),'r')
            title(strcat(num2str(high_freq_thresh),' low-pass filter'))
            subplot(4,1,3)
            plot(ALLEEG(3).data(cz,EEG.event(2).latency:EEG.event(2).latency+EEG.srate),'r')
            hold on
            plot(ALLEEG(2).data(cz,EEG.event(2).latency:EEG.event(2).latency+EEG.srate),'b')
            title(strcat(num2str(low_freq_thresh),'-',num2str(high_freq_thresh),' band-pass filter'))
        end
        
        pop_saveset(ALLEEG(3), 'filename',fullfile(path_filtered,strcat('s',num2str(subject),'_',mode_names{mode},'_filt.set')))
    end
end