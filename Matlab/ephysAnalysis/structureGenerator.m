
Folder = '2017-08-08_17-57-44less5';


fPath = strcat('/Users/James/Desktop/Kilosort_processed/', Folder,'/');
stimPath = strcat('/Users/James/Desktop/Python/', Folder, '.mat');

%[trigSpikesWhisk, allTrialsWhisk, unitDataWhisk, numSUWhisk] = structureClusterData(fPath, stimPath, 'all', 'whisker', 1);
[trigSpikesOpto, allTrialsOpto, unitDataOpto, numSUOpto] = structureClusterData(fPath, stimPath, 'all', 'opto', 1);
[trigSpikesBoth, allTrialsBoth, unitDataBoth, numSUBoth] = structureClusterData(fPath, stimPath, 'all', 'both', 1);


close all
for i = 1:20
    subplot(4,5,i)
    histogram(trigSpikesOpto{11}, 21)
end





csvwrite('inhibitedSOM.csv', trigSpikesOpto{11});












    











% bothJit = mean(unitDataBoth.jitter);
% whiskJit = mean(unitDataWhisk.jitter);
% 
% % whiskJit = [];
% 
% for i = 1:length(unitDataWhisk)
%     jit = unitDataWhisk(i).jitter;
%     if strcmp(jit, 'n/a') == 1
%         whiskJit(i) = NaN;
%     else
%         whiskJit(i) = jit;
%     end
% end
% 
% bothJit = [];
% 
% for i = 1:length(unitDataBoth)
%     jit = unitDataBoth(i).jitter;
%     if strcmp(jit, 'n/a') == 1
%         bothJit(i) = NaN;
%     else
%         bothJit(i) = jit;
%     end
% end
% 






