function [] = plot_PCA(score,full_numBins,trial_IDs,skipHome_offset,cmap_firstSecond_train,markers)

currStart = 1; % start reading
currEnd = full_numBins; % read a full trial worth of bins

nexttile
hold on
for currVisitArmID = 1:length(trial_IDs) % for each trial type

    if trial_IDs(currVisitArmID) > 20 % if using all
        skipHomeHere = 0;
    else
        skipHomeHere = skipHome_offset; % if skipping an epoch
    end

    plot3(score(currStart+skipHomeHere:currEnd,1),score(currStart+skipHomeHere:currEnd,2),score(currStart+skipHomeHere:currEnd,3),'LineWidth',2,'color',cmap_firstSecond_train(currVisitArmID,:)/256) % plot PCs

    scatter3(score(currStart+skipHomeHere,1),score(currStart+skipHomeHere,2),score(currStart+skipHomeHere,3),100,'k','filled',markers{currVisitArmID}); % markers for starts
    
    % increment writing 
    currStart = currEnd+1;
    currEnd = currEnd+(full_numBins); 
end % each choice arm

xlabel('PC1')
ylabel('PC2')
zlabel('PC3')

set(gca,'fontsize',18)

end