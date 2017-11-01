startVoltage = 5;
targetVoltage = 3.3;

target = targetVoltage/startVoltage;


x = [100, 220, 330, 470, 680, 1000, 2200, 3300, 4700, 10000, 22000, 47000, 100000, 330000, 1000000];
y = [100, 220, 330, 470, 680, 1000, 2200, 3300, 4700, 10000, 22000, 47000, 100000, 330000, 1000000];

for i = 1:length(x)
    for ii = 1:length(y)
        result = x(i)/ (x(i) + y(ii));
        difference(i,ii) = abs(result - target);
        
    end
end

minMatrix = min(difference(:));
[row,col] = find(difference==minMatrix);

res1 = x(row);
res2 = y(col);