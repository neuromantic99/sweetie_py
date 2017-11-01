function [stimMatrix, clusterTimes, allNormed, channel, numSU] = clusterPreprocess(fPath, stimPath, clusterType, zeroCluster)



% fPath is the path to the NPY files
% StimPath is the path to the .mat stimulation time file
% clusterType should = 'SU' or 'MU' (or 'Noise' but unlikely to be needed)
% zeroCluster should = 1 if there is a 0 cluster and 0 if there is not zero
% cluster

% returns
% SU times: a cell of all spike times of all clusters labelled with
% clusterType

% allNormed: a 1d matrix containing all clsuter spike times normalised to within a
% single sweep (not yet showing millisecond precision)






fstimMatrix = open(stimPath);

stimMatrix = getfield(fstimMatrix, 'out');

sampleRate = 30000;


spikeClusters = double(readNPY(strcat(fPath, 'spike_clusters.npy')));

spikeTimeSample = double(readNPY(strcat(fPath, 'spike_times.npy')));

spikeTimes = spikeTimeSample / sampleRate;

% total number of sweeps across recordings
totSweeps = length(stimMatrix) * length(stimMatrix(1,:,1))  / 4 ;

% length of sweep
sweepLength = max(spikeTimes) / totSweeps;

[~, ~, clusterInfo] = xlsread(strcat(fPath, 'ClusterTypes.xlsx'),'Sheet1');
clusterInfo = clusterInfo(2:end,:);
clusterInfo(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),clusterInfo)) = {''};

% get the string corresponding to the types of clusters
types = clusterInfo(:,2);

% get the numbers of the clusters that are single units
if strcmp(clusterType, 'all') == 1
    clusterIND = strmatch('SU', types)';
    
    numSU = length(clusterIND);
    clusterIND2 = strmatch('MU', types);

    for i = 1:length(clusterIND2)
        clusterIND = [clusterIND clusterIND2(i)];
    end
    
elseif  strcmp(clusterType, 'SU') == 1 || strcmp(clusterType, 'MU') == 1
    clusterIND = strmatch(clusterType, types);
else
    error('Invalid Cluster Type');
end
    

    





numClusters = length(clusterIND);

% create blank cells to store the index and times of single unit spikes
clusterSpikesIND = cell(numClusters, 1);
clusterTimes = cell(numClusters, 1);

% cells to store the index of the sweep during which each spike arose
n = cell(numClusters,1);
bins = cell(numClusters,1);
edges = linspace(0,sweepLength*totSweeps,totSweeps);

% store index and spike times of single unit clusters. 1 must sometimes be subtracted due to the 0
% cluster
%keyboard
channel = zeros(numClusters, 1);
allChannels = clusterInfo(:,4);

for i = 1:numClusters
    try
    channel(i) = allChannels{clusterIND(i)};
    catch
        error('one of your clusters doesnt have a corresponding channel number you berk')
    end
    
    if zeroCluster == 1
        clusterSpikesIND{i} = find(spikeClusters == clusterIND(i) - 1);
        
    elseif zeroCluster == 0
        clusterSpikesIND{i} = find(spikeClusters == clusterIND(i));

    else
        error('Invalid zero cluster arugment')
    end
    
    clusterTimes{i} = spikeTimes(clusterSpikesIND{i});
    
    
    clusterTimes{i} = vertcat(clusterTimes{i}, max(spikeTimes));   
    [n{i},~,bins{i}] = histcounts(clusterTimes{i}, 120);
end

% cells to store binned spike times and spike times
binnedTimes = cell(numClusters, totSweeps);
normedTimes = cell(numClusters, totSweeps);
normaliser = cell(numClusters, totSweeps);


allNormed = [];


for cluster = 1:numClusters
    for sweep = 1:totSweeps
        
        % find index of each bin corresponding to individual sweeps
        ind = find(bins{cluster} == sweep);
        % run through individual clusters
        unit = clusterTimes{cluster};
        % store spike time from each cluster in correct bin
        binnedTimes{cluster,sweep} = unit(ind);
        % normalise spike times
        normaliser{cluster, sweep} = (sweep - 1) * sweepLength;
        normedTimes{cluster, sweep} = binnedTimes{cluster, sweep} - normaliser{cluster, sweep};
        
        % store all normalised times in a 1d matrix
        singleSweep = normedTimes{cluster, sweep};
        
        for i = 1:length(singleSweep)
            
            singleValue = singleSweep(i);

            allNormed = [allNormed singleValue];
            
        end
        
    end
    
end


    
