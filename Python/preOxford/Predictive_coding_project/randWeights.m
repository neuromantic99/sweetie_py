function [weights] = randWeights(num_inputs, num_hidden, num_outputs)

rng(1)
theta0 = 2*rand(num_inputs, num_hidden) - 1;
theta1 = 2*rand(num_hidden, num_outputs) - 1;

% initialise bias node weights

thetaB0 = 2*rand(1, num_hidden);
thetaB1 = 2*rand(1, num_outputs);

weights = {theta0; thetaB0; theta1; thetaB1};

end