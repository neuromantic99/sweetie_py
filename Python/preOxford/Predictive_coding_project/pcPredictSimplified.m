function[l2] = pcPredicLinear(inputs, num_outputs, num_hidden, weights)

theta0 = cell2mat(weights(1));
thetaB0 = cell2mat(weights(2));
theta1  = cell2mat(weights(3));
thetaB1 = cell2mat(weights(4));

% initialise node values

error1 = zeros(1, num_hidden);
error2 = zeros(1, num_outputs);

l1 = zeros(1, num_hidden);
l2 = zeros(1, num_outputs);

% initialise bias

bias = 1;

% prediction mode

l0 = inputs(1,:);

%num_iter = 100;

%for iter = 1:num_iter

% perform euler forward integration

DT = 0.1;
maxt = 500;
F_past=-1e6;

for j = 1:maxt/DT
    
    diff_eq = -error1 + error2 * transpose(theta1);
    
    
    l1 = l1 + DT .* diff_eq;
    
    l2 = l2 + DT .* (-error2);
    
    sigma = 100;
    
    error2 = l2 - (sig(l1) * theta1 + bias * thetaB1);
    error1 = l1 - (sig(l0) * theta0 + bias * thetaB0);
    
    error2 = error2/sigma;
    
    F=error1*error1' + error2*error2'*sigma;
    
    if F<F_past
        keyboard
    end
    
    F_past=F;
    
end

%end

end


%F(iter) = -0.5 * (sum(error1.^2) + sum(error2.^2));













