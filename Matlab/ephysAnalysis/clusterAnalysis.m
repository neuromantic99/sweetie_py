clear
PVpath = '17-33-13.mat';
%PVpath = 'PVmerged.mat';
PV = load(PVpath);
PVwhisk = PV.unitDataWhisk;
PVboth = PV.unitDataBoth;

SOMpath = '20-29-14.mat';
%SOMpath = '17-57-44.mat';

SOM = load(SOMpath);
SOMwhisk = SOM.unitDataWhisk;
SOMboth = SOM.unitDataBoth;

clusterDepthsWhisk = PVwhisk.depths;
for i = 1:length(PVwhisk)
    clusterDepthsWhisk(i) = PVwhisk(i).depths;
end

for i = 1:length(SOMwhisk)
    clusterDepthsSOM(i) = SOMwhisk(i).depths;
    
end

if strcmp(PVpath, '17-33-13.mat')
    goodPV = [1,2,3,5,7,8,9,11];
    for i = 1:length(PVboth)
        if (PVboth(i).depths >= 400) && (PVboth(i).depths <= 500)
            PVboth(i).layer = 4;
        elseif PVboth(i).depths > 500
            PVboth(i).layer = 5;
        else
            PVboth(i).layer = 23;
        end
        PVwhisk(i).layer = PVboth(i).layer;
    end
end

if strcmp(PVpath, 'PVmerged.mat')
    goodPV = 2:8;
    for i = 1:length(PVboth)
        if (PVboth(i).depths >= 300) && (PVboth(i).depths <= 400)
            PVboth(i).layer = 4;
        elseif PVboth(i).depths > 400
            PVboth(i).layer = 5;
        else
            PVboth(i).layer = 23;
        end
        PVwhisk(i).layer = PVboth(i).layer;
    end
end


if strcmp(SOMpath, '20-29-14.mat')
    goodSOM = 1:8;
    for i = 1:length(SOMboth)
        if (SOMboth(i).depths >= 425) && (SOMboth(i).depths <= 550)
            SOMboth(i).layer = 4;
        elseif SOMboth(i).depths > 550
            SOMboth(i).layer = 5;
        else
            SOMboth(i).layer = 23;
        end
        
        SOMwhisk(i).layer = SOMboth(i).layer;
    end
end

if strcmp(SOMpath, '17-57-44.mat')
    goodSOM = 1:5;
    for i = 1:length(SOMboth)
        if (SOMboth(i).depths >= 300) && (SOMboth(i).depths <= 425)
            SOMboth(i).layer = 4;
        elseif SOMboth(i).depths > 400
            SOMboth(i).layer = 5;
        else
            SOMboth(i).layer = 23;
        end
        
        SOMwhisk(i).layer = SOMboth(i).layer;
    end
end

%timepoint = linspace(1.7,3.3, 161); 
timepoint = linspace(1.5,3.5, 50);
for t = 1
    
    time = timepoint(t); 

    tMin = 1.5;
    tMax = 2;



simPVwhisk = similarityRatio(PVwhisk, tMin, tMax, goodPV);
simPVboth = similarityRatio(PVboth, tMin, tMax, goodPV);

pvWhisk(t,:) = simPVwhisk(:);
pvBoth(t,:) = simPVboth(:);



simSOMwhisk = similarityRatio(SOMwhisk, tMin, tMax, goodSOM);
simSOMboth = similarityRatio(SOMboth, tMin, tMax, goodSOM);

somWhisk(t,:) = simSOMwhisk(:);
somBoth(t,:) = simSOMboth(:);



allPVBoth = simPVboth(simPVboth~=100);
allPVWhisk = simPVwhisk(simPVwhisk~=100);

allSOMBoth = simSOMboth(simSOMboth~=100);
allSOMWhisk = simSOMwhisk(simSOMwhisk~=100);


criteria = 0.5;

perPVBoth(t) = (length(find(allPVBoth < criteria)) / length(allPVBoth)) * 100;
perPVWhisk(t) = (length(find(allPVWhisk < criteria)) / length(allPVWhisk)) * 100;

perSOMBoth(t) = (length(find(allSOMBoth < criteria)) / length(allSOMBoth)) * 100;
perSOMWhisk(t) = (length(find(allSOMWhisk < criteria)) / length(allSOMWhisk)) * 100;

% compare layer 4 to layer 5


layerSimsWhiskPV = layerComp(PVwhisk, simPVwhisk, goodPV, 4, 5, criteria, tMin, tMax);
layerSimsBothPV =  layerComp(PVboth, simPVboth, goodPV, 4, 5, criteria, tMin, tMax);

layerSimsWhiskSOM = layerComp(SOMwhisk, simSOMwhisk, goodSOM, 4,5, criteria, tMin, tMax);
layerSimsBothSOM = layerComp(SOMboth, simSOMboth, goodSOM, 4,5, criteria, tMin, tMax);


whiskSOMl4l5(t,:) = allCell(layerSimsWhiskSOM);
bothSOMl4l5(t,:) = allCell(layerSimsBothSOM);

whiskPVl4l5(t,:) = allCell(layerSimsWhiskPV);
bothPVl4l5(t,:) = allCell(layerSimsBothPV);

% l4vl5whisk(t) = (length(find(allSimsWhisk{t} < criteria)) / length(allSimsWhisk{t}(allSimsWhisk{t}~=100))) * 100;
% l4vl5both(t) = (length(find(allSimsBoth{t} < criteria)) / length(allSimsBoth{t}(allSimsBoth{t}~=100))) * 100;
% 
end



x = PVwhisk(1).singleTrials{9};
x = x(x>tMin & x<tMax);
y = PVwhisk(4).singleTrials{9};
y = y(y>tMin & y<tMax);


close all, figure, hold on

plot(x, ones(length(x)), 'o','color', 'red')
plot(y, 2*ones(length(y)), 'o')
set(gca, 'ylim', [0,4])
set(gca, 'xlim', [tMin,tMax])

csvwrite('nonPropagating_l4_pattern.csv', x)
csvwrite('nonPropagating_l5_pattern.csv', y)





% 
% 
% 
% 
% close all, figure, hold on
% % plot(timepoint, perPVWhisk)
% % plot(timepoint, perPVBoth, 'red')
% plot(timepoint,l4vl5whisk)
% plot(timepoint,l4vl5both, 'red')









% 
% x= [1,0,0,0,0,0,1,0,0,0];
% 
% y = [0,1,0,0,0,0,1,0,0,0];
% 
% xIND = find(x==1);
% 
% 
% 
% [r, lag] = xcorr(x, y, 5);
% [~,peakIND] = max(r);
% 
% lagdiff = lag(peakIND);



close all
for i = 1:20

%     subplot(4,5,i)
%     histogram(SOMboth(i).allTrials, 51);


end


histogram(SOMboth(5).allTrials, 51);

csvwrite('SOMbothStims2.csv', SOMboth(5).allTrials)


% %the good PV for 19-14-14 whisker
%goodPV = 1:3;

% % the good PV for 19-14-14 both
%goodPV = 1:5;

% % the good SOM for 17-57-44
%goodSOM = 1:5;


% csvwrite('l5_1.csv' , PVboth(1).allTrials)
% csvwrite('l5_2.csv' , PVboth(2).allTrials)
% csvwrite('l4_1.csv' , PVboth(3).allTrials)
% csvwrite('l4_2.csv' , PVboth(4).allTrials)
% csvwrite('l5_3.csv' , PVboth(5).allTrials)
% csvwrite('l23_1.csv' , PVboth(6).allTrials)
% csvwrite('l5_4.csv' , PVboth(7).allTrials)
% csvwrite('l4_3.csv' , PVboth(8).allTrials)
% csvwrite('l4_4.csv' , PVboth(9).allTrials)
%
%

% csvwrite('l5_1.csv' , SOMwhisk(1).allTrials)
% csvwrite('l5_2.csv' , SOMwhisk(2).allTrials)
% csvwrite('l5_3.csv' , SOMwhisk(3).allTrials)
% csvwrite('l4_1.csv' , SOMwhisk(4).allTrials)
% csvwrite('l5_4.csv' , SOMwhisk(5).allTrials)
% csvwrite('l5_5.csv' , SOMwhisk(6).allTrials)
% csvwrite('l5_6.csv' , SOMwhisk(7).allTrials)
% csvwrite('l5_7.csv' , SOMwhisk(8).allTrials)


