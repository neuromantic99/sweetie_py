% training set, output should be sum of input layers
% training set randomly generated

% generate training set
function [prediction_error] = backpropBias(inputs, outputs, test_inputs, test_outputs, weights learn_rate)

% generate 20 non-repeating integers from 1-150. Index to create
% generalisation test set

num_inputs = length(inputs(1,:));
num_hidden = 10;
num_outputs = length(outputs(1,:));

% random initial weights (seeded)

rng(1)
syn0 = weights{1};
synB0 = weights{2};
syn1 = weights{3};
synB1 = weights{4};

num_iterations = 500;

prediction_error = zeros(1,num_iterations);

for iter = 1:num_iterations 
    
    for i = 1:length(outputs)
    
        % forward propagation
        l0 = inputs(i,:);
        

        %linear output node, but sigmoidal hidden layers
        l1 = sig(l0 * syn0); 
        l1(1) = 1;
      
        l2 = purelin(l1 * syn1);

        l2_error = outputs(i,:) - l2;

        % Delta function, linear transfer function so derivative = 1
        % calculation shown for illustration

        l2_delta = l2_error .* 1;

        % backpropagation
        l1_error = l2_delta * transpose(syn1);

        [~, outDir1] = sig(l1);
        l1_delta = l1_error .* outDir1;

        % update the weights
        alpha = learn_rate;
        syn1 = syn1 + alpha .* (transpose(l1) * l2_delta);
        syn0 = syn0 + alpha .* (transpose(l0) * l1_delta);

        
    end
  
% generalisation test

for i = 1:length(test_inputs)

    input_test = test_inputs(i,:);

    l0_test = [1 input_test];
    l1_test = sig(l0_test * syn0);
    l1_test(1) = 1;
    l2_test(i,:) = purelin(l1_test * syn1);
end

for i = 1:length(l2_test(:,1))
        sq_error(i) = (l2_test(i) - test_outputs(i)).^2;
end

prediction_error = mean(sq_error);

end
% l2_test = l2_test*100;
% test_outputs = test_outputs*100;





   
    
    







