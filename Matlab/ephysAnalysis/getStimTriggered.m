function [trigSpikes, byTrial, lengthStim] = getStimTriggered(stimMatrix, clusterTimes, stimType, numMulti)


if strcmp(stimType, 'opto')  == 1 
    record = 3;
    startIND = find(stimMatrix(:,2,record) == 200);
    endIND = find(stimMatrix(:,2,record) == 250);
   
elseif strcmp(stimType, 'whisker') == 1
    record = 2;
    startIND = find(stimMatrix(:,2,record) == 500);
    endIND = find(stimMatrix(:,2,record) == 550);
    
elseif strcmp(stimType, 'both') == 1
    record = 4;
    startIND = find(stimMatrix(:,2,record) == 500);
    endIND = find(stimMatrix(:,2,record) == 550);
else
    error('Invalid Stimulation Type')
end

numClusters = length(clusterTimes);
sweepsPerRec = length(stimMatrix) / 4;



trigSpikes = cell(numClusters,1);

byTrial = cell(numClusters, sweepsPerRec);

for cluster = 1:numClusters
    
    
    allTrigNormed = [];
    
    
    
    for sweep = 1:length(endIND)

        Sind = startIND(sweep); 

 
        Eind = endIND(sweep);
        
            
        start = stimMatrix(Sind,1,record) - 1.5;
        stop = stimMatrix(Eind,1,record) + 1;
        

        
        allSpikes = clusterTimes{cluster};

        trigged = allSpikes(allSpikes>start & allSpikes<stop);
        
        normed = trigged - start;
        
        byTrial{cluster, sweep} = normed;
        
        for i = 1:length(normed)
            
            allTrigNormed = [allTrigNormed normed(i)];
        end
 
    end
    

    
    trigSpikes{cluster} = allTrigNormed;
    
    
    
end

multiClusters = [];

if strcmp(numMulti, 'all') == 1
    numMulti = 1:numClusters;
end
    
for i = numMulti
    oneCluster = trigSpikes{i};
    for ii = 1:length(oneCluster)
        multiClusters = [oneCluster(ii) multiClusters];
    end
end
    
lengthStim = stop - start;



