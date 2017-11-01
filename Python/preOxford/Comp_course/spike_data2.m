close all, figure, hold on

mn = zeros(1,101);
for i = 1:20
    mn = mn + condition1(i,:)/0.01;
end
mn = mn/20;

edges = 0:10:1000;

mean_cond1 = mean(condition1);

std_cond1 = std(condition1);
std_error = sqrt(std_cond1/20);

mean_cond2 = mean(condition2);
std_cond2 = std(condition2);

bar(edges, mean_cond1, 'histc')
errorbar(edges+5, mean_cond1, std_error,'x')