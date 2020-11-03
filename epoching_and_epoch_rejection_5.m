%% epoching_and_epoch_rejection_5
% create epochs and reject it based onprobability and amplitude criteria
% using EEGLAB functions
clear all; close all; clc;
main_path = 'E:\Documentos\BCI_Kaplab\Article\Data3\'; % can be modified
epoch_window = [-0.1 0.9]; %seconds
%%
chanlocks_path=[main_path,'supplementary_data\topomap_26.ced'];
path_int = strcat(main_path,'interpolated_electrodes_datasets\');
path_epoched=strcat(main_path,'epoched_datasets\');
if exist(path_epoched)==0
    mkdir(path_epoched);
end
mode_names = {'allhappy','allneutral','rarehappy','rareneutral'};
count=1;

for subject=1:16
    for mode=1:4
        eeglab
        tmp_epochs =[];
        epoch_count = 1;
        events=[];
        % Load dataset
        EEG = pop_loadset('filename',strcat('s',num2str(subject),'_',mode_names{mode},'_int.set'),'filepath',path_int);

        % create epochs
        for event = 1:length(EEG.event)
            if ~strcmp(EEG.event(event).type,'boundary')
              tmp_epochs(:,:, epoch_count) = EEG.data(:, EEG.event(event).latency + epoch_window(1)*EEG.srate :  EEG.event(event).latency + epoch_window(2)*EEG.srate-1);
              epoch_count = epoch_count+1;
            end
        end

        % get rid of boundary events
        tmp_event_types = {EEG.event(:).type};
        bound_true = find(cellfun(@(x) strcmp(x, 'boundary'), tmp_event_types));
        bound_false=setdiff(1:length(EEG.event), bound_true);
        events=EEG.event(bound_false);

        % correct event latencies and epoch numbers
        for n=1:length(events)
        [events(n).epoch] = n;
            if n==1
                events(n).latency =abs(epoch_window(1)*EEG.srate) + 1;
            else
                events(n).latency = events(1).latency + (n-1)*(epoch_window(2)*EEG.srate+abs(epoch_window(1)*EEG.srate));
            end
        end

        % import data into dataset
        setname = strcat('s', num2str(subject), '_',mode_names{mode},'_epoched');
        EEG = pop_importdata('dataformat','array','nbchan',26,'data','tmp_epochs', 'srate',500,'pnts',500,'xmin',-0.1, 'setname', setname);
        EEG.event = events;
        
        % Import channel locations
        EEG=pop_chanedit(EEG, 'load',chanlocks_path,'settype',{'1:24' 'EEG'},'settype',{'25:26' 'EOG'});

        % remove baseline
        EEG = pop_rmbase( EEG, [-100 0] ,[]);

        % reject improbable epochs
        EEG = pop_jointprob(EEG,1,[1:26] ,2,2,0,1,0,[],0);
        % reject epochs by extreme value of EOG channels
        EEG = pop_eegthresh(EEG,1,[24:26] ,-60,60,-1,0.998,0,1);
        % save set
        EEG.setname = strcat('s',num2str(subject),'_',mode_names{mode},'_epoched');
        pop_saveset(EEG, 'filename',fullfile(path_epoched,strcat(EEG.setname,'.set')));  
        % update counter
        count=count+1;       
    end
end