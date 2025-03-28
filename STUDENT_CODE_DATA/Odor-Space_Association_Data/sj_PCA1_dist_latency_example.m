
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
binsize=0.1;
binsize_ms=1000*binsize;
win1 = -win(1); win2 = win(2);
timeaxis = -win(1):binsize_ms:win(2);
goodbins = [win1:binsize_ms:win(2)-binsize_ms]; 

leftvector=[]; rightvector=[]; %For each timebin, save Ntrial X Nnenuron firing matrix

Nneu = size(lefttrials,1); 
Nlefttr = length(leftidx);
Nrighttr = length(rightidx);
bins = -win(1):binsize_ms:win(2);
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

% b) Also, GET average PCA trajectory for left and right trials, and also per trial
% Also get DISTANCE METRIC FOR 1st 3 PCs only

% For storing PC values
% -------------------
store_Scores = []; store_Explained = [];
store_Scores3 = []; store_Explained3 = [];

% For storing Average and variance of PC values
% ---------------------------------------------
meanleft=[]; meanright=[];
lefttrials_pc = zeros(Nlefttr,Nbins,3); righttrials_pc =zeros(Nrighttr,Nbins,3);

% Do only DIST between average trajectories for Left and Right
store_avg_DISTPC1=[];  % Avg left vs Avg right


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

     % Store for current bin - mean and err for PCs
     % --------------------------------------------
    curr_scores = store_Scores3{i};
    currleft_scores = curr_scores(leftidx,:);
    currright_scores = curr_scores(rightidx,:);
    meanleft(i,:) = nanmean(currleft_scores,1);   % For current timebin, save mean across trials of 1st 3 PCs/1st PC
    meanright(i,:) = nanmean(currright_scores,1); 
    errleft(i,:) = nansem(currleft_scores,1);     % For current timebin, save sem across trials of 1st 3 PCs/ 1st PC
    errright(i,:) = nansem(currright_scores,1);
    stdleft(i,:) = nanstd(currleft_scores,1);     % Same for st dev
    stdright(i,:) = nanstd(currright_scores,1);    
    
    
    % Gather to plot trial-by-trial
    % -------------------------------
    lefttrials_pc(:,i,:)= currleft_scores;
    righttrials_pc(:,i,:)= currright_scores;
    
    
    % TRY DISTANCE ONLY between PCs averaged over trajectories, rather than
    % tr-by-tr
    % ---------------------------------------
    
    % 1PC only
    left_avgpc1 = meanleft(i,1); % Single value; avg of PC1 for bin i
    right_avgpc1 = meanright(i,1); % If 1 PC, then only 1 value for 1 left and right trial each
    
    %d=pdist2([left_avgpc1', right_avgpc1'],'euclidean');
    d=pdist([left_avgpc1'; right_avgpc1']);
    store_avg_DISTPC1(i)=d(1); % Will eventually be bin length eg. 11
   
    % 3 PCs
%     left_avgpc = meanleft(i,:);
%     right_avgpc = meanright(i,:);
%     d=pdist2([left_avgpc'; right_avgpc'],'euclidean');  % If 3 PCs, then 3 values for 1 left and right trial each
%     store_avg_DISTPC(i)=d(1,2);


end



figure; hold on;
bar(store_Explained3);
ylabel('Percentage variance explained by 3 PCs');
xlabel('Time Bin number');
box off;
axis([0 13.5 0 100]);

%% Do ShufflePCA and get PCA for shuffled trajectory.
% --------------------------------------------------

% d) Distance metric shuffle by taking distance between average shuffle left vs. right, rather
% than individual shuffled trials
store_avg_randDISTPC1=[]; % 1st PC
store_avg_randDISTPC=[]; % All PCs


for shuf = 1:itr    
    % Can generate randperm for each bin separately, or use same randperm
    % for all bins
    
    randtmp = randperm(Ntotaltr);
    randleftidx = randtmp(1:Nlefttr);
    randrightidx = randtmp(Nlefttr+1:end);
        
    for i = 1:Nbins
        X_left = leftvector{i};    % Ntr x Nneu matrix
        X_right = rightvector{i};
        X_combined = [X_left;X_right];
   
        randleftvec = X_combined(randleftidx,:);
        randrightvec = X_combined(randrightidx,:);
        randX_combined = [randleftvec;randrightvec];
        
        [randCOEFF, randSCORES] = pca(randX_combined);
        
        
        % Separate into Random left and right trials, and carry forward
        % Left and Right Shuff PCs
        % randscores is NtrXNpc
        curr_randleftSCORES = randSCORES(1:Nlefttr,:);  %NtrleftXNpc
        curr_randrightSCORES = randSCORES(Nlefttr+1:end,:); %NtrrightXNpc
        currbin_randleftScores_avg = mean(curr_randleftSCORES,1); % mean across trials %1XNpc
        currbin_randrightScores_avg = mean(curr_randrightSCORES,1); % mean across trials %1XNpc
        
       
        % Try getting dist directly from PCs averaged over trials, rather
        % than tr-by-tr below
        % ------------------
        % 1PC
        left_avgpc1=currbin_randleftScores_avg(1); % Single value; avg of PC1 for bin i
        right_avgpc1=currbin_randrightScores_avg(1);
        d=pdist([left_avgpc1'; right_avgpc1']); % If 1 PC, then only 1 value for 1 left and right trial each
        store_avg_randDISTPC1(shuf,i)=d(1); % Will eventually be shufXbin eg. 1000X11

        % 3 PCs
%         left_avgpc=currbin_randleftScores_avg(1:3); 
%         right_avgpc=currbin_randrightScores_avg(1:3);
%         d=dist([left_avgpc', right_avgpc']); % If 3 PCs, then 3 values for 1 left and right trial each
%         store_avg_randDISTPC(shuf,i)=d(1,2);
        
               
    end
    
end  % end shuf
   


% IMP
% Get Shuffle DIST PCsvalues Means and CIs - USING AVERAGE ACROSS SHUFFLES
shuffavgDIST_PC1 = mean(store_avg_randDISTPC1,1); % Mean across shuffles, for each timebin  
shuffavgCIDIST_PC1 = [prctile(store_avg_randDISTPC1,5,1);prctile(store_avg_randDISTPC1,95,1)]; 

% shuffavgDIST_PC = mean(store_avg_randDISTPC,1); % Mean across shuffles, for each timebin  
% shuffavgCIDIST_PC = [prctile(store_avg_randDISTPC,5,1);prctile(store_avg_randDISTPC,95,1)]; 





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



%% Plot PC distance metric. Real-intertrial distance vs. Shuffled
% -------------------------------------------------------------

timeaxis = -win(1):binsize_ms:win(2);
timeaxis = timeaxis(1:end-1);


figure(60); hold on; title ('PC Distance Metric; Shuff PCDist; 3PCs black, 1 PC mag');


% % This is left vs. right PC distances using average PC - 3 PCs
% plot(timeaxis,store_avg_DISTPC,'ko-', 'LineWidth',4,'MarkerSize',16);
% 
% % This is shuffle using average left vs right in each shuffle - 3 PCs
% plot(timeaxis,shuffavgDIST_PC,'go-', 'LineWidth',4);
% plot(timeaxis,shuffavgCIDIST_PC(2,:),'g--', 'LineWidth',2); % 95% CI
% plot(timeaxis,shuffavgCIDIST_PC(1,:),'g--', 'LineWidth',2); % 5% CI

%1 PC - same using average as above
plot(timeaxis,store_avg_DISTPC1,'mx-', 'LineWidth',4);
plot(timeaxis,shuffavgDIST_PC1,'co-', 'LineWidth',4);
plot(timeaxis,shuffavgCIDIST_PC1(2,:),'c--', 'LineWidth',2); % 95% CI
plot(timeaxis,shuffavgCIDIST_PC1(1,:),'c--', 'LineWidth',2); % 5% CI




keyboard;

