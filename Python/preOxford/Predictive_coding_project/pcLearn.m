function[weights] = pcLearnBias(inputs, outputs, num_hidden, weights, learn_rate)

% initialise node values
num_outputs = length(outputs(1,:));

error1 = 2*rand(1, num_hidden)-1;
error2 = 2*rand(1, num_outputs)-1;
l1 = 2*rand(1, num_hidden)-1;

% initialise weight

theta0 = cell2mat(weights(1));
thetaB0 = cell2mat(weights(2));
theta1  = cell2mat(weights(3));
thetaB1 = cell2mat(weights(4));

% prediction, establish steady state in nodes

num_iter = 200;
%F = zeros(length(outputs), num_iter);

for iter = 1:num_iter
    
    for i = 1:length(outputs)
    
        l2 = outputs(i,:);
        l0 = inputs(i,:);

    %perform euler forward integration
        DT = 0.5;
        maxt = 5;
    
        for j = 1:maxt/DT

            [~, l1_deriv] = sig(l1);
            diff_eq = -error1 + error2 * transpose(theta1) .* l1_deriv;


            l1 = l1 + DT .* diff_eq;


            l2 = l2 + DT .* (-error2);

            sigma = 100;

            error2 = l2 - (sig(l1) * theta1 + thetaB1);
            error1 = l1 - (sig(l0) * theta0 + thetaB0);

            error2 = error2/sigma;

        end
        
        
%         F(i,iter) = -0.5 * (sum(error1.^2) + sum(error2.^2));
%         F = sum(F);
        
        %update the weights
        
        alpha = learn_rate;
        
        theta0 = theta0 + alpha * (transpose(sig(l0)) * error1);
        thetaB0 = thetaB0 + alpha * error1; 
        
        theta1 = theta1 + alpha * (transpose(sig(l1)) * error2);
        thetaB1 = thetaB1 + alpha * error2; 
        
    end
    
end

% save weights required by other functions
weights = {theta0; thetaB0; theta1; thetaB1};

end

















   
    
    






