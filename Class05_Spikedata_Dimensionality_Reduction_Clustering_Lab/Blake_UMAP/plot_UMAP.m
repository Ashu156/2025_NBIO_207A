function [] = plot_UMAP(reduction_HPC,full_numBins,trial_IDs,skipHome_offset_HPC,cmap_firstSecond_train,markers)

% Plot UMAP data

currStart = 1; % where to start reading data
currEnd = full_numBins; % how long is a trial

UMAP_dims = length(reduction_HPC(1,:));

nexttile
hold on
for currChoiceArmID = 1:length(trial_IDs) % for each trial type

    if trial_IDs(currChoiceArmID) > 20 % if using all
        skipHomeHere = 0;
    else
        skipHomeHere = skipHome_offset_HPC; % if skipping an epoch
    end

    if UMAP_dims == 3 % 3D plot

        plot3(reduction_HPC(currStart+skipHomeHere:currEnd,1),reduction_HPC(currStart+skipHomeHere:currEnd,2),reduction_HPC(currStart+skipHomeHere:currEnd,3),'LineWidth',2,'color',cmap_firstSecond_train(currChoiceArmID,:)/256); % plot UMAP result

        %scatter3(reduction_HPC(currStart+skipHomeHere:currEnd,1),reduction_HPC(currStart+skipHomeHere:currEnd,2),reduction_HPC(currStart+skipHomeHere:currEnd,3),'filled','LineWidth',2,'MarkerFaceColor',cmap_firstSecond_train(currChoiceArmID,:)/256);

        scatter3(reduction_HPC(currStart+skipHomeHere,1),reduction_HPC(currStart+skipHomeHere,2),reduction_HPC(currStart+skipHomeHere,3),150,'k','filled',markers{currChoiceArmID}); % plot starting points as markers

    elseif UMAP_dims == 2 % 2D plot

        plot(reduction_HPC(currStart+skipHomeHere:currEnd,1),reduction_HPC(currStart+skipHomeHere:currEnd,2),'LineWidth',2,'color',cmap_firstSecond_train(currChoiceArmID,:)/256); % plot UMAP result

        %scatter(reduction_HPC(currStart+skipHomeHere:currEnd,1),reduction_HPC(currStart+skipHomeHere:currEnd,2),'filled','LineWidth',2,'MarkerFaceColor',cmap_firstSecond_train(currChoiceArmID,:)/256);

        scatter(reduction_HPC(currStart+skipHomeHere,1),reduction_HPC(currStart+skipHomeHere,2),150,'k','filled',markers{currChoiceArmID}); % plot starting points as markers

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

% h = zeros(3, 1);
% h(1) = plot(NaN,NaN,'color',[16, 43, 148]/256,'linewidth',2);
% h(2) = plot(NaN,NaN,'color',[15, 122, 34]/256,'linewidth',2);
% h(3) = plot(NaN,NaN,'color',[191, 0, 0]/256,'linewidth',2);
% h(4) = plot(NaN,NaN,'color',[179, 102, 0]/256,'linewidth',2);
% h(5) = plot(NaN,NaN,'color',[87, 14, 156]/256,'linewidth',2);
% legend(h, 'A','B','C','D','E');

set(gca,'fontsize',18)

end % end function