function [inputs, outputs, test_inputs, test_outputs] = tanhTrainSet(num_examples)

inputs = linspace(-5, 5, num_examples);

inputs = transpose(inputs);

outputs = sig(inputs);
outputs = sig(outputs);


num_training_examples = 50;

rng(1)
ix=randperm(length(inputs));
ix=ix(1:num_training_examples);

for i = 1:length(ix)
    test_inputs(i,:) = inputs(ix(i), :); 
    test_outputs(i,:) = outputs(ix(i), :);
    
end

%remove test set from training set
inputs(ix, :) = [];
outputs(ix, :) = [];



end
