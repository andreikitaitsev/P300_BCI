%% reject_bad_channels_4
clear all; close all; clc;
main_path = 'E:\Documentos\BCI_Kaplab\Article\Data3\'; % can be modified
path_int = strcat(main_path,'interpolated_electrodes_datasets\');
if exist(path_int)==0
    mkdir(path_int)
end
path_filtered=[main_path,'filtered_datasets\'];
mode_names = {'allhappy','allneutral','rarehappy','rareneutral'};
count=1;

for subject=1:16
    for mode=1:4
          eeglab
          % Load dataset
          EEG = pop_loadset('filename',strcat('s',num2str(subject),'_',mode_names{mode},'_filt.set'),'filepath',path_filtered);
          EEG.setname = EEG.filename;
          [ALLEEG EEG CURRENTSET]=eeg_store(ALLEEG, EEG); %ALLEEG(1)

          %[EEG, indelec, measure, ~] =pop_rejchan(ALLEEG(1), 'elec',[1:24],'threshold',1.5, 'measure', 'prob' , 'norm', 'on');
          [EEG, indelec, measure, ~] = pop_rejchan(EEG, 'elec',[1:24] ,'threshold',[-1.49 1.49] ,'norm','on','measure','spec','freqrange',[0.3 25] );
          % visualization
          display(indelec)
          figure;
          topoplot(measure,ALLEEG(1).chanlocs(1:24),'electrodes','labels');
          title(strcat('Presumably bad channels: ',num2str(indelec)))
          pop_eegplot(ALLEEG(1), 1, 1, 1);
          
          bad_channels = input('Bad channels: ','s');
          split_bad_channels= regexp(bad_channels,',','split');
          bad_channels = [cellfun(@(x) str2double(x), split_bad_channels)];
          if ~isnan(bad_channels) %if is not empty
            Bad_chan{count} = bad_channels;
          elseif isnan(bad_channels) % if is empty
            Bad_chan{count}=[];
          end

          % Interpolate bad channels
          if ~isempty(Bad_chan{count})
            EEG = pop_interp(ALLEEG(1), [Bad_chan{count}], 'spherical');
          end
          pop_saveset(EEG,'filename', fullfile(path_int, strcat('s',num2str(subject),'_',mode_names{mode},'_int.set')))
          % Update counter
          count=count+1;
          close all
    end
end
save(fullfile(main_path,'supplementary_data\','Bad_chan.mat'),'Bad_chan')         
