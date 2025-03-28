
%%

% PCA on Firing rate 
% ----------------
LRcombined = [leftfr; rightfr];
[dim, num_data] = size(LRcombined);  
% dim/trials/obs/datapoints = Ntrials (left+right)
% num_data = number of neurons
% LRcombined or X is a Ntrials x Nneurons matrix

leftidx = 1:size(leftfr,1);
rightidx = size(leftfr,1)+1:size(LRcombined,1);

[COEFF, SCORES, LATENT, TSQUARED, EXPLAINED, MU] = pca(LRcombined);
SCORE = SCORES;
% COEFF returns N_neurons prncipal components in columns, with each PC
% having Nneurons coefficients along original dimensions

% SCORES are the projections: Original data in Ntrials projected along
% the new N_neu dimensions - we will look at the first 3



%% Firing rate Figures

figure('color','w');
scatter3(SCORE(leftidx,1),SCORE(leftidx,2),SCORE(leftidx,3),100,...
                    'filled','MarkerFaceColor','r',...
                        'MarkerEdgeColor','w');                    
hold on,
scatter3(SCORE(rightidx,1),SCORE(rightidx,2),SCORE(rightidx,3),100,...
                    'filled','MarkerFaceColor','b',...
                        'MarkerEdgeColor','w');

                     
figure;
subplot(2,1,1);
bar(EXPLAINED);
ylabel('Percentage variance explained');
xlabel('Dimension number');
box off;
axis([0 3.5 0 100]);

subplot(2,1,2);
bar(cumsum(EXPLAINED));
ylabel('Percentage total variance explained using components 1-N');
xlabel('Dimension number');
box off;
axis([0 3.5 0 100]);
                   




%% 

% PCA on firing rate vectors
% ------------------------

win = [200 800]; %-200ms to 800ms
leftvector=[]; rightvector=[]; %For each timebin, save Ntrial X Nnenuron firing matrix

Nneu = size(lefttrials,1); 
Nlefttr = length(leftidx);
Nrighttr = length(rightidx);

binsize=100;

bins = -win(1):binsize:win(2);
Nbins = length(bins)-1; % histogram will have bins-1 edges

% For each bin, get a NtrxNspk matrix
for i=1:Nbins
    
    storeleftbindata = []; storerightbindata = []; % Reinitialize store for current bin
    for neu = 1:Nneu
        currleft = lefttrials{neu};
        currright = righttrials{neu};
        
        currleftbindata = currleft(:,i); %current neuron's data for timebin i
        storeleftbindata = [storeleftbindata, currleftbindata];
        
        currrightbindata = currright(:,i); %current neuron's data for timebin i
        storerightbindata = [storerightbindata, currrightbindata];    
    end
    
    leftvector{i} = storeleftbindata;
    rightvector{i} = storerightbindata;
    
end

%% 


% Do PCA in each timebin
% ---------------------

store_Scores = []; store_Explained = [];
store_Scores3 = []; store_Explained3 = [];

for i = 1:Nbins
    X_left = leftvector{i};
    X_right = rightvector{i};
    
    LRcombined = [X_left; X_right];
    [COEFF, SCORES, LATENT, TSQUARED, EXPLAINED, MU] = pca(LRcombined);
    SCORE = SCORES;
    
    store_Scores{i} = SCORES;
    store_Explained{i} = EXPLAINED;
    store_Explained3 = [store_Explained3;sum(EXPLAINED(1:3))]; % explain variance in each time bin
    store_Scores3{i} = SCORES(:,1:3); % First 3 components only
end

figure; hold on;
bar(store_Explained3);
ylabel('Percentage variance explained by 3 PCs');
xlabel('Time Bin number');
box off;
axis([0 13.5 0 100]);


%% 


% GET average PCA trajectory for left and right trials, and also per trials 

meanleft=[]; meanright=[];
lefttrials_pc = zeros(Nlefttr,Nbins,3); righttrials_pc =zeros(Nrighttr,Nbins,3);
for i = 1:Nbins
    
    % Store for current bin - mean and err for PCs
    curr_scores = store_Scores3{i};
    currleft_scores = curr_scores(leftidx,:);
    currright_scores = curr_scores(rightidx,:);
    meanleft(i,:) = nanmean(currleft_scores,1);   % For current timebin, save mean of 1st 3 PCs
    meanright(i,:) = nanmean(currright_scores,1); 
    errleft(i,:) = nansem(currleft_scores,1);     % For current timebin, save sem of 1st 3 PCs
    errright(i,:) = nansem(currright_scores,1);
    
    % Gather to plot trial-by-trial
    lefttrials_pc(:,i,:)= currleft_scores;
    righttrials_pc(:,i,:)= currright_scores;
    
end





% 3d plot
figure(99); hold on;
plot3(meanleft(:,1),meanleft(:,2),meanleft(:,3),'ro-', 'LineWidth',4);
plot3(meanright(:,1),meanright(:,2),meanright(:,3),'bx-', 'LineWidth',4);



% 2d plot
figure(100); hold on;
plot(meanleft(:,1),meanleft(:,2),'ro-', 'LineWidth',4);
plot(meanright(:,1),meanright(:,2),'bx-', 'LineWidth',4);


%% 

% 1d plot, with sem/shuffle/95% interval
% -----------------------


%timeaxis = -1000*win(1):100:1000*win(2);
timeaxis = -win(1):100:win(2);
timeaxis = timeaxis(1:end-1);

PCnum=1;

% PLOT mean and sem
figure(10); hold on;
plot(timeaxis,meanleft(:,PCnum),'ro-', 'LineWidth',4);
plot(timeaxis,meanleft(:,PCnum)+errleft(:,PCnum),'r--', 'LineWidth',2);
plot(timeaxis,meanleft(:,PCnum)-errleft(:,PCnum),'r--', 'LineWidth',2);

plot(timeaxis,meanright(:,PCnum),'bx-', 'LineWidth',4);
plot(timeaxis,meanright(:,PCnum)+errright(:,PCnum),'b--', 'LineWidth',2);
plot(timeaxis,meanright(:,PCnum)-errright(:,PCnum),'b--', 'LineWidth',2);


keyboard;

