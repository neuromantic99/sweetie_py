function [inputs, numer_outputs, test_inputs, test_outputs] = irisTrainSet()

% loads iris classifier training set from
% (http://archive.ics.uci.edu/ml/machine-learning-databases/iris/bezdekIris.data
% split into inputs and outputs to neural network

% Initialize variables.
filename = '/Users/jimmy/Desktop/Matlab_scripts/iris_data.txt';
delimiter = ',';
formatSpec = '%f%f%f%f%s%[^\n\r]';

% Open the text file.
fileID = fopen(filename,'r');

% Read columns of data according to format string.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);

% Close the text file.
fclose(fileID);

% Create output variable and clear temporary variables
dataArray([1, 2, 3, 4]) = cellfun(@(x) num2cell(x), dataArray([1, 2, 3, 4]), 'UniformOutput', false);
irisdata = [dataArray{1:end-1}];
clearvars filename delimiter formatSpec fileID dataArray ans;

inputs = cell2mat(irisdata(:,1:4));
outputs = irisdata(:,5);

% transform the three flower-type strings into the binary activity
% of three output nodes

numer_outputs = zeros(150, 3);

for i = 1:length(outputs)
    
    if strcmp('Iris-setosa', outputs(i))
        numer_outputs(i,:) = [1,0,0];
    
    elseif strcmp('Iris-versicolor', outputs(i))
        numer_outputs(i,:) = [0,1,0];
        
    else 
        numer_outputs(i,:) = [0,0,1];
        
    end
    
end

%randomly chose x examples from the training set to remove and test the
% network
num_training_examples = 20;

rng(1)
ix=randperm(150);
ix=ix(1:num_training_examples);

for i = 1:length(ix)
    test_inputs(i,:) = inputs(ix(i), :); 
    test_outputs(i,:) = numer_outputs(ix(i), :);
    
end

% remove test set from training set
inputs(ix, :) = [];
numer_outputs(ix, :) = [];

end
        



