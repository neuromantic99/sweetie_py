function [trigSpikes, allTrials, unitData, numSU] = structureClusterData(fPath, stimPath, clusterType, stimType, zeroClust)


[stimMatrix, clusterTimes, allNormed, channels, numSU] = clusterPreprocess(fPath, stimPath, clusterType, zeroClust);

[trigSpikes, allTrials, lengthStim] = getStimTriggered(stimMatrix, clusterTimes, stimType, clusterType);



numClusters = length(clusterTimes);


unitData=struct();
% for i = 1:numClusters
%     
%     [meanFit, stimResponsive, jitter, time2peak, SRI, finalBinSize, conf] = PSTH(trigSpikes{i}, 10);
%     
%     unitData(i).meanFit = meanFit;
%     unitData(i).stimResponsive = stimResponsive;
%     unitData(i).jitter = jitter;
%     unitData(i).time2Peak = time2peak;
%     unitData(i).SRI = SRI;
%     unitData(i).finalBinSize = finalBinSize;
%     unitData(i).conf = conf;
%     
% end

depths = linspace(800, 25, 32);

channels = channels + 1;

for i = 1:length(channels)
    
    clusterDepths(i) = depths(channels(i));
end

for i = 1:length(clusterDepths)
    
    unitData(i).depths = clusterDepths(i);
end

for i = 1:numClusters
    unitData(i).singleTrials = allTrials(i,:);
    unitData(i).allTrials = trigSpikes{i};
end


for i = 1:numClusters
    unitData(i).singleTrials = allTrials(i,:);
    unitData(i).allTrials = trigSpikes{i};
    if i <= numSU
        unitData(i).clusterType = 'SU';
    else
        unitData(i).clusterType = 'MU';
    end
end






