clear

fPath = '/media/jamesrowland/DATA/RawData/Behaviour/2018/2018-4-4-sensory_stimulation/fclock_gtrs17a.txt';
fc = load(fPath);


gap = [];
count = 0;
for i = 1:length(fc) - 1
    sub = fc(i+1) - fc(i);
    
    if abs(sub) < 100000
        count = count + 1;
        gap(count) = sub;
    end
end

gap = gap / 1000;

fRate = 1000/mean(gap);






