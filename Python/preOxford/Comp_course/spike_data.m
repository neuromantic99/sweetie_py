close all, figure

%plot(single_trial, ones(sz), 'o'), xlabel('time(ms)')

%edges = 0:10:1000;
edges = linspace(0,20,20);

response = histc(single_trial, edges);

response = response / 0.01;

response2 = condition1(1,:);

for i = 1:length(condition1(1,:))
    subplot(11,10,i)
    bar(edges, condition1(:,i)/0.01, 'histc')
end






