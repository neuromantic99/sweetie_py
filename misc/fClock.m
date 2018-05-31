fPath = '/media/jamesrowland/DATA/RawData/Behaviour/2018/CTBD1.1j_area01_frameclock.txt';
fc = load(fPath);

for i = 1:length(fc)-1
    diff(i) = fc(i+1) - fc(i);
    
end

% throw out difference between imaging sessions.
% Frame time differece should not be more than 100ms 
idx = find(diff>100000 | diff < 0);
diff(idx) = [];

close all
figure
plot(diff,'.')

md = mean(diff) / 1000;


fRate = 1000 / md;
