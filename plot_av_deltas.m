%% plot_av_deltas
% Plot deltas ERP (for each subject using custom function plotERP24)

main_path = 'E:\Documentos\BCI_Kaplab\Article\Data3\'; 
path_av_deltas=strcat(main_path, 'av_deltas\');
path_av_deltas_figures =strcat(path_av_deltas, 'figures\');

if exist(path_av_deltas_figures) == 0
   mkdir(path_av_deltas_figures)
end
if exist('av_deltas') ~= 1
   load(strcat(path_av_deltas,'av_deltas.mat'))
end

stim_types = {'all happy', 'all neutral', 'frequent happy', 'frequent neutral', 'rare happy', 'rare neutral'};
for subject = 1:16
    fig = plotERP24(av_deltas(1:24,:,:,subject), stim_types)
    saveas(gcf,strcat(path_av_deltas_figures, 'subject_',num2str(subject),'_av_deltas','.png'))
    close 
end