function [] = rasterPlotter(toRaster, trialNum, clusterDepths, tMin, tMax)



numClusters = length(clusterDepths);

close all, figure, hold on
for i = 1:7
   
    
    
    
    allSpikes = toRaster(i).singleTrials{trialNum};
    sensorySpikes = allSpikes(allSpikes > tMin & allSpikes < tMax);

    yaxis = ones(length(sensorySpikes)) * clusterDepths(i);
    set(gca, 'xlim', [tMin, tMax])
    %set(gca, 'xticklabel', [0,30,60,90,120,150,180])
    plot(sensorySpikes, yaxis, '.','markers',20)
    ylabel('Depth um')
    set(gca, 'ylim',[0 800])
    xlabel('time (ms)')
    set(gca, 'fontsize', 20)
    title('Without Optogenetics', 'fontsize', 20)
    
end

hold off