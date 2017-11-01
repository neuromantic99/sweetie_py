
function [integral] = similarityRatio(whisker1, tMin, tMax, goodClusters)

% good clusters should be a list of indexes for all the whisker responsive
% SUs

numTrials = length(whisker1(1).singleTrials);

% the number of single units in this recording

numClusters = length(goodClusters);


integral = ones(numClusters, numClusters, numTrials);

numSpikesCriteria = 6;


for sweep = 1:numTrials
    %     tMin = tWindows(sweep-1);
    %     tMax = tWindows(sweep);
    ISI = cell(numClusters,1);
    tLength = [];
    for i = 1:length(goodClusters)
        clusterISI = [];
        
        clust = goodClusters(i);
        trial = whisker1(clust).singleTrials{sweep};
        
        trialTrunc = trial(trial > tMin & trial < tMax);
        
        %take 1000 time instances during which to calculate the ISI
        numInstances = 1000;
        instances = linspace(tMin, tMax, numInstances);
        
        for ii = 1:numInstances
            
            
            
            t = instances(ii);
            
            
            lessT = trialTrunc(trialTrunc < t);
            minInst = max(lessT);
            
            moreT = trialTrunc(trialTrunc > t);
            maxInst = min(moreT);
            
            if isempty(lessT) == 1 || isempty(moreT) == 1
                clusterISI(ii) = NaN;
                
            else
                clusterISI(ii) = maxInst - minInst;
            end
            
            
            
            

        end
        if isempty(trialTrunc)
             tLength(i) = NaN;
        else
            
            tLength(i) = range(trialTrunc);
        end
        
        
        ISI{i} = clusterISI;
        
    end
    
    
    
    
    for cluster = 1:length(goodClusters)
        x = ISI{cluster};
        
        
        
        for compare = 1:length(goodClusters)
            
            
            y = ISI{compare};
            
            
            for t = 1:numInstances
                if x(t) <= y(t)
                    
                    ratio(t) = x(t)/y(t) - 1;
                else
                    ratio(t) = -(x(t)/y(t) - 1);
                end
            end
            DI = 0;
            
            % Replace NANs with 0s for Diff calculation
            I = zeros(numInstances,1);
            for time = 1:numInstances
                
                if isnan(ratio(time)) ==1
                    I(time) = 0;
                    continue
                else
                    I(time) = ratio(time);
                end
            end
            
            
            % find integral of I - discrete steps so easy numerical method
            
            % Index of final value of step, change occurs at the next index
            stepIND = find(logical(diff(I)) == 1);
            xLength = 0;
            numSteps = length(stepIND);
            
            if numSteps < numSpikesCriteria
                integral(cluster, compare, sweep) = 100;
                continue
            end
            
            for i = 1:numSteps
                
                stepVals(i) = I(stepIND(i));
                if i == 1
                    stepLengths(i) = 0;
                else
                    stepLengths(i) = stepIND(i) - stepIND(i-1);
                end
                
                
                
            end
            
            stepLengths = stepLengths / (numInstances / 0.6);
            
            stepArea = stepLengths(2:end) .* abs(stepVals(2:end));
            
            % time weighted varient
            lenT1 = tLength(cluster);
            lenT2 = tLength(compare);



            if lenT1 > lenT2
                integral(cluster, compare, sweep) = sum(stepArea) / lenT1;
            else
                integral(cluster, compare, sweep) = sum(stepArea) / lenT2;
            end
            
            % spike weighted varient
            %integral(cluster, compare, sweep) = sum(abs(I)) /1000;
            
        end
    end
end
% end

% c1 = whisker1(3).singleTrials{8};
% c2 = whisker1(1).singleTrials{8};
% 
% 
% 
% test1 = c1(c1 > tMin & c1 < tMax);
% test2 = c2(c2 > tMin & c2 < tMax);
% 
% close all, figure, hold on
% plot(test1, ones(length(test1),1), 'o')
% plot(test2, 2*ones(length(test2),1), 'o')
% set(gca, 'ylim', [0,4]);
% set(gca,'xlim', [tMin,tMax])
% 
% numer = length(find(integral < 0.5));
% 
% 
% %minval=min( nonzeros(Cost_optimum));
% 
% 
% [m,mIND] = min(nonzeros(integral(:)));
% [m1,m2,m3] = ind2sub(size(integral), mIND);
% 
% 
% plot(trialTrunc, ones(length(trialTrunc)), 'o')
% 
% end