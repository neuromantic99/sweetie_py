function waterOn = getWaterOn(inSession)
    
pl = inSession.print_lines;

waterOn = [];

for i = 1:length(pl)
    if contains(pl(i), 'waterON')
        ss = split(pl(i),' ');
        waterOn(end+1) = str2double(ss{2});
    end
end
