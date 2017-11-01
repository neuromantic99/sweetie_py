function[l2] = pcPredicBias(inputs, num_outputs, num_hidden, weights)
  
theta0 = cell2mat(weights(1));
thetaB0 = cell2mat(weights(2));
theta1  = cell2mat(weights(3));
thetaB1 = cell2mat(weights(4));

% initialise node values

error1 = 2*rand(1, num_hidden)-1;
error2 = 2*rand(1, num_outputs)-1;

l1 = 2*rand(1, num_hidden)-1;
l2 = 2*rand(1, num_outputs)-1;

% initialise bias

bias = 1;

% prediction mode

l0 = inputs(1,:);

num_iter = 100;
    
for iter = 1:num_iter

    % perform euler forward integration

    DT = 0.5;
    maxt = 5;

    for j = 1:maxt/DT
        
        [~, l1_deriv] = sig(l1);
        diff_eq = -error1 + error2 * transpose(theta1) .* l1_deriv;
        
        
        l1 = l1 + DT .* diff_eq;
 
        l2 = l2 + DT .* (-error2);
        
        sigma = 100;

        error2 = l2 - (sig(l1) * theta1 + bias * thetaB1);
        error1 = l1 - (sig(l0) * theta0 + bias * thetaB0);
        
        error2 = error2/sigma;
        
        

    end

end

end


%F(iter) = -0.5 * (sum(error1.^2) + sum(error2.^2));

        
        
        
        
        
    
    
    
    



