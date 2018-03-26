close all, figure
for i = 1:9
subplot(3,3,i)
plot(ans.date_2018_02_26.area1.plane1.fluoresence_corrected(i+10,:))
end