cycles_done = 0;
learn_rate = 10.^-2;

for j = 1:length(learn_rate)
    for i = 1:10
        [inputs(:,:,i), outputs(:,:,i), test_inputs(:,:,i), test_outputs(:,:,i)] = airfoilTrainSet(i);

        %pe_linear(i,j) = pcNetworkLinear(inputs(:,:,i), outputs(:,:,i), test_inputs(:,:,i), test_outputs(:,:,i), learn_rate(j));
        pe_predictive(i,j) = pcNetwork(inputs(:,:,i), outputs(:,:,i), test_inputs(:,:,i), test_outputs(:,:,i), learn_rate(j));
        %pe_backprop(i,j) = backpropBias(inputs(:,:,i), outputs(:,:,i), test_inputs(:,:,i), test_outputs(:,:,i), learn_rate(j));

        clearvars inputs outputs test_inputs test_outputs

        cycles_done = cycles_done + 1

    end
end

%mean_lin = mean(pe_linear);
mean_pc = mean(pc_predictive)
%mean_backprop = mean(pe_backprop);


close all, figure, hold on
xlabel('prediction mode iteration')
ylabel('mean squared error')
title('PC predicition error no repeated training examples')

%plot(mean_pc)
plot(mean_lin)
%plot(mean_backprop)
%legend('Predictive coding', 'Predicitve coding no derivative', 'ANN')
