
% Data from an olfactory-cued experiment, Symanski et al., 2023
% Two olfactory cues - associated with left and right trails on a maze
% Left trials: 49, Right trials, 46
% 26 neurons, Firing rate in 30 time bins [-450:50:1000] ms.
% 0 ms is time of cue

bins = [-450:50:1000];
load ("Example5_olfact_FRdata.mat");
leftTrials_ori = leftTrials;
rightTrials = rightTrials;
%load('cs_FRdata.mat')
leftTrials = cellfun(@(x) x(:), leftTrials,'UniformOutput',false);
rightTrials = cellfun(@(x) x(:), rightTrials,'UniformOutput',false);
L = cat(2,leftTrials{:})';
R = cat(2,rightTrials{:})';
T = [L; R];

[coeff,score,latent,tsqaured,explained,mu] = pca(T);
% Note: we can also use the svd approach

figure; hold on;
plot(explained,'--o')
%sum(explained(1:3))

%%
figure;
imagesc(score); title(sprintf('scores of pcs; columns are components; rows are score\nfirst half = left'));
hold on; l=line([0 95],[49.5 49.5]);
l.Color='r';
l.LineStyle=':'
l.LineWidth=3;
xlabel('principal components'); ylabel('trials');

%% difference in first 2 PCs

figure; 
area(score(:,1)+score(:,2),'linewidth',2)
hold on; 
text(10,-220,'Left Trials','fontsize',24,'color','k');
text(50,180,'Right Trials','fontsize',24,'color','k');
l=line([0 100],[0 0]);
l.Color='k';
l.LineStyle=':'
l.LineWidth=2;
l=line([49 49],get(gca,'ylim'));
l.Color='r';
l.LineStyle=':'
l.LineWidth=3;
xlabel('Trial');
ylabel('Total Score of Components');
title(sprintf('sum of first two components \nseparates types\n'),'fontsize',20);

% PC components over time - try the first 2 PCs/ 3 PCs/ 4 Pcs
Nt = 30;
Nt_all = size(L,2);

figure; hold on
plot(coeff(:,1))
pc1 = reshape(coeff(:,1),26, 30);
figure; hold on
plot(sum(pc1,1));


coefft = coeff';
% projections of PC 
projections = score(:,1:2)*coefft(1:2,:); 

projL = projections(1:49,:);
projR = projections(50:end,:);

figure; hold on
plot(mean(projL,1));
plot(mean(projR,1),'r');

leftp = reshape(mean(projL,1),26, 30);
rightp = reshape(mean(projR,1),26, 30);

bins = [-450:50:1000];
figure; hold on
plot(bins,mean(leftp,1));
plot(bins,mean(rightp,1),'r');






