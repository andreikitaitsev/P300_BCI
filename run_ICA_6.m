%% run_ICA_6
clear all; close all; clc;
main_path = 'E:\Documentos\BCI_Kaplab\Article\Data3\'; % can be modified
path_epoched=strcat(main_path,'epoched_datasets\');
path_supplementary = strcat(main_path, 'supplementary_data\');
mode_names = {'allhappy','allneutral','rarehappy','rareneutral'};
load('E:\Documentos\BCI_Kaplab\Article\Data\supplimentary_data\Bad_chan.mat');
PCA = max(cellfun(@(x) length(x), Bad_chan)); % number of components to retain in data = nbchan-PCA
count=1;
ICA_weights=cell(16*4,1);
ICA_sphere=cell(16*4,1);
tic
for subject=1:16
    for mode=1:4
        eeglab;
        % Load dataset
        EEG = pop_loadset('filename',strcat('s',num2str(subject),'_',mode_names{mode},'_epoched.set'),'filepath',path_epoched);
        % Run ica
        EEG = pop_runica(EEG, 'icatype', 'binica', 'extended',1,'pca',EEG.nbchan-PCA);
        ICA_weights{count} = EEG.icaweights;
        ICA_sphere{count} = EEG.icasphere;

        % Update counter
        count=count+1;
    end
end
time=toc
save(strcat(path_supplementary,'ICA.mat'), 'ICA_weights', 'ICA_sphere') 