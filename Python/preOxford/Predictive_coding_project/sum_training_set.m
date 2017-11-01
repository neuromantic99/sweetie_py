num_inputs = 1;
num_train_exams = 5;
rng(1)

for i = 1:num_train_exams
    
    inputs(i,:) = rand(1, num_inputs);
    inputs = round(inputs, 1);
    outputs(:,i) = inputs(i,:) + 0.5;
    
end

outputs = transpose(outputs);


