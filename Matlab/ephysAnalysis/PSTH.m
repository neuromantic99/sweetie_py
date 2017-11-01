function [meanFit, stimResponsive, jitter, time2peak, SRI, startBinSize, conf] = PSTH(toHist, startBinSize)

% calculate time to peak and jitter

edges1 = linspace(0,5,5 / 1 * 1000 + 1);
    
N1 = histcounts(toHist, edges1);
    
baselineIND1 = find(edges1 < 1 & edges1 > 0.5);
baseRate1 = sum(N1(baselineIND1)) / length(baselineIND1);
baseSTD1 = std(N1(baselineIND1));

% all spikes after stim
stimTriggeredIND1 = find(edges1 >= 1.5 & edges1 < 1.6);
optoOn = find(edges1 >= 1 & edges1 < 1.49);
spikesIND1 = find(N1(stimTriggeredIND1) > (baseRate1 + 2* baseSTD1));
[peakBar1, peakBarIND1] = max(N1(stimTriggeredIND1));

time2peak = peakBarIND1; %ms
mwhisk = max(N1(stimTriggeredIND1));
mopto = max(N1(optoOn));


ifDriven = mwhisk - mopto;


    
    

jitter = length(spikesIND1); %jitter in ms

failed = 0;

testFailed = 0;


while failed < 4
    
    
    
    edges = linspace(0,5,5 / startBinSize * 1000 + 1);
    
    N = histcounts(toHist, edges);

    
    fit = barsP(N, [0 max(toHist)], 60);
    modeFit = getfield(fit, 'mode');
    modeFine = getfield(fit, 'mode_fine');
    meanFit = getfield(fit, 'mode');
    conf = getfield(fit, 'confBands');
    confFine = getfield(fit, 'confBands_fine');
    
    %baseline firing rate before stimulus occurs
    baselineIND = find(edges < 1 & edges > 0.5);
    baseRate = sum(N(baselineIND)) / length(baselineIND);
    baseSTD = std(N(baselineIND));
    
    % the peak upper confidence interval of BARS pre stimulus
    threshold = max(conf(baselineIND,2));
    
    
    % all spikes within 100ms of stim
    stimTriggeredIND = find(edges > 1.49 & edges < 1.6);
    
    % the peak of lower confidence interval just after stimulus
    lowConfPeak = max(conf(stimTriggeredIND,1));
    
    
    stimResponsive = 0;
    if lowConfPeak > threshold
        stimResponsive = 1;
    end
    
    %peak height
    [peakHeight, peakIND] = max(meanFit);
    
    spikesIND = find(N(stimTriggeredIND) > (baseRate + 2* baseSTD));
    [peakBar, peakBarIND] = max(N(stimTriggeredIND));
    
    
    % get SRI
    SRI = 100 * ((peakHeight - baseRate) / baseRate);
    
    if testFailed < 3
        
        
      
        
        testSRI = 100 * ((peakBar - baseRate) / baseRate);
        
        if testSRI < 120 || ifDriven < 0
            %meanFit = 'n/a';
            stimResponsive =0;
            jitter = 'n/a';
            time2peak = 'n/a';
            
            break
        end
        
        testFailed = testFailed + 1;
    end
    
   
    
    
    
    
    
    % get the range of values where the peak is likely to occur
    
    peakRangeIND = find(edges > 1.5 & edges < 1.7);
    peakRange = meanFit(peakRangeIND);
    xPeakRange = edges(peakRangeIND);
    
    
    % get the second derivative of the BARS trace
    dy=diff(peakRange)./diff(1:length(peakRange));
    dy = dy(:,1);
    dy2 = diff(dy)./diff(1:length(peakRange));
    try
        dy2 = dy2(:,1);
    catch
         stimResponsive =0;
         jitter = 'n/a';
         time2peak = 'n/a';
            
         break
    end
        
    
    % ensure BARS finds the first peak
    if abs(max(dy2)) < 3
        failed = failed + 1;
        disp(['Failed attempt ' num2str(failed)]);
        
        
        if failed == 3
            startBinSize = startBinSize + 5;
            failed = 0;
            disp('Adding 5ms to bin Size')

        end
       
        continue
    end
    
    % get the start of the peak
    
    halfPeak = ceil(length(dy2)/3);
    halfWay = ceil(length(dy2)/2);
    [~, diffPeakStart] = max(dy2(1:halfWay));
    %dy2(diffPeakStart) = 0.00001;
    secondHighest = max(dy2(halfWay:end));
    diffPeakStart2 = find(dy2 == secondHighest);
    peakStartIND = peakRangeIND(diffPeakStart);
    peakStartIND2 = peakRangeIND(diffPeakStart2);
    
    
    
    %jitter = abs(peakStartIND - peakStartIND2) * startBinSize; %ms
    
    
    
    
    failed = 6;
    disp('success')
    
end

close all, figure, hold on

hFig = histogram(toHist, edges);
plot(edges(1:end-1) + startBinSize / 2000, meanFit);


plot(edges(1:end-1) + startBinSize / 2000, conf(:,1), '--', 'linewidth', 2, 'color', 'black')
plot(edges(1:end-1) +  startBinSize / 2000, conf(:,2), '--', 'linewidth', 2, 'color', 'black')
plot(edges, repmat(baseRate, length(edges)));
%plot(xPeakRange(1+1:end-1),dy2);

