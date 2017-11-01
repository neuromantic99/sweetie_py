function [inputs, outputs, test_inputs, test_outputs] = airfoilTrainSet(crossval_iter) 

filename = '/Users/jimmy/Desktop/Matlab_scripts/airfoil_self_noise.txt';
delimiter = '\t';

formatSpec = '%f%f%f%f%f%f%[^\n\r]';

fileID = fopen(filename,'r');

dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);

fclose(fileID);

airfoil_data = [dataArray{1:end-1}];
idx = randperm(length(airfoil_data));
airfoil_data = airfoil_data(idx,:);

clearvars filename delimiter formatSpec fileID dataArray ans;

len = length(airfoil_data);

if crossval_iter == 1
    
    ix = 1:len/10;
    
end

for i = 2:10
    
    if crossval_iter == i
        
        ix = round((len/10)*(i-1)):round((len/10)*i);
    
    end
end

inputs = airfoil_data(:,1:5);

outputs = airfoil_data(:,6);

for i = 1:length(inputs(1,:))

    maxin = max(inputs(:,i));
    minin = min(inputs(:,i));

    for j = 1:length(inputs(:,1))

        inputs(j,i) = (inputs(j,i) - minin) / (maxin - minin);

    end
end

for i = 1:length(outputs(1,:))

    maxin = max(outputs(:,i));
    minin = min(outputs(:,i));

    for j = 1:length(outputs(:,1))

        outputs(j,i) = (outputs(j,i) - minin) / (maxin - minin);

    end
end

test_inputs = inputs(ix,:);
test_outputs = outputs(ix,:);

inputs(ix,:) = [];
outputs(ix,:) = [];


end








