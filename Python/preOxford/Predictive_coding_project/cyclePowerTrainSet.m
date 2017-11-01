function [inputs, outputs, test_inputs, test_outputs] = cyclePowerTrainSet()

% Import the data
[~, ~, raw] = xlsread('/Users/jimmy/Desktop/Matlab_scripts/Folds5x2_pp.xlsx','Sheet1');
raw = raw(2:end,:);
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};

% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
raw(R) = {NaN}; % Replace non-numeric cells

% Create output variable
plant_powers = reshape([raw{:}],size(raw));

% Clear temporary variables
clearvars raw R;

inputs = plant_powers(:,1:4);
outputs = plant_powers(:,5);


num_training_examples = 100;

rng(1)
ix=randperm(length(inputs));
ix=ix(1:num_training_examples);

for i = 1:length(ix)
    test_inputs(i,:) = inputs(ix(i), :); 
    test_outputs(i,:) = outputs(ix(i), :);
    
end

% remove test set from training set
inputs(ix, :) = [];
outputs(ix, :) = [];

end