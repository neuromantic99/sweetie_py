% whisk = simPVboth(:);
% both = simPVwhisk(:);
% 

whiskPVl4l5(whiskPVl4l5 == 100) = NaN;
bothPVl4l5(bothPVl4l5 == 100) = NaN;


for i = 1:50
    [t(i), p(i)] = ttest2(whiskPVl4l5(i,:), bothPVl4l5(i,:));
end
    


for i = 1:50
    [x,conf, RL, RU] =  corrcoef(whiskPVl4l5(i,:)', bothPVl4l5(i,:)', 'rows', 'pairwise');
    cc(i) = x(1,2);
    confi(i) = conf(1,2);
    upper(i) = RL(1,2);
    lower(i) = RU(1,2);
    
end

sidek = 1- (1-0.05) ^ (1/8);
% 
close all, figure, hold on
plot(l4vl5both, 'blue')
plot(l4vl5whisk,'red')
% % plot(cc)
% plot(upper)
% plot(lower)
plot(1:50, repmat(0.05/30,50))
plot(p)
% 

indexes = find(p<(0.05/30))


% 
