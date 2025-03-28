%%
clear
set(0, 'DefaultTextInterpreter', 'none'); % for figures

load("C:\Users\blake\OneDrive\Documents\teaching\2025_NBIO_207A\Class05_Spikedata_Dimensionality_Reduction_Clustering_Lab\Blake_UMAP\TH605_train_Day11.mat")
%load("C:\Users\blake\OneDrive\Documents\teaching\2025_NBIO_207A\Class05_Spikedata_Dimensionality_Reduction_Clustering_Lab\Blake_UMAP\TH605_test_Day1.mat")

%load("C:\Users\blake\OneDrive\Documents\teaching\2025_NBIO_207A\Class05_Spikedata_Dimensionality_Reduction_Clustering_Lab\Blake_UMAP\TH405_train_Day34.mat")

%% Data explainer

% currID, str = session identifier as "RatName Experiment Day#"
% trial_IDs, vector = trial types. ordered by arm number. 2 suffix indicated second visit. e.g. 4 is choice arm while 24 is free arm
% full_numBins, vector = number of temporal bins the spiking data was divided into

% currUnits_XXX, array = cols: neurons, rows: temporal bins by trial_IDs. size = length(trial_IDs) * full_numBins , # neurons. Each element is the z scored average firing rate for each neuron at that time bin.
% XXX = brain region. HPC: dorsal CA.  PFC: dorsal medial prefrontal (ACC/PrL).  VTA: Ventral tegmental area (not all data sets)


%% PCA - PFC

skipHome_offset_PFC = 0; % 13 bin offset for choice trials to not plot home, 0 for whole trajectory

[coeff,score_PFC,latent,tsquared,explained,mu] = pca(currUnits_PFC,'centered',false); % data is already centered

disp('Variance explained:')
disp(explained(1:3))

%% Plot PCA - PFC - First 3 PCs

currStart = 1; % start reading
currEnd = full_numBins; % read a full trial worth of bins

figure
hold on
for currVisitArmID = 1:length(trial_IDs) % for each trial type

    if trial_IDs(currVisitArmID) > 20 % if a free choice arm trial type
        skipHomeHere = 0;
    else
        skipHomeHere = skipHome_offset_PFC; % if a choice arm trial type
    end

    plot3(score_PFC(currStart+skipHomeHere:currEnd,1),score_PFC(currStart+skipHomeHere:currEnd,2),score_PFC(currStart+skipHomeHere:currEnd,3),'LineWidth',2,'color',cmap_firstSecond_train(currVisitArmID,:)/256) % plot PCs
    scatter3(score_PFC(currStart+skipHomeHere,1),score_PFC(currStart+skipHomeHere,2),score_PFC(currStart+skipHomeHere,3),100,'k','filled',markers{currVisitArmID}); % markers for starts

    % increment writing
    currStart = currEnd+1;
    currEnd = currEnd+(full_numBins);
end % each choice arm

xlabel('PC1')
ylabel('PC2')
zlabel('PC3')

h = zeros(3, 1);
h(1) = plot(NaN,NaN,'color',[16, 43, 148]/256,'linewidth',2);
h(2) = plot(NaN,NaN,'color',[15, 122, 34]/256,'linewidth',2);
h(3) = plot(NaN,NaN,'color',[191, 0, 0]/256,'linewidth',2);
h(4) = plot(NaN,NaN,'color',[179, 102, 0]/256,'linewidth',2);
h(5) = plot(NaN,NaN,'color',[87, 14, 156]/256,'linewidth',2);
legend(h, 'A','B','C','D','E');
set(gca,'fontsize',18)

title({'PCA PFC 1st 2nd',currID})

%% PCA side quest - Coefficents / loadings
% coeff will be N neurons by N PCs where each col is a PC from 1:N
% this can tell you the coefficient for each neuron in each PC
% you could use these values to go back to your neurons to group/cluster
% them

figure
scatter(coeff(:,1),coeff(:,2),'filled','k')

Z = linkage(coeff(:,1:3));
figure
dendrogram(Z)

%% UMAP
% Open run_umap for details

% UMAP Settings

% dims: number of dimensions to reduce to.
UMAP_dims = 2;  % Graphs created for 2 or 3.

% neighbor: Controls local and global structure
% low neighbors, more local. high, more global
UMAP_neighbor = 30; % Blake: 30  Wenbo: 50  Gardner et al. 2022: 5  UMAP default: 15

% min_dist: Controls how tightly UMAP is allowed to pack points.
UMAP_minDist = 0.6; % Blake: 0.6  Wenbo: 0.6  Gardner et al. 2022: 0.05  UMAP default: 0.3

% metric: controls how distance is computed in the ambient space
%UMAP_metric = 'euclidean'; % default
%UMAP_metric = 'cityblock'; % Gardner et al. 2022, also called "manhattan"
UMAP_metric = 'cosine'; % used by Tang Shin Jadhav
%UMAP_metric = 'correlation';

%% run UMAP - PFC
[reduction_PFC,umap_PFC] = run_umap(currUnits_PFC,'n_components', UMAP_dims, 'metric', UMAP_metric, 'n_neighbors', UMAP_neighbor, 'min_dist', UMAP_minDist, 'verbose','none');

%% Plot UMAP - PFC

currStart = 1; % where to start reading data
currEnd = full_numBins; % how long is a trial

figure
hold on
for currChoiceArmID = 1:length(trial_IDs) % for each trial type

    if trial_IDs(currChoiceArmID) > 20 % if a free choice arm trial type
        skipHomeHere = 0;
    else
        skipHomeHere = skipHome_offset_PFC; % if a choice arm trial type
    end

    if UMAP_dims == 3 % 3D plot

        plot3(reduction_PFC(currStart+skipHomeHere:currEnd,1),reduction_PFC(currStart+skipHomeHere:currEnd,2),reduction_PFC(currStart+skipHomeHere:currEnd,3),'LineWidth',2,'color',cmap_firstSecond_train(currChoiceArmID,:)/256); % plot UMAP result

        %scatter3(reduction_PFC(currStart+skipHomeHere:currEnd,1),reduction_PFC(currStart+skipHomeHere:currEnd,2),reduction_PFC(currStart+skipHomeHere:currEnd,3),'filled','LineWidth',2,'MarkerFaceColor',cmap_firstSecond_train(currChoiceArmID,:)/256);

        scatter3(reduction_PFC(currStart+skipHomeHere,1),reduction_PFC(currStart+skipHomeHere,2),reduction_PFC(currStart+skipHomeHere,3),150,'k','filled',markers{currChoiceArmID}); % plot starting points as markers

    elseif UMAP_dims == 2 % 2D plot

        plot(reduction_PFC(currStart+skipHomeHere:currEnd,1),reduction_PFC(currStart+skipHomeHere:currEnd,2),'LineWidth',2,'color',cmap_firstSecond_train(currChoiceArmID,:)/256); % plot UMAP result

        %scatter(reduction_PFC(currStart+skipHomeHere:currEnd,1),reduction_PFC(currStart+skipHomeHere:currEnd,2),'filled','LineWidth',2,'MarkerFaceColor',cmap_firstSecond_train(currChoiceArmID,:)/256);

        scatter(reduction_PFC(currStart+skipHomeHere,1),reduction_PFC(currStart+skipHomeHere,2),150,'k','filled',markers{currChoiceArmID}); % plot starting points as markers

    end

    % update read position for next trial type
    currStart = currEnd+1;
    currEnd = currEnd+(full_numBins);
end % each choice arm

% Graph labels
grid off
xlabel('Dim 1')
ylabel('Dim 2')
zlabel('Dim 3')

% hack for legend when you plot twice
h = zeros(3, 1);
h(1) = plot(NaN,NaN,'color',[16, 43, 148]/256,'linewidth',2);
h(2) = plot(NaN,NaN,'color',[15, 122, 34]/256,'linewidth',2);
h(3) = plot(NaN,NaN,'color',[191, 0, 0]/256,'linewidth',2);
h(4) = plot(NaN,NaN,'color',[179, 102, 0]/256,'linewidth',2);
h(5) = plot(NaN,NaN,'color',[87, 14, 156]/256,'linewidth',2);
legend(h, 'A','B','C','D','E');
set(gca,'fontsize',18)

title({'UMAP PFC 1st 2nd',currID})

%% Plot PCA and UMAP - PFC
figure
tiledlayout(1,2)

plot_PCA(score_PFC,full_numBins,trial_IDs,skipHome_offset_PFC,cmap_firstSecond_train,markers)
title({'PCA PFC 1st 2nd',currID})

plot_UMAP(reduction_PFC,full_numBins,trial_IDs,skipHome_offset_PFC,cmap_firstSecond_train,markers)
title({'UMAP PFC 1st 2nd',currID})

%% Run UMAP and plot multiple times - PFC
% You can also iteratively change params like neighbors
UMAP_runs = 5;

% UMAP_neighbor = 5;

% UMAP_minDist = 0.05;

figure
tiledlayout(1,UMAP_runs,'tilespacing','none','padding','tight');
for currRun = 1:UMAP_runs
    [reduction_PFC,umap_PFC] = run_umap(currUnits_PFC,'n_components', UMAP_dims, 'metric', UMAP_metric, 'n_neighbors', UMAP_neighbor, 'min_dist', UMAP_minDist, 'verbose','none');
    plot_UMAP(reduction_PFC,full_numBins,trial_IDs,skipHome_offset_PFC,cmap_firstSecond_train,markers)
    cleanFig

    %UMAP_neighbor = UMAP_neighbor + 5;

    % UMAP_minDist = UMAP_minDist + 0.05;
end % each run

%% Calculating the distance between trajectories

%% UMAP - PFC

umap_dist_PFC = squareform(pdist(reduction_PFC,'euclidean'));
%figure
%imagesc(umap_dist_PFC)

% square

umap_dist_PFC_all = [];
currStart = 1;
for currTrialID = 1:length(trial_IDs)
    for currBin = 1:full_numBins
        currBin_dists = umap_dist_PFC(currBin:full_numBins:length(trial_IDs)*full_numBins,currStart);
        currStart = currStart +1;
        umap_dist_PFC_all = [umap_dist_PFC_all currBin_dists];
    end
end

umap_dist_PFC_removeSelf = umap_dist_PFC_all;
umap_dist_PFC_removeSelf(umap_dist_PFC_removeSelf==0) = NaN;

umap_dist_PFC_removeSelf_re = reshape(umap_dist_PFC_removeSelf,[],length(trial_IDs));

% every column is a trial type visits
% every row is the pairwise distance of a point on trial type X to all other trial types
% trial types repeat every 9th row (9 TTs)
% for column 1, that's B on BC
% 1 10 19 are 1 to itself across time bins
% 2 11 20 comapre 1 to 2, or B on BC to E on DE
% 3 12 21 comapre 1 to 3, or B on BC to A on AB

% get the average distance for every pairwise comparison

avg_dist_holder_PFC = [];
for currTT = 1:length(trial_IDs)
    for currBin = 1:length(trial_IDs)
        avg_dist_holder_PFC = [avg_dist_holder_PFC; mean(umap_dist_PFC_removeSelf_re(currBin:length(trial_IDs):length(trial_IDs)*full_numBins,currTT))];
    end
end

avg_dist_holder_PFC(isnan(avg_dist_holder_PFC)) = [];

avg_dist_holder_PFC_re = reshape(avg_dist_holder_PFC,length(trial_IDs)-1,[]);

%
z_PFC = linkage(avg_dist_holder_PFC_re');

if contains(currID,'TH605')
    dend_label = {'B1' 'E1' 'A1' 'C1' 'D1' 'B2' 'E2' 'C2' 'D2'};
elseif contains(currID,'TH405')
    dend_label = {'D1' 'B1' 'E1' 'A1' 'C1' 'D2' 'B2' 'E2' 'C2'};
else
    error('Cannot find rat name')
end


figure
[H,T,outperm] = dendrogram(z_PFC,'Labels',dend_label);
%[H,T,outperm] = dendrogram(z);
set(H,'LineWidth',3,'Color','k');
title('PFC UMAP')

% PCA - PFC
pca_dist_PFC = squareform(pdist(score_PFC,'euclidean'));

pca_dist_PFC_all = [];
currStart = 1;
for currTrialID = 1:length(trial_IDs)
    for currBin = 1:full_numBins
        currBin_dists = pca_dist_PFC(currBin:full_numBins:length(trial_IDs)*full_numBins,currStart);
        currStart = currStart +1;
        pca_dist_PFC_all = [pca_dist_PFC_all currBin_dists];
    end
end

pca_dist_PFC_removeSelf = pca_dist_PFC_all;
pca_dist_PFC_removeSelf(pca_dist_PFC_removeSelf==0) = NaN;

pca_dist_PFC_removeSelf_re = reshape(pca_dist_PFC_removeSelf,[],length(trial_IDs));

% get the average distance for every pairwise comparison

avg_dist_holder_PFC = [];
for currTT = 1:length(trial_IDs)
    for currBin = 1:length(trial_IDs)
        avg_dist_holder_PFC = [avg_dist_holder_PFC; mean(pca_dist_PFC_removeSelf_re(currBin:length(trial_IDs):length(trial_IDs)*full_numBins,currTT))];
    end
end

avg_dist_holder_PFC(isnan(avg_dist_holder_PFC)) = [];

avg_dist_holder_PFC_re = reshape(avg_dist_holder_PFC,length(trial_IDs)-1,[]);

%
z_PFC = linkage(avg_dist_holder_PFC_re');

figure
[H,T,outperm] = dendrogram(z_PFC,'Labels',dend_label);
%[H,T,outperm] = dendrogram(z);
set(H,'LineWidth',3,'Color','k');
title('PFC PCA')



%% HPC
% UMAP Settings

% dims: number of dimensions to reduce to.
UMAP_dims = 2;  % Graphs created for 2 or 3.

% neighbor: Controls local and global structure
% low neighbors, more local. high, more global
UMAP_neighbor = 30; % Blake: 30  Wenbo: 50  Gardner et al. 2022: 5  UMAP default: 15

% min_dist: Controls how tightly UMAP is allowed to pack points.
UMAP_minDist = 0.6; % Blake: 0.6  Wenbo: 0.6  Gardner et al. 2022: 0.05  UMAP default: 0.3

% metric: controls how distance is computed in the ambient space
%UMAP_metric = 'euclidean'; % default
%UMAP_metric = 'cityblock'; % Gardner et al. 2022, also called "manhattan"
UMAP_metric = 'cosine'; % used by Tang Shin Jadhav
%UMAP_metric = 'correlation';

skipHome_offset_HPC = 0; % 13 bin offset for choice trials to not plot home, 0 for whole trajectory


%% PCA - HPC

[coeff,score_HPC,latent,tsquared,explained,mu] = pca(currUnits_HPC,'centered',false); % data is already centered

disp('Variance explained:')
disp(explained(1:3))

%% Plot PCA - HPC - First 3 PCs
figure
tiledlayout(1,1)

plot_PCA(score_HPC,full_numBins,trial_IDs,skipHome_offset_HPC,cmap_firstSecond_train,markers)
title({'PCA HPC 1st 2nd',currID})

%% run UMAP - HPC
[reduction_HPC,umap_HPC] = run_umap(currUnits_HPC,'n_components', UMAP_dims, 'metric', UMAP_metric, 'n_neighbors', UMAP_neighbor, 'min_dist', UMAP_minDist, 'verbose','none');

%% Plot UMAP - HPC

figure
tiledlayout(1,1)
plot_UMAP(reduction_HPC,full_numBins,trial_IDs,skipHome_offset_HPC,cmap_firstSecond_train,markers)
title({'UMAP HPC 1st 2nd',currID})

%% Plot PCA and UMAP - HPC
figure
tiledlayout(1,2)

plot_PCA(score_HPC,full_numBins,trial_IDs,skipHome_offset_HPC,cmap_firstSecond_train,markers)
title({'PCA HPC 1st 2nd',currID})

plot_UMAP(reduction_HPC,full_numBins,trial_IDs,skipHome_offset_HPC,cmap_firstSecond_train,markers)
title({'UMAP HPC 1st 2nd',currID})


%%
% ~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~
% ~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~
% ~*~*~*~*~ Everything past here is extra *~*~*~*~*~*~*
% *~*~*~*~**~*~*~ and also bad code *~*~*~*~*~*~*~*~*~*
% ~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~
% ~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~


%% bars of 1st 1st-1st-2nd 2nd-2nd
% for 9 trial types as arranged above
%error('hardcoded idiot')


first2_PFC = unique(reshape(avg_dist_holder_PFC_re(1:4,1:5),[],1));
first2_PFC_mean = mean(first2_PFC);
first2_PFC_sem = std(first2_PFC)/sqrt(length(first2_PFC));

second2_PFC = unique(reshape(avg_dist_holder_PFC_re(6:8,6:9),[],1));
second2_PFC_mean = mean(second2_PFC);
second2_PFC_sem = std(second2_PFC)/sqrt(length(second2_PFC));

firstSecond_PFC = unique(reshape(avg_dist_holder_PFC_re(5:8,1:5),[],1));
firstSecond_PFC = [firstSecond_PFC; unique(reshape(avg_dist_holder_PFC_re(1:5,6:9),[],1))];
firstSecond_PFC_mean = mean(firstSecond_PFC);
firstSecond_PFC_sem = std(firstSecond_PFC)/sqrt(length(firstSecond_PFC));

firstSecond_PFC_all = [first2_PFC; second2_PFC; firstSecond_PFC];
firstSecond_PFC_groups = [repmat({'first2_PFC'},1,length(first2_PFC)) repmat({'second2_PFC'},1,length(second2_PFC)) repmat({'firstSecond_PFC'},1,length(firstSecond_PFC))];

% Z score
firstSecond_PFC_Z_mean = mean([first2_PFC; second2_PFC; firstSecond_PFC]);
firstSecond_PFC_Z_SD = std([first2_PFC; second2_PFC; firstSecond_PFC]);

first2_PFC_Z = (first2_PFC - firstSecond_PFC_Z_mean)/firstSecond_PFC_Z_SD;
second2_PFC_Z = (second2_PFC - firstSecond_PFC_Z_mean)/firstSecond_PFC_Z_SD;
firstSecond_PFC_Z = (firstSecond_PFC - firstSecond_PFC_Z_mean)/firstSecond_PFC_Z_SD;

first2_PFC_Z_mean = mean(first2_PFC_Z);
first2_PFC_Z_sem = std(first2_PFC_Z)/sqrt(length(first2_PFC_Z));

second2_PFC_Z_mean = mean(second2_PFC_Z);
second2_PFC_Z_sem = std(second2_PFC_Z)/sqrt(length(second2_PFC_Z));

firstSecond_PFC_Z_mean = mean(firstSecond_PFC_Z);
firstSecond_PFC_Z_sem = std(firstSecond_PFC_Z)/sqrt(length(firstSecond_PFC_Z));

firstSecond_PFC_all_Z = [first2_PFC_Z; second2_PFC_Z; firstSecond_PFC_Z];

%%
[p,tbl,stats] = kruskalwallis(firstSecond_PFC_all,firstSecond_PFC_groups);
multcompare(stats)

%% plot bars
figure
errorbar([first2_PFC_mean,firstSecond_PFC_mean,second2_PFC_mean],[first2_PFC_sem firstSecond_PFC_sem second2_PFC_sem],...
    'ok','linewidth',2,'markerfacecolor','k','markersize',7,'capsize',10)

xlim([0 4])
xticks([0:1:4])
xticklabels({'','1st-1st','1st-2nd','2nd-2nd',''})
yticks([0:2:6])
ylim([0 6])
ylabel('Average distance A.U.')
set(gca,'fontsize',18)
title('PFC')

%% distance calc

umap_dist_HPC = squareform(pdist(reduction_HPC,'euclidean'));

figure
imagesc(umap_dist_HPC)

% square

umap_dist_HPC_all = [];
currStart = 1;
for currTrialID = 1:length(trial_IDs)
    for currBin = 1:full_numBins
        currBin_dists = umap_dist_HPC(currBin:full_numBins:length(trial_IDs)*full_numBins,currStart);
        currStart = currStart +1;
        umap_dist_HPC_all = [umap_dist_HPC_all currBin_dists];
    end
end

umap_dist_HPC_removeSelf = umap_dist_HPC_all;
umap_dist_HPC_removeSelf(umap_dist_HPC_removeSelf==0) = NaN;

umap_dist_HPC_removeSelf_re = reshape(umap_dist_HPC_removeSelf,[],length(trial_IDs));

% every column is a trial type visits
% every row is the pairwise distance of a point on trial type X to all other trial types
% trial types repeat every 9th row (9 TTs)
% for column 1, that's B on BC
% 1 10 19 are 1 to itself across time bins
% 2 11 20 comapre 1 to 2, or B on BC to E on DE
% 3 12 21 comapre 1 to 3, or B on BC to A on AB

% get the average distance for every pairwise comparison

avg_dist_holder_HPC = [];
for currTT = 1:length(trial_IDs)
    for currBin = 1:length(trial_IDs)
        avg_dist_holder_HPC = [avg_dist_holder_HPC; mean(umap_dist_HPC_removeSelf_re(currBin:length(trial_IDs):length(trial_IDs)*full_numBins,currTT))];
    end
end

avg_dist_holder_HPC(isnan(avg_dist_holder_HPC)) = [];

avg_dist_holder_HPC_re = reshape(avg_dist_holder_HPC,length(trial_IDs)-1,[]);

%
z_HPC = linkage(avg_dist_holder_HPC_re');

dend_label = {'B1' 'E1' 'A1' 'C1' 'D1' 'B2' 'E2' 'C2' 'D2'};
[H,T,outperm] = dendrogram(z_HPC,'Labels',dend_label);
%[H,T,outperm] = dendrogram(z);
set(H,'LineWidth',3,'Color','k');
title('HPC')

%% bars of 1st 1st-1st-2nd 2nd-2nd
% for 9 trial types as arranged above
%error('hardcoded idiot')


first2_HPC = unique(reshape(avg_dist_holder_HPC_re(1:4,1:5),[],1));
first2_HPC_mean = mean(first2_HPC);
first2_HPC_sem = std(first2_HPC)/sqrt(length(first2_HPC));

second2_HPC = unique(reshape(avg_dist_holder_HPC_re(6:8,6:9),[],1));
second2_HPC_mean = mean(second2_HPC);
second2_HPC_sem = std(second2_HPC)/sqrt(length(second2_HPC));

firstSecond_HPC = unique(reshape(avg_dist_holder_HPC_re(5:8,1:5),[],1));
firstSecond_HPC = [firstSecond_HPC; unique(reshape(avg_dist_holder_HPC_re(1:5,6:9),[],1))];
firstSecond_HPC_mean = mean(firstSecond_HPC);
firstSecond_HPC_sem = std(firstSecond_HPC)/sqrt(length(firstSecond_HPC));

firstSecond_HPC_all = [first2_HPC; second2_HPC; firstSecond_HPC];
firstSecond_HPC_groups = [repmat({'first2_HPC'},1,length(first2_HPC)) repmat({'second2_HPC'},1,length(second2_HPC)) repmat({'firstSecond_HPC'},1,length(firstSecond_HPC))];

% Z score
firstSecond_HPC_Z_mean = mean([first2_HPC; second2_HPC; firstSecond_HPC]);
firstSecond_HPC_Z_SD = std([first2_HPC; second2_HPC; firstSecond_HPC]);

first2_HPC_Z = (first2_HPC - firstSecond_HPC_Z_mean)/firstSecond_HPC_Z_SD;
second2_HPC_Z = (second2_HPC - firstSecond_HPC_Z_mean)/firstSecond_HPC_Z_SD;
firstSecond_HPC_Z = (firstSecond_HPC - firstSecond_HPC_Z_mean)/firstSecond_HPC_Z_SD;

first2_HPC_Z_mean = mean(first2_HPC_Z);
first2_HPC_Z_sem = std(first2_HPC_Z)/sqrt(length(first2_HPC_Z));

second2_HPC_Z_mean = mean(second2_HPC_Z);
second2_HPC_Z_sem = std(second2_HPC_Z)/sqrt(length(second2_HPC_Z));

firstSecond_HPC_Z_mean = mean(firstSecond_HPC_Z);
firstSecond_HPC_Z_sem = std(firstSecond_HPC_Z)/sqrt(length(firstSecond_HPC_Z));

firstSecond_HPC_all_Z = [first2_HPC_Z; second2_HPC_Z; firstSecond_HPC_Z];



%%
[p,tbl,stats] = kruskalwallis(firstSecond_HPC_all,firstSecond_HPC_groups);
multcompare(stats)

%% plot bars
figure
errorbar([first2_HPC_mean,firstSecond_HPC_mean,second2_HPC_mean],[first2_HPC_sem firstSecond_HPC_sem second2_HPC_sem],...
    'ok','linewidth',2,'markerfacecolor','k','markersize',7,'capsize',10)

xlim([0 4])
xticks([0:1:4])
xticklabels({'','1st-1st','1st-2nd','2nd-2nd',''})
yticks([0:2:6])
ylim([0 6])
ylabel('Average distance A.U.')
set(gca,'fontsize',18)
title('HPC')

%% distance calc - remove home, esp for PFC
% home goes to approx 11-12 if 20

home_idx_PFC = round(full_numBins - full_numBins/3,0); % what index value to start center at. final third should be good (home - center - choice arm)
%home_idx = skipHome_offset_PFC;

umap_dist_PFC_removeSelf_re_noHome = umap_dist_PFC_removeSelf_re;

% delete distances on start of trajectories, including home
umap_dist_PFC_removeSelf_re_noHome(1:home_idx_PFC*length(trial_IDs),:) = [];


%% get the average distance for every pairwise comparison

avg_dist_PFC_holder_noHome = [];
for currTT = 1:length(trial_IDs)
    for currBin = 1:length(trial_IDs)
        avg_dist_PFC_holder_noHome = [avg_dist_PFC_holder_noHome; mean(umap_dist_PFC_removeSelf_re_noHome(currBin:length(trial_IDs):length(trial_IDs)*(full_numBins-home_idx_PFC),currTT))];
    end
end

avg_dist_PFC_holder_noHome(isnan(avg_dist_PFC_holder_noHome)) = [];

avg_dist_PFC_holder_noHome = reshape(avg_dist_PFC_holder_noHome,length(trial_IDs)-1,[]);

% I dont care which arms are most similar at choice arms compared to all others
% i want to see how arms visited on diff trial types and order are most similar
% A5 B3 C6 D7 E4


%         [15, 122, 34];... % dark green B AB BC BD
%             [87, 14, 156];... % dark purple E DE AE
%             [16, 43, 148];... % dark blue A AB AE
%             [191, 0, 0];... % dark red C BC CD
%             [179, 102, 0];... % dark orange D DE BD CD
%
%         [2, 247, 31];... % bright green B AB
%             [132, 0, 255];... % bright purple E DE AE
%             [255, 0, 0];... % bright red C BC
%             [255, 128, 0];... % bright orange D BD CD

BB = avg_dist_PFC_holder_noHome(5,1);
CC = avg_dist_PFC_holder_noHome(7,4);
DD = avg_dist_PFC_holder_noHome(8,5);
EE = avg_dist_PFC_holder_noHome(6,2);

arm_self_distances_PFC = [BB CC DD EE];

% compare to, all others
avg_dist_holder_noHome_vector_PFC = avg_dist_PFC_holder_noHome(:);

avg_dist_holder_noHome_allDist_PFC = unique(avg_dist_holder_noHome_vector_PFC); % has many dupes cause pairwise

% remove same arms
arm_others_distances_PFC = avg_dist_holder_noHome_allDist_PFC(~ismember(avg_dist_holder_noHome_allDist_PFC,arm_self_distances_PFC));

arm_self_distances_PFC_mean = mean(arm_self_distances_PFC);
arm_self_distances_PFC_sem = std(arm_self_distances_PFC)/sqrt(length(arm_self_distances_PFC));

arm_others_distances_PFC_mean = mean(arm_others_distances_PFC);
arm_others_distances_PFC_sem = std(arm_others_distances_PFC)/sqrt(length(arm_others_distances_PFC));

arm_PFC_all = [arm_self_distances_PFC'; arm_others_distances_PFC];
arm_PFC_groups = [repmat({'same_PFC'},1,length(arm_self_distances_PFC)) repmat({'diff_PFC'},1,length(arm_others_distances_PFC))];

% Z score
arm_PFC_z_mean = mean([arm_self_distances_PFC'; arm_others_distances_PFC]);
arm_PFC_z_SD = std([arm_self_distances_PFC'; arm_others_distances_PFC]);

arm_self_distances_PFC_Z = (arm_self_distances_PFC-arm_PFC_z_mean)/arm_PFC_z_SD;
arm_others_distances_PFC_Z = (arm_others_distances_PFC-arm_PFC_z_mean)/arm_PFC_z_SD;

arm_self_distances_PFC_Z_mean = mean(arm_self_distances_PFC_Z);
arm_self_distances_PFC_Z_sem = std(arm_self_distances_PFC_Z)/sqrt(length(arm_self_distances_PFC_Z));

arm_others_distances_PFC_Z_mean = mean(arm_others_distances_PFC_Z);
arm_others_distances_PFC_Z_sem = std(arm_others_distances_PFC_Z)/sqrt(length(arm_others_distances_PFC_Z));

arm_PFC_all_Z = [arm_self_distances_PFC_Z'; arm_others_distances_PFC_Z];



%%
[p,tbl,stats] = kruskalwallis(arm_PFC_all,arm_PFC_groups);
multcompare(stats)

%% plot bars
figure
errorbar([arm_self_distances_PFC_mean,arm_others_distances_PFC_mean],[arm_self_distances_PFC_sem arm_others_distances_PFC_sem],...
    'ok','linewidth',2,'markerfacecolor','k','markersize',7,'capsize',10)

xlim([0 3])
xticks([0:1:3])
xticklabels({'','Same arm','Other arms',''})

yticks([0:2:6])
ylim([0 6])


ylabel('Average distance A.U.')
set(gca,'fontsize',18)
title('PFC')

%% distance calc - remove home, esp for HPC
% home goes to approx 11-12 if 20

home_idx_HPC = round(full_numBins - full_numBins/3,0); % what index value to start center at. final third should be good (home - center - choice arm)
%home_idx = skipHome_offset_HPC;

umap_dist_HPC_removeSelf_re_noHome = umap_dist_HPC_removeSelf_re;

% delete distances on start of trajectories, including home
umap_dist_HPC_removeSelf_re_noHome(1:home_idx_HPC*length(trial_IDs),:) = [];


%% get the average distance for every pairwise comparison

avg_dist_HPC_holder_noHome = [];
for currTT = 1:length(trial_IDs)
    for currBin = 1:length(trial_IDs)
        avg_dist_HPC_holder_noHome = [avg_dist_HPC_holder_noHome; mean(umap_dist_HPC_removeSelf_re_noHome(currBin:length(trial_IDs):length(trial_IDs)*(full_numBins-home_idx_HPC),currTT))];
    end
end

avg_dist_HPC_holder_noHome(isnan(avg_dist_HPC_holder_noHome)) = [];

avg_dist_HPC_holder_noHome = reshape(avg_dist_HPC_holder_noHome,length(trial_IDs)-1,[]);

% I dont care which arms are most similar at choice arms compared to all others
% i want to see how arms visited on diff trial types and order are most similar
% A5 B3 C6 D7 E4


%         [15, 122, 34];... % dark green B AB BC BD
%             [87, 14, 156];... % dark purple E DE AE
%             [16, 43, 148];... % dark blue A AB AE
%             [191, 0, 0];... % dark red C BC CD
%             [179, 102, 0];... % dark orange D DE BD CD
%
%         [2, 247, 31];... % bright green B AB
%             [132, 0, 255];... % bright purple E DE AE
%             [255, 0, 0];... % bright red C BC
%             [255, 128, 0];... % bright orange D BD CD

BB = avg_dist_HPC_holder_noHome(5,1);
CC = avg_dist_HPC_holder_noHome(7,4);
DD = avg_dist_HPC_holder_noHome(8,5);
EE = avg_dist_HPC_holder_noHome(6,2);

arm_self_distances_HPC = [BB CC DD EE];

% compare to, all others
avg_dist_holder_noHome_vector_HPC = avg_dist_HPC_holder_noHome(:);

avg_dist_holder_noHome_allDist_HPC = unique(avg_dist_holder_noHome_vector_HPC); % has many dupes cause pairwise

% remove same arms
arm_others_distances_HPC = avg_dist_holder_noHome_allDist_HPC(~ismember(avg_dist_holder_noHome_allDist_HPC,arm_self_distances_HPC));

% mean SEM

arm_self_distances_HPC_mean = mean(arm_self_distances_HPC);
arm_self_distances_HPC_sem = std(arm_self_distances_HPC)/sqrt(length(arm_self_distances_HPC));

arm_others_distances_HPC_mean = mean(arm_others_distances_HPC);
arm_others_distances_HPC_sem = std(arm_others_distances_HPC)/sqrt(length(arm_others_distances_HPC));

arm_HPC_all = [arm_self_distances_HPC'; arm_others_distances_HPC];
arm_HPC_groups = [repmat({'same_HPC'},1,length(arm_self_distances_HPC)) repmat({'diff_HPC'},1,length(arm_others_distances_HPC))];

% Z score
arm_HPC_z_mean = mean([arm_self_distances_HPC'; arm_others_distances_HPC]);
arm_HPC_z_SD = std([arm_self_distances_HPC'; arm_others_distances_HPC]);

arm_self_distances_HPC_Z = (arm_self_distances_HPC-arm_HPC_z_mean)/arm_HPC_z_SD;
arm_others_distances_HPC_Z = (arm_others_distances_HPC-arm_HPC_z_mean)/arm_HPC_z_SD;

arm_self_distances_HPC_Z_mean = mean(arm_self_distances_HPC_Z);
arm_self_distances_HPC_Z_sem = std(arm_self_distances_HPC_Z)/sqrt(length(arm_self_distances_HPC_Z));

arm_others_distances_HPC_Z_mean = mean(arm_others_distances_HPC_Z);
arm_others_distances_HPC_Z_sem = std(arm_others_distances_HPC_Z)/sqrt(length(arm_others_distances_HPC_Z));

arm_HPC_all_Z = [arm_self_distances_HPC_Z'; arm_others_distances_HPC_Z];


%%
[p,tbl,stats] = kruskalwallis(arm_HPC_all,arm_HPC_groups);
multcompare(stats)

%% plot bars
figure
errorbar([arm_self_distances_HPC_mean,arm_others_distances_HPC_mean],[arm_self_distances_HPC_sem arm_others_distances_HPC_sem],...
    'ok','linewidth',2,'markerfacecolor','k','markersize',7,'capsize',15)

xlim([0 3])
xticks([0:1:3])
xticklabels({'','Same arm','Other arms',''})

yticks([0:2:6])
ylim([0 6])


ylabel('Average distance A.U.')
set(gca,'fontsize',18)
title('HPC')

%% combined arm distances

figure
errorbar([arm_self_distances_HPC_mean,arm_self_distances_PFC_mean, arm_others_distances_HPC_mean,arm_others_distances_PFC_mean],[arm_self_distances_HPC_sem arm_self_distances_PFC_sem arm_others_distances_HPC_sem arm_others_distances_PFC_sem],...
    'ok','linewidth',2,'markerfacecolor','k','markersize',7,'capsize',15)

xlim([0 5])
xticks([0 1.5 3.5])
xticklabels({'','Same arm','Other arms'})

yticks([0:2:6])
ylim([0 6])

ylabel('Average distance A.U.')
set(gca,'fontsize',18)
title('HPC and PFC arm distances')

%% combined arm distances z

figure
errorbar([arm_self_distances_HPC_Z_mean,arm_self_distances_PFC_Z_mean, arm_others_distances_HPC_Z_mean,arm_others_distances_PFC_Z_mean],[arm_self_distances_HPC_Z_sem arm_self_distances_PFC_Z_sem arm_others_distances_HPC_Z_sem arm_others_distances_PFC_Z_sem],...
    'ok','linewidth',2,'markerfacecolor','k','markersize',7,'capsize',15)


xlim([0 5])
xticks([0 1.5 3.5])
xticklabels({'','Same arm','Other arms'})

yticks([-2:1:2])
ylim([-2 2])

ylabel('Z scored average distance')
set(gca,'fontsize',18)
title('HPC and PFC arm distances')

%% stats z
[p,tbl,stats] = anova1([arm_HPC_all_Z; arm_PFC_all_Z],[arm_HPC_groups arm_PFC_groups]);


[c,m,h,gnames] = multcompare(stats);

%% combined first second
figure
errorbar([first2_HPC_mean,first2_PFC_mean,firstSecond_HPC_mean,firstSecond_PFC_mean,second2_HPC_mean,second2_PFC_mean],[first2_HPC_sem first2_PFC_sem firstSecond_HPC_sem firstSecond_PFC_sem second2_HPC_sem second2_PFC_sem],...
    'ok','linewidth',2,'markerfacecolor','k','markersize',7,'capsize',15)

xlim([0 7])
xticks([0 1.5 3.5 5.5])
xticklabels({'','1st-1st','1st-2nd','2nd-2nd'})

yticks([0 2 4 6])
ylim([0 7])

ylabel('Average distance A.U.')
set(gca,'fontsize',18)
title('HPC and PFC phase distances')

%% stats

[p,tbl,stats] = kruskalwallis([firstSecond_HPC_all; firstSecond_PFC_all],[firstSecond_HPC_groups firstSecond_PFC_groups]);

[c,m,h,gnames] = multcompare(stats);

%% combined first second z scored
figure
errorbar([first2_HPC_Z_mean,first2_PFC_Z_mean,firstSecond_HPC_Z_mean,firstSecond_PFC_Z_mean,second2_HPC_Z_mean,second2_PFC_Z_mean],[first2_HPC_Z_sem first2_PFC_Z_sem firstSecond_HPC_Z_sem firstSecond_PFC_Z_sem second2_HPC_Z_sem second2_PFC_Z_sem],...
    'ok','linewidth',2,'markerfacecolor','k','markersize',7,'capsize',15)

xlim([0 7])
xticks([0 1.5 3.5 5.5])
xticklabels({'','1st-1st','1st-2nd','2nd-2nd'})

yticks([-2:1:2])
ylim([-2 2])

ylabel('Z scored average distance')
set(gca,'fontsize',18)
title('HPC and PFC phase distances')

%% stats z

[p,tbl,stats] = anova1([firstSecond_HPC_all_Z; firstSecond_PFC_all_Z],[firstSecond_HPC_groups firstSecond_PFC_groups]);

[c,m,h,gnames] = multcompare(stats);











