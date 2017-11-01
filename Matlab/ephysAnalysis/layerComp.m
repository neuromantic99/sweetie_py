function [allComps] = layerComp(dataStruc, sims, goodUnits, inLay, outLay, criteria, tMin, tMax)
%[allComps, lags, isGood, numBinsInMS]


data = dataStruc(goodUnits);

inLayIND = find([data.layer] == inLay);
outLayIND = find([data.layer] == outLay);


allComps = cell(length(inLayIND), length(outLayIND));


lags = cell(length(inLayIND), length(outLayIND));

isGood = cell(length(inLayIND), length(outLayIND));



for unit = 1:length(inLayIND)
    %keyboard
    in = inLayIND(unit);
    
    for compare = 1:length(outLayIND)
        out = outLayIND(compare);
         include = [];
         lagSave = [];
           
        for trial = 1:60
            
           % lagPeak = [];
            result(trial) = sims(in, out, trial);
            
            if result(trial) < criteria
                
                lengthVector = 1000;
                
                inVect = zeros(ceil((tMax - tMin) * lengthVector), 1);
                outVect = zeros(ceil((tMax - tMin) * lengthVector), 1);
                
                % single trial spike times for the input unit
                inTimes = data(in).singleTrials{trial};
                outTimes = data(out).singleTrials{trial};
                
                inTimes = inTimes(inTimes > tMin & inTimes < tMax);
                outTimes = outTimes(outTimes > tMin & outTimes < tMax);
                
                normInTimes = inTimes - tMin;
                normOutTimes = outTimes - tMin;
                
                for i = 1:length(normInTimes)
                    inVect(ceil(normInTimes(i) * lengthVector)) = 1;
                end
                
                for i = 1:length(normOutTimes)
                    outVect(ceil(normOutTimes(i) * lengthVector)) = 1;
                end
                
                vectBinTime = (tMax - tMin) / lengthVector;
                numBinsInMS = (1/1000) / vectBinTime;
                
                maxLag = 20;
                
                numBinsInMax = ceil(maxLag * numBinsInMS);
                
                inSpikeIND = find(inVect==1);
                
                for i = 1:length(inSpikeIND)
                    spike = inSpikeIND(i);
                    try
                        inSpike = inVect(spike - numBinsInMax : spike + numBinsInMax);
                        outSpike = outVect(spike - numBinsInMax : spike + numBinsInMax);
                    catch
                        continue
                    end
                    
                    [r, lag] = xcorr(inSpike, outSpike);
                    
                    peakCorrs = find(r==1);
                    lagAtPeak = lag(peakCorrs);
                    
                    [~, lookHere] = min(abs(lagAtPeak));
                    
                    
                    
                    if sum(r) == 0
                        lagPeak(i) = NaN;
                     elseif isempty(peakCorrs)
                        lagPeak(i) = NaN;
                    else
                        
                        lagPeak(i) = lagAtPeak(lookHere);
                    end
                    
                    

                end
                try
                    for i = 1:length(lagPeak)
                            lagSave = [lagSave lagPeak(i)];
                    end
                catch
                    continue
                end
                                
            end
            
          
          try  
            signCheck = sign(lagPeak);

            if mean(signCheck) < 0
                include(trial) = 1;
            else
                include(trial) = 0;
            end
          catch
              include(trial) = 0;
          end
     %       keyboard
            
        end

        lags{unit, compare} = lagSave;
        allComps{unit, compare} = result;
        isGood{unit, compare} = include;
        
    end
end


