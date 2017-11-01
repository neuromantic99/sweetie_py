function [prediction_error] = pcNetworkLinear(inputs, outputs, test_inputs, test_outputs, learn_rate)

% function to run PC network. inputs and outputs should be matrices in the form
% number-training-examples x number-inputs/outputs

num_inputs = length(inputs(1,:));
num_hidden = 10;
num_outputs = length(outputs(1,:));

rand_weights = randWeights(num_inputs, num_hidden, num_outputs);

% learn weights - learning mode
[weights] = pcLearnLinear(inputs, outputs, num_hidden, rand_weights, learn_rate);

% set input value(s) for generalisation test, run prediction mode

for i = 1:length(test_inputs)
    
    test_l2s(i) = pcPredicLinear(test_inputs(i,:), num_outputs, num_hidden, weights);
    
end

for i = 1:length(test_l2s(i))
    sq_error(i) = (test_l2s(i) - test_outputs(i)).^2;
end

prediction_error = mean(sq_error);

% close all, figure, hold on
% for i = 1:length(diff(:,1))
%     plot(diff(i,:))
% end

end




